//
//  ViewController.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import UIKit

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switchToEditingMode(isEditing: true)
    }
}

extension ViewController: CarouselViewControllerDelegate {
    func updateState(newState: State) {
        setExchangeCurrency(fromCurrencyIndex: newState.rawValue, toCurrencyIndex: nil, amount: nil)
        displayRates()
    }
}

final class ViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var amountPlusTextField: UITextField!
    @IBOutlet weak var amountMinusTextField: UITextField!
    @IBOutlet weak var exchangeButton: UIBarButtonItem!
    @IBOutlet weak var amountPlusRateLabel: UILabel!
    @IBOutlet weak var amountMinusRateLabel: UILabel!
    @IBAction func tapRefresh(_ sender: Any) {
        actionRefresh()
    }
    @IBAction func tapExchange(_ sender: Any) {
        actionExchange()
    }
    @IBAction func tapSegementedControl(_ sender: UISegmentedControl) {
        setExchangeCurrency(fromCurrencyIndex: nil, toCurrencyIndex: sender.selectedSegmentIndex, amount: nil)
        displayRates()
    }
    @IBAction func textFieldEditingChange(_ sender: Any) {
        if let text = amountPlusTextField.text {
            setExchangeCurrency(fromCurrencyIndex: nil, toCurrencyIndex: nil, amount: Double(text))
        }
    }
    
    private let service = EuropeanCentralBankService()
    private let parser = Parser()
    private var coreData: PersistanceModel? = nil
    private var carouselViewController: CarouselViewController?
    private var currentCurrency: CurrencyType? = nil
    private var selectedToExchangeCurrency: CurrencyType? = nil
    private var amountToExchange: Double = 0.0
    private var converter: Converter?
    private var timer: Timer?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "carousel" {
            carouselViewController = segue.destination as? CarouselViewController
            carouselViewController?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreData = PersistanceModel()
        displayUserBalance()
        amountPlusTextField.delegate = self
        setupSegmentedControl()
        updateExchangeRatesRegularly()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        for (index, currency) in ViewModel.currences.enumerated() {
            segmentedControl.insertSegment(withTitle: currency.rawValue, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
        setExchangeCurrency(fromCurrencyIndex: nil, toCurrencyIndex: 0, amount: nil)
    }
    
    @objc
    private func actionRefresh() {
        let isDataValid = parser.parse(url: service.api.url!)
        if isDataValid {
            converter = Converter(rates: parser.currencies)
            displayRates()
        } else {
            print("XML Parser Error: \(parser.parsingError!)")
        }
    }
    
    private func displayRates() {
        guard let safeConverter = converter else {
            return
        }
        if let safeCurrentCurrency = currentCurrency, let safeSelected = selectedToExchangeCurrency {
            let rate1Conversion = safeConverter.convert(fromCurrency: safeSelected, toCurrency: safeCurrentCurrency, amount: 1)
            if rate1Conversion.sucess {
                let formattedRate = String(format: "%.2f", rate1Conversion.amount!)
                amountPlusRateLabel.text = "\(safeSelected.symbol())1 = \(safeCurrentCurrency.symbol())\(formattedRate)"
            } else {
                amountPlusRateLabel.text = nil
            }
            let rate2Conversion = safeConverter.convert(fromCurrency: safeCurrentCurrency, toCurrency: safeSelected, amount: 1)
            if rate2Conversion.sucess {
                let formattedRate = String(format: "%.2f", rate2Conversion.amount!)
                amountMinusRateLabel.text = "\(safeCurrentCurrency.symbol())1 = \(safeSelected.symbol())\(formattedRate)"
            } else {
                amountMinusRateLabel.text = nil
            }
        }
    }
    
    /// Set one of 3 properties required for exchange. This method validates
    /// all 3 properties and toggles Exchange button enabled state.
    private func setExchangeCurrency(fromCurrencyIndex: Int?, toCurrencyIndex: Int?, amount: Double?) {
        if let to = toCurrencyIndex {
            selectedToExchangeCurrency = ViewModel.currences[to]
        }
        if let from = fromCurrencyIndex {
            currentCurrency = ViewModel.userAccounts[from]
        }
        if let safeAmount = amount {
            amountToExchange = safeAmount
        }
        
        if currentCurrency == nil || selectedToExchangeCurrency == nil || amountToExchange == 0 {
            exchangeButton.isEnabled = false
        } else {
            // It should not be possible to exchange to the same currency.
            exchangeButton.isEnabled = currentCurrency != selectedToExchangeCurrency
        }
    }
    
    /// Only call this when selectedToExchangeCurrency and currentCurrency set.
    private func actionExchange() {
        guard let safeConverted = converter else {
            presentAlert(text: "Coudln't Access Bank Rates")
            return
        }
        let exchange = safeConverted.convert(fromCurrency: selectedToExchangeCurrency!,
                                               toCurrency: currentCurrency!,
                                                   amount: amountToExchange)
        if exchange.sucess {
            var fromAccount: Account?
            var toAccount: Account?
            var irrelevantAccounts = [Account]()
            
            // Because of complex Core Data relationship we will create copy
            // of all user accounts first.
            let user = coreData?.fetchUser()
            for account in user?.accounts?.allObjects as! [Account] {
                if account.currencyType! == currentCurrency!.rawValue {
                    fromAccount = account
                } else if account.currencyType! == selectedToExchangeCurrency!.rawValue {
                    toAccount = account
                } else {
                    irrelevantAccounts.append(account)
                }
            }
            guard let safeToAccount = toAccount else {
                presentAlert(text: "Exchange Error", message: "Coudln't read destination account.")
                return
            }
            guard let safeFromAccount = fromAccount else {
                presentAlert(text: "Exchange Error", message: "Coudn't access selected user account.")
                return
            }
            // Make sure enough money on balance
            if exchange.amount! > safeFromAccount.balance {
                presentAlert(text: "Not Enough Funds")
                return
            }
            // Dedact money from current.
            safeFromAccount.balance -= exchange.amount!
            // Add money to new account.
            safeToAccount.balance += amountToExchange
            let updatedAccounts = NSMutableSet(array: [safeToAccount, safeFromAccount])
            updatedAccounts.addObjects(from: irrelevantAccounts)
            user?.accounts = NSSet(set: updatedAccounts)
            displayUserBalance()
            coreData?.saveContext()
            presentAlert(text: "Exchange Succeeded")
        } else {
            presentAlert(text: "Exchange Failed", message: exchange.error)
        }
    }
    
    private func presentAlert(text: String, message: String? = nil) {
        let alert = UIAlertController(title: text, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func displayUserBalance() {
        let user = coreData?.fetchUser()
        if user == nil {
            // User not found. Handle error.
            return
        }
        
        for account in user!.accounts!.allObjects as! [Account] {
            let balance = String(format: "%.2f", account.balance)
            switch account.currencyType! {
                case CurrencyType.usd.rawValue:
                    carouselViewController?.leftLabel.text = "\(CurrencyType.usd.symbol())\(balance)"
                case CurrencyType.eur.rawValue:
                    carouselViewController?.rightLabel.text = "\(CurrencyType.eur.symbol())\(balance)"
                case CurrencyType.gbp.rawValue:
                    carouselViewController?.mainLabel.text = "\(CurrencyType.gbp.symbol())\(balance)"
                default:
                    break
            }
        }
        
        // By default currency in the middle selected, which is first in the array
        self.setExchangeCurrency(fromCurrencyIndex: 0, toCurrencyIndex: nil, amount: nil)
    }
    
    private func switchToEditingMode(isEditing: Bool) {
        if isEditing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissKeyboard))
            
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.actionRefresh))
            amountPlusTextField.resignFirstResponder()
            exchangeButton.isEnabled = false
        }
    }
    
    @objc
    private func dismissKeyboard() {
        switchToEditingMode(isEditing: false)
    }
    
    private func updateExchangeRatesRegularly() {
        timer = Timer.scheduledTimer(withTimeInterval: ViewModel.ratesPollUpdateInterval, repeats: true, block: { (timer) in
            self.actionRefresh()
        })
        timer!.fire()
    }

}


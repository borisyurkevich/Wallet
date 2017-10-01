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
    }
}

final class ViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var exchangeButton: UIBarButtonItem!
    @IBAction func tapRefresh(_ sender: Any) {
        actionRefresh()
    }
    @IBAction func tapExchange(_ sender: Any) {
        actionExchange()
    }
    @IBAction func tapSegementedControl(_ sender: UISegmentedControl) {
        setExchangeCurrency(fromCurrencyIndex: nil, toCurrencyIndex: sender.selectedSegmentIndex, amount: nil)
    }
    @IBAction func textFieldEditingChange(_ sender: Any) {
        if let text = textField.text {
            setExchangeCurrency(fromCurrencyIndex: nil, toCurrencyIndex: nil, amount: Double(text))
        }
    }
    
    private let service = EuropeanCentralBankService()
    private let parser = Parser()
    private var coreData: PersistanceModel? = nil
    private var user: User?
    private var carouselViewController: CarouselViewController?
    private var currentCurrency: CurrencyType? = nil
    private var selectedToExchangeCurrency: CurrencyType? = nil
    private var amountToExchange: Double = 0.0
    private var converter: Converter?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "carousel" {
            carouselViewController = segue.destination as? CarouselViewController
            carouselViewController?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreData = PersistanceModel()
        user = coreData?.fetchUser()
        displayUserBalance()
        textField.delegate = self
        setupSegmentedControl()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        for (index, currency) in ViewModel.currences.enumerated() {
            segmentedControl.insertSegment(withTitle: currency.rawValue, at: index, animated: false)
        }
    }
    
    @objc
    private func actionRefresh() {
        let isDataValid = parser.parse(url: service.api.url!)
        if isDataValid {
            converter = Converter(rates: parser.currencies)
        } else {
            print("XML Parser Error: \(parser.parsingError!)")
        }
    }
    
    /// Set one of 3 properties required for exchange. This method validates
    /// all 3 properties and toggles Exchange button enabled state.
    private func setExchangeCurrency(fromCurrencyIndex: Int?, toCurrencyIndex: Int?, amount: Double?) {
        if let to = toCurrencyIndex {
            currentCurrency = ViewModel.currences[to]
        }
        if let from = fromCurrencyIndex {
            selectedToExchangeCurrency = ViewModel.userAccounts[from]
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
            print("converter not found")
            return
        }
        let exchange = safeConverted.convert(fromCurrency: currentCurrency!,
                                            toCurrency: selectedToExchangeCurrency!,
                                                amount: amountToExchange)
        if exchange.sucess {
            var fromAccount: Account?
            var toAccount: Account?
            var irrelevantAccounts = [Account]()
            
            // Because of complex Core Data relationship we will create copy
            // of all user accounts first.
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
                return
            }
            guard let safeFromAccount = fromAccount else {
                return
            }
            // Dedact money from current.
            safeToAccount.balance -= exchange.amount!
            // Add money to new account.
            safeFromAccount.balance += amountToExchange
            let updatedAccounts = NSMutableSet(array: [safeToAccount, safeFromAccount])
            updatedAccounts.addObjects(from: irrelevantAccounts)
            user?.accounts = NSSet(set: updatedAccounts)
            displayUserBalance()
            presentSuccessAlert()
        }
    }
    
    private func presentSuccessAlert() {
        let title = "Exchange Succeeded"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func displayUserBalance() {
        if user == nil {
            // User not found. Handle error.
            return
        }
        
        for account in user!.accounts!.allObjects as! [Account] {
            switch account.currencyType! {
                case CurrencyType.usd.rawValue:
                    carouselViewController?.leftLabel.text = "\(CurrencyType.usd.symbol())\(account.balance)"
                case CurrencyType.eur.rawValue:
                    carouselViewController?.rightLabel.text = "\(CurrencyType.eur.symbol())\(account.balance)"
                case CurrencyType.gbp.rawValue:
                    carouselViewController?.mainLabel.text = "\(CurrencyType.gbp.symbol())\(account.balance)"
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
            textField.resignFirstResponder()
            exchangeButton.isEnabled = false
        }
    }
    
    @objc
    private func dismissKeyboard() {
        switchToEditingMode(isEditing: false)
    }


}


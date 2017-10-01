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
        setExchangeCurrency(fromCurrencyIndex: newState.rawValue, toCurrencyIndex: nil)
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
        setExchangeCurrency(fromCurrencyIndex: nil, toCurrencyIndex: sender.selectedSegmentIndex)
    }
    
    private let service = EuropeanCentralBankService()
    private let parser = Parser()
    private var coreData: PersistanceModel? = nil
    private var user: User?
    private var carouselViewController: CarouselViewController?
    private var excangeCurrency: CurrencyType? = nil
    private var selectedCurrency: CurrencyType? = nil
    
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
            print("success")
        } else {
            print("XML Parser Error: \(parser.parsingError!)")
        }
    }
    
    private func setExchangeCurrency(fromCurrencyIndex: Int?, toCurrencyIndex: Int?) {
        if let to = toCurrencyIndex {
            excangeCurrency = ViewModel.currences[to]
        }
        if let from = fromCurrencyIndex {
            selectedCurrency = ViewModel.userAccounts[from]
        }
        // It should not be possible to exchange to the same currency.
        exchangeButton.isEnabled = excangeCurrency != selectedCurrency
    }
    
    private func actionExchange() {
        
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
        self.setExchangeCurrency(fromCurrencyIndex: 0, toCurrencyIndex: nil)
    }
    
    private func switchToEditingMode(isEditing: Bool) {
        if isEditing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissKeyboard))
            exchangeButton.isEnabled = true
            
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


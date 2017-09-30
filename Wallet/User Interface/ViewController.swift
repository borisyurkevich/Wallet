//
//  ViewController.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBAction func tapRefresh(_ sender: Any) {
        actionRefresh()
    }
    
    private let service = EuropeanCentralBankService()
    private let parser = Parser()
    private var coreData: PersistanceModel? = nil
    private var user: User?
    private var carouselViewController: CarouselViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "carousel" {
            carouselViewController = segue.destination as? CarouselViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreData = PersistanceModel()
        user = coreData?.fetchUser()
        if user != nil {
            displayUserBalance()
        } else {
            print("user not found")
        }
    }
    
    private func actionRefresh() {
        let isDataValid = parser.parse(url: service.api.url!)
        if isDataValid {
            print("success")
        } else {
            print("XML Parser Error: \(parser.parsingError!)")
        }
    }
    
    private func displayUserBalance() {
        for account in user!.accounts!.allObjects as! [Account] {
            switch account.currencyType! {
                case CurrencyType.usd.rawValue:
                    carouselViewController?.leftLabel.text = "$\(account.balance)"
                case CurrencyType.eur.rawValue:
                    carouselViewController?.rightLabel.text = "€\(account.balance)"
                case CurrencyType.gbp.rawValue:
                    carouselViewController?.mainLabel.text = "£\(account.balance)"
                default:
                    break
            }
        }
        
    }


}


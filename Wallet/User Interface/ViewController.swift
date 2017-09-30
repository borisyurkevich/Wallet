//
//  ViewController.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    private let service = EuropeanCentralBankService()
    private let parser = Parser()
    
    @IBAction func tapRefresh(_ sender: Any) {
        actionRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func actionRefresh() {
        let isDataValid = parser.parse(url: service.api.url!)
        if isDataValid {
            print("success")
        } else {
            print("XML Parser Error: \(parser.parsingError!)")
        }
    }


}


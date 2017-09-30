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
        let isSuccess = parser.parse(url: service.api.url!)
        if isSuccess {
            print("success")
        } else {
            print("Parser Error: \(parser.parsingError!)")
        }
        
//        service.request(url: service.api.url) { (success, error, data) in
//            if success {
//                let parsingSuccess = self.parser.parse(data: data!)
//                if parsingSuccess {
//                    print("Success on parsing")
//                } else {
//                    // Handle parsign error
//                    print("Parsign error: \(self.parser.parsingError!)")
//                }
//
//            } else {
//                // Handle download error
//            }
//        }
    }


}


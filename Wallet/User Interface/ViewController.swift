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
    var coreData: PersistanceModel? = nil
    var user: User?
    
    @IBAction func tapRefresh(_ sender: Any) {
        actionRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreData = PersistanceModel()
        user = coreData?.fetchUser()
        if user != nil {
            print("user found")
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


}


//
//  EuropeanCentralBankService.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import Foundation

/// Loads URL for API from info.plist
struct EuropeanCentralBankService {
    
    let api: API
    
    init() {
        let infoDic = Bundle.main.infoDictionary
        guard let url = infoDic?["url"] else {
            fatalError("Please add url to the Info.plist")
        }
        guard let safeURL = url as? String else {
            fatalError("Something wrong with url value")
        }
        api = API(path: safeURL)
    }
}

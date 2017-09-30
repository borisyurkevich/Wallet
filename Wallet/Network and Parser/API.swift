//
//  EuropeanCentralBankAPI.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import Foundation

struct API {
    
    let url: URL?
    
    init(path: String) {
        url = URL(string: path)
    }
}

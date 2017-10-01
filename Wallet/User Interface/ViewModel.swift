//
//  Model.swift
//  Wallet
//
//  Created by Boris Yurkevich on 01/10/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

//  This class separates buiseness logic from UI.
struct ViewModel {
    
    // Set currencies in the carousel. Default is preselected it is first in the list.
    static let userAccounts: [CurrencyType] = [.gbp, .usd, .eur]
    
    // Set amount of availble currencies in segmented control
    static let currences: [CurrencyType] = [.usd, .gbp, .eur]
}

//
//  Converter.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import Foundation

struct Converter {
    
    private var rates: [Currency]
    
    init(rates: [Currency]) {
        self.rates = rates
    }
    
    func convert(fromCurrency: CurrencyType,
                 toCurrency: CurrencyType,
                 amount: Double) -> (sucess: Bool, error: String?, amount: Double?) {
        
        var euroRateRelativeToGivenCurrency: Double? = nil
        var rateFromEuroToNeededCurrency: Double? = nil
        for rate in rates {
            if rate.type == fromCurrency {
                euroRateRelativeToGivenCurrency = rate.valueInEuro
            } else if rate.type == toCurrency {
                rateFromEuroToNeededCurrency = rate.valueInEuro
            }
        }
        if euroRateRelativeToGivenCurrency == nil {
            return (false, "Couldn't find EUR rate to \(fromCurrency.rawValue)", nil)
        }
        if rateFromEuroToNeededCurrency == nil {
            return (false, "Couldn't find EUR rate to \(toCurrency.rawValue)", nil)
        }
        
        // Because our rates are relative to € we need to convert to € first.
        let inEuro = amount / euroRateRelativeToGivenCurrency!
        let result = inEuro * rateFromEuroToNeededCurrency!
        return (true, nil, result)
    }
}

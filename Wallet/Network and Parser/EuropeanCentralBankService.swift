//
//  EuropeanCentralBankService.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import Foundation

struct EuropeanCentralBankService: NetworkService {
    
    let api = API(path: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")
    
    func extractCurrencies(data: Data) -> (isSuccess: Bool,
                                           error: String?,
                                           result: [Currency]?) {
        let parser = Parser()
        let result = parser.parse(data: data)
        return (result, parser.parsingError, parser.currencies)
    }
}

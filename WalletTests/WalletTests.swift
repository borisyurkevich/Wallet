//
//  WalletTests.swift
//  WalletTests
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import XCTest
@testable import Wallet

class WalletTests: XCTestCase {
    
    // "all" property should return correct count of currencies.
    func testCurrencyDefinitions() {
        XCTAssert(CurrencyType.all.count == kTotalCurrencies)
    }
    
    func testAPI() {
        let parser = Parser()
        let service = EuropeanCentralBankService()
        let isDataValid = parser.parse(url: service.api.url!)
        if isDataValid {
            XCTAssert(true)
        } else {
            XCTFail("XML Parser Error: \(parser.parsingError!)")
        }
    }
    
    func testCurrencyConverter() {
        let parser = Parser()
        let service = EuropeanCentralBankService()
        _ = parser.parse(url: service.api.url!)
        let converter = Converter(rates: parser.currencies)
        
        // Convert 10 GBP to USD
        let result = converter.convert(fromCurrency: .gbp, toCurrency: .usd, amount: 10.0)
        XCTAssert(result.sucess)
        XCTAssert(result.amount != nil)
        print("💵 Converted 10 GBP to USD, Result is \(result.amount!)")
    }
    
}

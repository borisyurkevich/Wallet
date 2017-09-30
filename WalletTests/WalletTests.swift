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
    
}

//
//  Currency.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import Foundation

// Udpate this constant when modifying CurrencyType.
let kTotalCurrencies = 31

enum CurrencyType: String {
    case usd = "USD"
    case jpy = "JPY"
    case bgn = "BGN"
    case czk = "CZK"
    case dkk = "DKK"
    case gbp = "GBP"
    case huf = "HUF"
    case pln = "PLN"
    case ron = "RON"
    case sek = "SEK"
    case chf = "CHF"
    case nok = "NOK"
    case hrk = "HRK"
    case rub = "RUB"
    case turkishLira = "TRY"
    case aud = "AUD"
    case brl = "BRL"
    case cad = "CAD"
    case cny = "CNY"
    case hkd = "HKD"
    case idr = "IDR"
    case ils = "ILS"
    case inr = "INR"
    case krw = "KRW"
    case mxn = "MXN"
    case myr = "MYR"
    case nzd = "NZD"
    case php = "PHP"
    case sgd = "SGD"
    case thb = "THB"
    case zar = "ZAR"
    
    static let all = [usd, jpy, bgn, czk, dkk, gbp, huf, pln, ron, sek, chf, nok, hrk, rub, turkishLira, aud, brl, cad, cny, hkd, idr, ils, inr, krw, mxn, myr, nzd, php, sgd, thb, zar]
}

struct Currency {
    let type: CurrencyType
    let valueInEuro: Double
}

//
//  Parser.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import Foundation

extension Parser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "Cube" {
            guard let currencyCode = attributeDict["currency"] else {
                // Empty node, we probably okay as parent node is empty.
                return
            }
            guard let currencyValue = attributeDict["rate"] else {
                parsingError = "Missing currency value for \(currencyCode)"
                return
            }
            guard let curencyType = CurrencyType(rawValue: currencyCode) else {
                parsingError = "Unknown currency code \(currencyCode)"
                return
            }
            guard let rate = Double(currencyValue) else {
                parsingError = "Value of currency \(currencyCode) is not a number"
                return
            }
            let newCurrency = Currency(type: curencyType, valueInEuro: rate)
            self.currencies.append(newCurrency)
        }
        
    }
}

final class Parser: NSObject {
    
    var currencies = [Currency]()
    var parsingError: String?
    
    func parse(url: URL) -> Bool {
        guard let xmlParser = XMLParser(contentsOf: url) else {
            parsingError = "Coudn't create XMLParser."
            return false
        }
        xmlParser.delegate = self
        xmlParser.parse()
        return parsingError == nil
    }
    
    func parse(data: Data) -> Bool {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        xmlParser.parse()
        return parsingError == nil
    }
}

//
//  Subscription.swift
//  StockViewer
//
//  Created by Алексей Киселев on 29/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation

enum StockSymbol: String, CustomStringConvertible {
    
    case EURUSD, EURGBP, USDJPY, GBPUSD, USDCHF, USDCAD, AUDUSD, EURJPY, EURCHF
    
    var description: String {
        // EUR/USD
        let str: String = rawValue
        let separatorIndex = str.index(str.startIndex, offsetBy:Int(str.characters.count/2))
        return "\(str.substring(to: separatorIndex))/\(str.substring(from: separatorIndex))"
    }
    
    static func all() -> [StockSymbol] {
        return [.EURUSD, .EURGBP, .USDJPY, .GBPUSD, .USDCHF, .USDCAD, .AUDUSD, .EURJPY, .EURCHF]
    }
}

struct Constants {
    static let webSocketUrlString = "wss://quotes.exness.com:18400/"
    static let initialStockSymbol: StockSymbol = .EURUSD
}

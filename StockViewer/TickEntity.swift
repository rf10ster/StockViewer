//
//  TickEntity.swift
//  StockViewer
//
//  Created by Алексей Киселев on 29/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import RealmSwift

class TickEntity: Object {
    dynamic var spread: Double = 0
    dynamic var ask: Double = 0
    dynamic var bid: Double = 0
    dynamic var date: Date = Date()
    dynamic var symbol: SymbolEntity?
    
    override static func primaryKey() -> String? {
        return "date"
    }
}

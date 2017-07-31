//
//  SymbolEntity.swift
//  StockViewer
//
//  Created by Алексей Киселев on 29/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import RealmSwift

class SymbolEntity: Object {
    dynamic var name: String = Constants.initialStockSymbol.rawValue
    dynamic var order: Int = 0
    dynamic var isActive: Bool = false
    let ticks = LinkingObjects(fromType: TickEntity.self, property: "symbol")
    
    // denormalization of db
    dynamic var lastSpread: Double = 0
    dynamic var lastAsk: Double = 0
    dynamic var lastBid: Double = 0
    
    // prepare new object - if add to DB it will be updated based on primaryKey
    func makeNewCopy() -> SymbolEntity {
        let entity = self
        let newEntity = SymbolEntity()
        newEntity.name = entity.name
        newEntity.order = entity.order
        newEntity.isActive = entity.isActive
//        ticks = entity.ticks
        newEntity.lastSpread = entity.lastSpread
        newEntity.lastAsk = entity.lastAsk
        newEntity.lastBid = entity.lastBid
        return newEntity
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
    override static func indexedProperties() -> [String] {
        return ["order"]
    }
}


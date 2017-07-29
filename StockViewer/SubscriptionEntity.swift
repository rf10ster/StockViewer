//
//  SubscriptionEntity.swift
//  StockViewer
//
//  Created by Алексей Киселев on 29/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import RealmSwift

class StockSubscriptionEntity: Object {
    dynamic var name: String = Constants.initialSubscription.rawValue
    dynamic var order: Int = 0
    let ticks = List<TickEntity>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
    override static func indexedProperties() -> [String] {
        return ["order"]
    }
}


//
//  DataManager.swift
//  StockViewer
//
//  Created by Алексей Киселев on 29/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

enum StockViewerError: Error {
    case databaseError(error: Error?)
    case connectionError(error: Error?)
    case jsonError
}

enum ResultType {
    case success
    case failure(error: Error)
}

protocol DataManagerDelegage: NSObjectProtocol {
    func dataManagerDidUpdated(result: ResultType)
}

class DataManager<T: Object>: NSObject {
    
    fileprivate let networkServive = NetworkService.shared
    fileprivate var realmToken: NotificationToken? = nil
    fileprivate let realm = try! Realm()
    
    weak var delegate: DataManagerDelegage? {
        didSet {
            startUpdates()
        }
    }
    
    override init() {
        super.init()
        networkServive.addObserver(self)
        realmToken = realm.addNotificationBlock { [weak self] notification, realm in
            self?.delegate?.dataManagerDidUpdated(result: ResultType.success)
        }
    }
    
    deinit {
        realmToken?.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    func fetchData(sortKey: String, filterPredicate: NSPredicate?) -> Results<T> {
        let resultEntities = realm.objects(T.self).sorted(byKeyPath: sortKey)

        if let predicate = filterPredicate {
            return resultEntities.filter(predicate)
        } else {
            return resultEntities
        }
    }
    
    func startUpdates() {
        
        let subscriprions = activeSubscriprions(realm: realm)
        networkServive.connect(with: subscriprions) { [weak self] (success) in
            guard success else {
                let result = ResultType.failure(error: StockViewerError.connectionError(error: nil))
                self?.delegate?.dataManagerDidUpdated(result: result)
                return
            }
            print("connected to network service")
        }
    }
    
    // ugly method - it seems that as entry here should be new objects with implemented primaryKey
    func update(entities: [T]) {
        try! realm.write {
            for entity in entities {
                realm.add(entity, update: true)
            }
        }
    }
    
    func changeActiveSubscriptions(symbol: StockSymbol, isActive: Bool) {
        if isActive {
            networkServive.subscribe(to: [symbol])
        } else {
            networkServive.unsubscribe(from: [symbol])
        }
    }
    
    private func activeSubscriprions(realm: Realm) -> [StockSymbol] {
        
        // check if need to fill database
        if realm.objects(SymbolEntity.self).isEmpty {
            initializeSubscriprions(realm: realm, activeSubscriprion: Constants.initialStockSymbol)
        }
        //do i need - realm.refresh() invalidate() ?
        return realm.objects(SymbolEntity.self).filter(NSPredicate(format: "isActive == true")).flatMap { StockSymbol(rawValue: $0.name) }
    }
    
    private func initializeSubscriprions(realm: Realm, activeSubscriprion: StockSymbol) {
        try! realm.write {
            for (index, stockSubscription) in StockSymbol.all().enumerated() {
                let entity = SymbolEntity()
                entity.isActive = (stockSubscription == activeSubscriprion)
                entity.name = stockSubscription.rawValue
                entity.order = index
                realm.add(entity)
            }
        }
    }
    
}

extension DataManager: NetworkServiceObserverDelegage {
    func networkServiceDidReceiveData(message: String) {
        var isSubscriptionResponse = false
        var jsonTicks: JSON? = nil
        if let dataFromString = message.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            
            if json["subscribed_list"]["ticks"].exists() {
                isSubscriptionResponse = true
                jsonTicks = json["subscribed_list"]["ticks"]
            }else if json["ticks"].exists() {
                jsonTicks = json["ticks"]
            }
        }
        guard let ticks = jsonTicks?.array, !ticks.isEmpty else {
            delegate?.dataManagerDidUpdated(result: ResultType.failure(error: StockViewerError.jsonError))
            return
        }
        
        try! realm.write {
            if isSubscriptionResponse {
                // switch off all current symbols - they will be maden as active by response
                for symbol in realm.objects(SymbolEntity.self) {
                    if symbol.isActive {
                        symbol.isActive = false
                    }
                }
            }
            
            for tickJson in ticks {
                let symbol = realm.object(ofType: SymbolEntity.self, forPrimaryKey: tickJson["s"].stringValue)
                if isSubscriptionResponse {
                    symbol?.isActive = true
                }
                let entity = TickEntity()
                //{"ticks":[{"s":"EURGBP","b":"0.79573","bf":0,"a":"0.79587","af":1,"spr":"1.4"}]}
                entity.symbol = symbol
                entity.spread = tickJson["spr"].doubleValue
                entity.ask = tickJson["a"].doubleValue
                entity.bid = tickJson["b"].doubleValue
                entity.date = Date()
                
                // denormalization
                symbol?.lastAsk = entity.ask
                symbol?.lastBid = entity.bid
                symbol?.lastSpread = entity.spread
                
                realm.add(entity)
            }
        }
        

    }
    func networkServiceDidDisconnect(error: Error?) {
        let result = ResultType.failure(error: StockViewerError.connectionError(error: error))
        delegate?.dataManagerDidUpdated(result: result)
    }
}

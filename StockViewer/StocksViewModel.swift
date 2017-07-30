//
//  StocksViewModel.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/27/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import RealmSwift

protocol StocksViewModelDelegate: NSObjectProtocol {
    func stocksViewModelFetchingData()
    func stocksViewModelGotData(result: ResultType)
}

class StocksViewModel: NSObject {
    
    fileprivate(set) var items: Results<SymbolEntity>?
    
    weak var delegate: StocksViewModelDelegate?
    
    fileprivate let dataManager = DataManager<SymbolEntity>()
    
    override init() {
        super.init()
        dataManager.delegate = self
    }
    
    func fetchData() {
        delegate?.stocksViewModelFetchingData()
        items = dataManager.fetchData(sortKey: "order", filterPredicate: NSPredicate(format: "isActive == true"))
        if let items = self.items, !items.isEmpty {
            self.delegate?.stocksViewModelGotData(result: ResultType.success)
        }
    }
    
    func reconnect() {
        delegate?.stocksViewModelFetchingData()
        dataManager.startUpdates()
    }
    
}

extension StocksViewModel: DataManagerDelegage {
    func dataManagerDidUpdated(result: ResultType) {
        self.delegate?.stocksViewModelGotData(result: result)
    }
}

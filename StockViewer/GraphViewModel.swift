//
//  GraphViewModel.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/31/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import RealmSwift

protocol GraphViewModelDelegate: NSObjectProtocol {
    func graphViewModelFetchingData()
    func graphViewModelGotData(result: ResultType)
}

class GraphViewModel: NSObject {
    
    fileprivate(set) var items: Results<TickEntity>?
    
    weak var delegate: GraphViewModelDelegate?
    
    fileprivate let dataManager = DataManager<TickEntity>()
    
    fileprivate let symbol: StockSymbol
    
    fileprivate let filterPredicate: NSPredicate
    
    fileprivate let sortKey = "date"
    
    init(symbol: StockSymbol) {
        self.symbol = symbol
        //can be replaced to Identity comparisons filter("symbol == %@", symbolEntity)
        filterPredicate = NSPredicate(format: "symbol.name = %@", symbol.rawValue)
        super.init()
        dataManager.delegate = self
    }
    
    func fetchData() {
        delegate?.graphViewModelFetchingData()
        
        items = dataManager.fetchData(sortKey: sortKey, filterPredicate: filterPredicate)
        if let items = self.items, !items.isEmpty {
            self.delegate?.graphViewModelGotData(result: ResultType.success)
        }
    }
    
    func reconnect() {
        delegate?.graphViewModelFetchingData()
        dataManager.startUpdates()
    }
    
}

extension GraphViewModel: DataManagerDelegage {
    func dataManagerDidUpdated(result: ResultType) {
        switch result {
        case .success:
            items = dataManager.fetchData(sortKey: sortKey, filterPredicate: filterPredicate)
        default:
            break
        }
        self.delegate?.graphViewModelGotData(result: result)
    }
}

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
    
    func toggleIsActiveOfItem(at index: Int) {
        guard let items = self.items, index > 0 && index < items.count else {
            return
        }
        delegate?.stocksViewModelFetchingData()
        let currentItem = items[index]
        dataManager.changeActiveSubscriptions(symbol: StockSymbol(rawValue: currentItem.name)!, isActive: !currentItem.isActive)
    }
    
    func changePositions(src: Int, dest: Int) {
        guard let items = self.items, items.count > src, items.count > dest else {
            return
        }
        delegate?.stocksViewModelFetchingData()
        var rearrangedItems = [SymbolEntity]()
        for item in items {
            rearrangedItems.append(item.makeNewCopy())
        }
        let element = rearrangedItems.remove(at: src)
        rearrangedItems.insert(element, at: dest)
        for (index, item) in rearrangedItems.enumerated() {
            item.order = index
        }
        dataManager.update(entities: rearrangedItems)
    }
}

extension StocksViewModel: DataManagerDelegage {
    func dataManagerDidUpdated(result: ResultType) {
        switch result {
        case .success:
            // instead of calculation what have been changed - just get new collection
            items = dataManager.fetchData(sortKey: "order", filterPredicate: NSPredicate(format: "isActive == true"))
        default:
            break
        }
        self.delegate?.stocksViewModelGotData(result: result)
    }
}

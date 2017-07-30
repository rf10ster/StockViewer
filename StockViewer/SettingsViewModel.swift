//
//  SettingsViewModel.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/27/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import RealmSwift

protocol SettingsViewModelDelegate: NSObjectProtocol {
    func settingsViewModelFetchingData()
    func settingsViewModelGotData(result: ResultType)
}

class SettingsViewModel: NSObject {
    
    fileprivate(set) var items: Results<SymbolEntity>?
    
    weak var delegate: SettingsViewModelDelegate?
    
    fileprivate let dataManager = DataManager<SymbolEntity>()
    
    override init() {
        super.init()
        dataManager.delegate = self
    }
    
    func fetchData() {
        delegate?.settingsViewModelFetchingData()
        items = dataManager.fetchData(sortKey: "order", filterPredicate: nil)
        if let items = self.items, !items.isEmpty {
            self.delegate?.settingsViewModelGotData(result: ResultType.success)
        }
    }
    
    func reconnect() {
        delegate?.settingsViewModelFetchingData()
        dataManager.startUpdates()
    }
    
    func toggleSelectionOfItem(at index: Int) {
        guard let items = self.items, index > 0 && index < items.count else {
            return
        }
        let currentItem = items[index]
        dataManager.changeActiveSubscriptions(symbol: StockSymbol(rawValue: currentItem.name)!, isActive: !currentItem.isActive)
        delegate?.settingsViewModelFetchingData()
    }
    
}

extension SettingsViewModel: DataManagerDelegage {
    func dataManagerDidUpdated(result: ResultType) {
        self.delegate?.settingsViewModelGotData(result: result)
    }
}

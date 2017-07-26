//
//  SettingsViewModel.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/27/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation

protocol SettingsViewModelDelegate: NSObjectProtocol {
    func settingsViewModelFetchingData()
    func settingsViewModelGotData()
}

class SettingsViewModel {
    
    fileprivate(set) var items: [SettingsItemViewModel]
    
    weak var delegate: SettingsViewModelDelegate?
    
    init() {
        items = [SettingsItemViewModel(title: "EUR/USD", isChecked: true), SettingsItemViewModel(title: "USD/RUB", isChecked: false)]
    }
    
    func fetchData() {
        delegate?.settingsViewModelFetchingData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.delegate?.settingsViewModelGotData()
        }
    }
    
    func toggleSelectionOfItem(at index: Int) {
        guard (0..<items.count).contains(index) else {
            return
        }
        
        delegate?.settingsViewModelFetchingData()
        
        let item = items[index]
        items[index] = SettingsItemViewModel(title: item.title, isChecked: !item.isChecked)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.delegate?.settingsViewModelGotData()
        }
    }
}

//
//  SettingsItemViewModel.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/27/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation

struct SettingsItemViewModel {
    
    let isChecked: Bool
    
    let title: String
    
    init(title: String, isChecked: Bool) {
        self.title = title
        self.isChecked = isChecked
    }
    
}

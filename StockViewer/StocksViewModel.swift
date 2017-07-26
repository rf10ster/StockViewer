//
//  StocksViewModel.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/27/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation

protocol StocksViewModelDelegate: NSObjectProtocol {
    func stocksViewModelFetchingData()
    func stocksViewModelGotData()
}

class StocksViewModel {
    
    fileprivate(set) var items: [Any]
    
    weak var delegate: StocksViewModelDelegate?
    
    init() {
        items = ["NA"]
    }
    
    func fetchData() {
        delegate?.stocksViewModelFetchingData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.delegate?.stocksViewModelGotData()
        }
    }
    
}

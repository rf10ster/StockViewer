//
//  DataManager.swift
//  StockViewer
//
//  Created by Алексей Киселев on 29/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation

protocol DataManagerDelegage: NSObjectProtocol {
    func serviceDidChangeContent()
}

class DataManager {
    
    fileprivate let networkServive = NetworkService.shared
    
    weak var delegate: DataManagerDelegage?
    
    init() {
        networkServive.addDelegate(delegate: self)
    }
    
    func fetchData(with subscriprions: [StockSubscription]) {
        //networkServive.connect(with subscriprions: [StockSubscription])
    }
    
    
}

extension DataManager: NetworkServiceObserverDelegage {
    func networkServiceDidReceiveData(text: String) {
        
    }
    func networkServiceDidConnect() {
        
    }
    func networkServiceDidDisconnect(error: Error?) {
        
    }
}

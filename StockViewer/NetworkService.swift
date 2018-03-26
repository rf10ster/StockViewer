//
//  NetworkService.swift
//  StockViewer
//
//  Created by Алексей Киселев on 29/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import Starscream

protocol NetworkServiceObserverDelegage: NSObjectProtocol {
    func networkServiceDidReceiveData(message: String)
    func networkServiceDidDisconnect(error: Error?)
}

class NetworkService {
    
    static let shared = NetworkService()
    fileprivate let serviceObservers = NSHashTable<AnyObject>(options: [.weakMemory])
    
    fileprivate var socket: WebSocket?
    
    deinit {
        disconnect()
    }
    
    func connect(with symbols: [StockSymbol], completion: ((_ success: Bool)->())? ) {
        // if connected or connecting
        if let socket = self.socket {
            if socket.isConnected {
                subscribe(to: symbols)
                completion?(true)
                return
            }
            print("socket is not finished previous connection request")
            return
        }
        disconnect()
        let socket = WebSocket(url: URL(string: Constants.webSocketUrlString)!)
        // WebSocketDelegate socket.delegate = self
        socket.onConnect = { [weak self] _ in
            self?.subscribe(to: symbols)
        }
        socket.onDisconnect = { [weak self] (error: Error?) in
            self?.disconnect()
            self?.serviceObservers.allObjects.forEach { ($0 as? NetworkServiceObserverDelegage)?.networkServiceDidDisconnect(error: error) }
        }
        socket.onText = { [weak self] (text: String) in
            print("network response: \(text)")
            self?.serviceObservers.allObjects.forEach { ($0 as? NetworkServiceObserverDelegage)?.networkServiceDidReceiveData(message: text) }
        }
        socket.connect()
        self.socket = socket
    }
    func disconnect() {
        socket?.disconnect()
        socket = nil
    }
    
    func addObserver(_ observer: NetworkServiceObserverDelegage) {
        if !serviceObservers.contains(observer) {
            serviceObservers.add(observer)
        }
    }
    
    func subscribe(to symbols: [StockSymbol]) {
        guard let socket = self.socket, socket.isConnected, !symbols.isEmpty else {
            return
        }
        let subscriprionsParam = symbols.flatMap{ $0.rawValue }.joined(separator: ",")
        socket.write(string: "SUBSCRIBE: \(subscriprionsParam)")
    }
    
    func unsubscribe(from symbols: [StockSymbol]) {
        guard let socket = self.socket, socket.isConnected, !symbols.isEmpty else {
            return
        }
        let subscriprionsParam = symbols.flatMap{ $0.rawValue }.joined(separator: ",")
        socket.write(string: "UNSUBSCRIBE: \(subscriprionsParam)")
    }
}

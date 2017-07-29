//
//  NetworkService.swift
//  StockViewer
//
//  Created by Алексей Киселев on 29/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import Foundation
import Starscream

@objc protocol NetworkServiceObserverDelegage {
    func networkServiceDidReceiveData(text: String)
    func networkServiceDidConnect()
    func networkServiceDidDisconnect(error: Error?)
}

enum NetworkServiceError: Error {
    case unknownError(error: Error?)
    case connectionError
    case invalidRequest
}

class NetworkService {
    
    static let shared = NetworkService()
    fileprivate let serviceObservers = NSHashTable<NetworkServiceObserverDelegage>(options: [.weakMemory])
    
    fileprivate var socket: WebSocket?
    
    var isConnected: Bool { return socket?.isConnected ?? false }
    
    private init() {
        connect()
    }
    deinit {
        disconnect()
    }
    
    func reconnect() {
        disconnect()
        // not sure if i need to wait for disconnection
        connect()
    }
    private func connect() {
        let socket = WebSocket(url: URL(string: Constants.webSocketUrlString)!)
        socket.delegate = self
        socket.connect()
        self.socket = socket
    }
    private func disconnect() {
        socket?.disconnect()
        socket = nil
    }
    
    func addDelegate(delegate: NetworkServiceObserverDelegage) {
        if !serviceObservers.contains(delegate) {
            serviceObservers.add(delegate)
        }
    }
    
    func subscribe(to subscriprions: [StockSubscription]) throws {
        guard let socket = self.socket, socket.isConnected else {
            throw NetworkServiceError.connectionError
        }
        guard !subscriprions.isEmpty else {
            throw NetworkServiceError.invalidRequest
        }
        let subscriprionsParam = subscriprions.flatMap{ $0.rawValue }.reduce("", { $0 + "," + $1 })
        socket.write(string: "SUBSCRIBE: \(subscriprionsParam)")
    }
    
    func unsubscribe(from subscriprions: [StockSubscription]) throws {
        guard let socket = self.socket, socket.isConnected else {
            throw NetworkServiceError.connectionError
        }
        guard !subscriprions.isEmpty else {
            throw NetworkServiceError.invalidRequest
        }
        let subscriprionsParam = subscriprions.flatMap{ $0.rawValue }.reduce("", { $0 + "," + $1 })
        socket.write(string: "UNSUBSCRIBE: \(subscriprionsParam)")
    }
}

extension NetworkService: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        serviceObservers.allObjects.forEach { $0.networkServiceDidConnect() }
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        serviceObservers.allObjects.forEach { $0.networkServiceDidDisconnect(error: error) }
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        serviceObservers.allObjects.forEach { $0.networkServiceDidReceiveData(text: text) }
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count) but listen for text")
    }
}

//
//  NetworkConnectionManager.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/17.
//

import Foundation
import Network

import Foundation
import Network
import RxSwift
import RxRelay

/// 네트워크 연결 여부를 감시하는 싱글톤 매니저
final class NetworkConnectionManager {
    
    static let shared = NetworkConnectionManager()
    
    private let queue = DispatchQueue.global()
    private let connectionMonitor: NWPathMonitor
    
    let isConnectedNetwork: Observable<Bool>
    private let isConnectedNetworkRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    // MARK: - init
    private init () {
        connectionMonitor = NWPathMonitor()
        isConnectedNetwork = isConnectedNetworkRelay
            .share()
            .asObservable()
    }
    
    // MARK: - Implements
    public func startMonitoring() {
        connectionMonitor.start(queue: queue)
        connectionMonitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            guard let self = self,
                  isConnected != self.isConnectedNetworkRelay.value else { return }

            self.isConnectedNetworkRelay.accept(isConnected)
        }
    }
    
    public func stopMonitoring() {
        connectionMonitor.cancel()
    }
}

//
//  Coordinator.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import Foundation

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func didFinishChildCoordinator<T: Coordinator>(_ coordinator: T) {
        guard let index = childCoordinators.firstIndex(where: { $0 === coordinator }) else {
            return
        }
        
        childCoordinators.remove(at: index)
    }
}

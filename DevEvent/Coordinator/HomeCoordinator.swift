//
//  HomeCoordinator.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import UIKit

final class HomeCoordinator: Coordinator {
    private let presenter: UINavigationController
    var homeViewController: HomeViewController?
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let homeVC = HomeViewController.instantiateViewController()
        homeVC.coordinator = self
        presenter.pushViewController(homeVC, animated: false)
    }
    
    func showWebKitViewController(of url:URL) {
        let coordinator: WebKitCoordinator = {
            let coordinator = WebKitCoordinator(presenter: presenter)
            coordinator.parentCoordinator = self
            return coordinator
        }()

        self.childCoordinators.append(coordinator)
        
        let webVC = WebKitViewController.instantiateViewController()
        webVC.url = url
        webVC.coordinator = coordinator
        presenter.pushViewController(webVC, animated: false)
    }
}

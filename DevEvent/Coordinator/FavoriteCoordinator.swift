//
//  FavoriteCoordinator.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/17.
//

import UIKit

final class FavoriteCoordinator: Coordinator {
    private let presenter: UINavigationController
    var favoriteViewController: FavoriteViewController?
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let favoriteVC = FavoriteViewController.instantiateViewController()
        favoriteVC.coordinator = self
        presenter.pushViewController(favoriteVC, animated: false)
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

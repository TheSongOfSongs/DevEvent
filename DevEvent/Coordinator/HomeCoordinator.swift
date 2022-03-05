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
        presenter.pushViewController(homeVC, animated: false)
    }
}

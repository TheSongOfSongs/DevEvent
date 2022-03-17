//
//  InfoCoordinator.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/17.
//

import UIKit

final class InfoCoordinator: Coordinator {
    private let presenter: UINavigationController
    var infoViewController: InfoViewController?
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let infoVC = InfoViewController.instantiateViewController()
        infoVC.coordinator = self
        presenter.pushViewController(infoVC, animated: false)
    }
}

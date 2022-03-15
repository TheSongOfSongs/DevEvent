//
//  WebKitCoordinator.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/07.
//

import UIKit

final class WebKitCoordinator: Coordinator {
    private let presenter: UINavigationController
    var webKitViewController: WebKitViewController?
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let webKitVC = WebKitViewController.instantiateViewController()
        webKitVC.coordinator = self
        presenter.pushViewController(webKitVC, animated: false)
    }
    
    func dismiss() {
        presenter.popViewController(animated: true)
        parentCoordinator?.didFinishChildCoordinator(self)
    }
}

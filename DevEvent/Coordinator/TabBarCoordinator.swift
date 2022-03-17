//
//  TabBarCoordinator.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import UIKit

// MARK: - TabBarPage
enum TabBarPage: Int, CaseIterable {
    case home
    case favorites
    case info
    
    init?(index: Int) {
        switch index {
        case 0:
            self = .home
        case 1:
            self = .favorites
        case 2:
            self = .info
        default:
            return nil
        }
    }
    
    var pageOrderNumber: Int {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .favorites:
            return "즐겨찾기"
        case .info:
            return "앱 정보"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house.fill")
        case .favorites:
            return UIImage(systemName: "star.fill")
        case .info:
            return UIImage(systemName: "info.circle.fill")
        }
    }
}

// MARK: - TabBarCoordinatorType
protocol TabBarCoordinatorType: Coordinator {
    var tabBarController: UITabBarController { get set }
    func selectPage(_ page: TabBarPage)
    func setSelectedIndex(_ index: Int)
    func currentPage() -> TabBarPage?
}


// MARK: - TabBarCoordinator
final class TabBarCoordinator: Coordinator {
    let window: UIWindow
    
    var tabBarController: UITabBarController
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(window: UIWindow) {
        self.window = window
        
        let tabBarController: UITabBarController = {
            let tabBarController = UITabBarController()
            
            // iOS 15버전부터 tabBar divider 보이지 않는 이슈 핸들링
            if #available(iOS 15.0, *) {
                tabBarController.tabBar.scrollEdgeAppearance = UITabBarAppearance()
            }
            return tabBarController
        }()
        
        self.tabBarController = tabBarController
        window.rootViewController = tabBarController
    }
    
    func start() {
        let pages: [TabBarPage] = TabBarPage.allCases
        let controllers = pages.map({ tabController($0) })
        
        tabBarController.setViewControllers(controllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.home.pageOrderNumber
    }
    
    func tabController(_ page: TabBarPage) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.tabBarItem = UITabBarItem(title: page.title,
                                                       image: page.image,
                                                       tag: page.pageOrderNumber)
        
        switch page {
        case .home:
            let homeCoordinator = HomeCoordinator(presenter: navigationController)
            homeCoordinator.parentCoordinator = self
            homeCoordinator.start()
            childCoordinators.append(homeCoordinator)
        case .favorites:
            let favoriteCoordinator = FavoriteCoordinator(presenter: navigationController)
            favoriteCoordinator.parentCoordinator = self
            favoriteCoordinator.start()
            childCoordinators.append(favoriteCoordinator)
        case .info:
            let infoCoordinator = InfoCoordinator(presenter: navigationController)
            infoCoordinator.parentCoordinator = self
            infoCoordinator.start()
            childCoordinators.append(infoCoordinator)
        }
        
        return navigationController
    }
    
    func selectPage(_ page: TabBarPage) {
        tabBarController.selectedIndex = page.pageOrderNumber
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPage.init(index: index) else { return }
        tabBarController.selectedIndex = page.pageOrderNumber
    }
    
    func currentPage() -> TabBarPage? {
        TabBarPage.init(index: tabBarController.selectedIndex)
    }
}

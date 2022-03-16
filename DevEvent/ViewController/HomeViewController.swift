//
//  HomeViewController.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import UIKit
import RxDataSources
import RxGesture
import RxSwift

class HomeViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var tableView: UITableView!
    
    static var defaultFileName: String = "Main"
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let viewModel = HomeViewModel()
    private lazy var input = HomeViewModel.Input()
    private lazy var output = viewModel.transform(input: input)
    
    var coordinator: HomeCoordinator!
    
    var dataSources: RxTableViewSectionedReloadDataSource<SectionOfEvents> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfEvents>(configureCell: { [weak self] _, tableView, indexPath, devEvent in
            guard let cell = tableView
                    .dequeueReusableCell(withIdentifier: DevEventTableViewCell.identifier,
                                         for: indexPath) as? DevEventTableViewCell else {
                        return UITableViewCell()
                    }
            
            self?.setupCell(cell, event: devEvent)
            return cell
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }

        return dataSource
    }
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    // MARK: -
    func setupTableView() {
        let cell = UINib(nibName: DevEventTableViewCell.identifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: DevEventTableViewCell.identifier)
    }
    
    func bindViewModel() {
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        output.dataSources
            .bind(to: tableView.rx.items(dataSource: dataSources))
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.modelSelected(Event.self), tableView.rx.itemSelected)
            .subscribe(onNext: { [weak self] event, _ in
                self?.showWebViewController(of: event)
            })
            .disposed(by: disposeBag)
        
        // TODO: - section header 추가
    }
    
    func showWebViewController(of event: Event) {
        guard let url = event.url else { return }
        coordinator.showWebKitViewController(of: url)
    }
    
    func setupCell(_ cell: DevEventTableViewCell, event: Event) {
        cell.updateWith(event: event)
        
        // TODO: flatMap에 조건식 넣기
        let gestureDisposable: Disposable = {
            if event.isFavorite {
                return cell
                    .rx
                    .longPressGesture()
                    .when(.began)
                    .flatMap({ _ in self.viewModel.removeFavorite(event: event) })
                    .subscribe(onNext: { _ in
                        UIDevice.vibrate()
                        cell.favoriteImageView.isHidden = !cell.favoriteImageView.isHidden
                    })
            } else {
                return cell
                    .rx
                    .longPressGesture()
                    .when(.began)
                    .flatMap({ _ in self.viewModel.addFavorite(event: event) })
                    .subscribe(onNext: { _ in
                        UIDevice.vibrate()
                        cell.favoriteImageView.isHidden = !cell.favoriteImageView.isHidden
                    })
            }
        }()
        
        cell.gestureDisposable.setDisposable(gestureDisposable)
    }
    
    func addFavoriteEvent(_ event: Event) {
        UIDevice.vibrate()
    }
}

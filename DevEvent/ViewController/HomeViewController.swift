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
import RxRelay

class HomeViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    static var defaultFileName: String = "Main"
    
    var disposeBag: DisposeBag = DisposeBag()
    
    
    // MARK: ViewModel
    let viewModel = HomeViewModel()
    private lazy var requestFetchingEvents: PublishSubject<Void> = PublishSubject()
    private lazy var input = HomeViewModel.Input(requestFetchingEvents:
                                                    requestFetchingEvents.asObservable())
    private lazy var output = viewModel.transform(input: input)
    
    var coordinator: HomeCoordinator!
    
    private var refreshControl = UIRefreshControl()
    
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
        // cell 등록
        let cell = UINib(nibName: DevEventTableViewCell.identifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: DevEventTableViewCell.identifier)
        
        // refrehsControl
        refreshControl.addTarget(self, action: #selector(reloadEventsData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func bindViewModel() {
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        let dataSources = output.dataSources
            .share(replay: 1, scope: .whileConnected)
        
        dataSources
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.activityIndicatorView.isHidden = true
                self.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        dataSources
            .bind(to: tableView.rx.items(dataSource: self.dataSources))
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.modelSelected(Event.self), tableView.rx.itemSelected)
            .subscribe(onNext: { [weak self] event, _ in
                self?.showWebViewController(of: event)
            })
            .disposed(by: disposeBag)
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
    
    @objc func reloadEventsData() {
        requestFetchingEvents
            .onNext(())
    }
}

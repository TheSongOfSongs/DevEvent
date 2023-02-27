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
import Toaster

final class HomeViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var networkConnectionLabel: UILabel!
    private var refreshControl = UIRefreshControl()
    
    static var defaultFileName: String = "Main"
    private var isNetworkConnect: Bool = true
    
    var coordinator: HomeCoordinator!
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - ViewModel
    let viewModel = HomeViewModel()
    var requestFetchingEvents: PublishSubject<Void> = PublishSubject()
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
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func bindViewModel() {
        let input = HomeViewModel.Input(requestFetchingEvents: requestFetchingEvents.asObservable())
        let output = viewModel.transform(input: input)
        let dataSources = output
            .dataSources
            .share(replay: 1,
                   scope: .whileConnected)
        
        dataSources
            .observe(on: MainScheduler.instance)
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
        
        output.isNetworkConnect
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isConnected in
                guard let self = self else { return }
                
                self.isNetworkConnect = isConnected
                
                guard !isConnected else {
                    self.reloadEventsData()
                    self.networkConnectionLabel.isHidden = true
                    self.tableView.isHidden = false
                    return
                }
                
                if self.tableView.isEmpty {
                    // 데이터를 로드한 적이 없는 경우
                    self.networkConnectionLabel.isHidden = false
                    self.activityIndicatorView.isHidden = true
                    self.tableView.isHidden = true
                } else {
                    // 데이터를 로드해서 이미 dataSources가 존재하는 경우
                    self.showToast(.checkNetwork)
                }
            })
            .disposed(by: disposeBag)
        
        requestFetchingEvents
            .onNext(())
    }
    
    func showWebViewController(of event: Event) {
        guard isNetworkConnect else {
            self.showToast(.checkNetwork)
            return
        }
        
        guard let url = event.url else { return }
        coordinator.showWebKitViewController(of: url)
    }
    
    func setupCell(_ cell: DevEventTableViewCell, event: Event) {
        cell.updateWith(event: event)
        
        let gestureDisposable: Disposable = {
            var handlingFavorite: Single<Bool> {
                if event.isFavorite {
                    return viewModel.removeFavorite(event: event)
                } else {
                    return viewModel.addFavorite(event: event)
                }
            }
            
            return cell
                .rx
                .longPressGesture()
                .when(.began)
                .flatMap({ _  in handlingFavorite })
                .subscribe(onNext: { _ in
                    UIDevice.vibrate()
                    cell.favoriteImageView.isHidden.toggle()
                })
        }()
        
        
        cell.gestureDisposable.setDisposable(gestureDisposable)
    }
    
    func addFavoriteEvent(_ event: Event) {
        UIDevice.vibrate()
    }
    
    @objc func reloadEventsData() {
        guard isNetworkConnect else {
            refreshControl.endRefreshing()
            return
        }
        
        requestFetchingEvents
            .onNext(())
    }
}

//
//  FavoriteViewController.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/16.
//

import UIKit
import RxDataSources
import RxSwift

class FavoriteViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favoriteGuideLabel: UILabel!
    
    static var defaultFileName: String = "Main"
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let viewModel = FavoriteViewModel()
    private lazy var input = FavoriteViewModel.Input()
    private lazy var output = viewModel.transform(input: input)
    
    var coordinator: FavoriteCoordinator!
    
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
        tableView.delegate = self
    }
    
    func bindViewModel() {
        let dataSources = output
            .dataSources
        
        dataSources
            .subscribe(onNext: { sectionOfEvents in
                let isFavoriteEmpty = sectionOfEvents.flatMap({$0.items}).isEmpty
                self.tableView.isHidden = isFavoriteEmpty
                self.favoriteGuideLabel.isHidden = !isFavoriteEmpty
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
        cell.updateWith(event: event, setFavoriteImageViewHidden: true)
        
        let gestureDisposable = cell.rx
            .longPressGesture()
            .when(.began)
            .flatMap({ _ in self.viewModel.removeFavorite(event: event) })
            .subscribe(onNext: { _ in
                UIDevice.vibrate()
            })
        
        cell.gestureDisposable.setDisposable(gestureDisposable)
    }
}

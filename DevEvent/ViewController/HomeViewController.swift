//
//  HomeViewController.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import UIKit
import RxDataSources
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
        let dataSoucre = RxTableViewSectionedReloadDataSource<SectionOfEvents>(configureCell: { _, tableView, indexPath, devEvent in
            guard let cell = tableView
                    .dequeueReusableCell(withIdentifier: DevEventTableViewCell.identifier,
                                         for: indexPath) as? DevEventTableViewCell else {
                        return UITableViewCell()
                    }
            cell.titleLabel.text = devEvent.name
            cell.hostLabel.text = devEvent.detail?.host
            // TODO: - 즐겨찾기 이미지 처리, long press gesture
            return cell
        })

        return dataSoucre
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
        guard let url = URL(string: event.url) else {
                  return
              }
        coordinator.showWebKitViewController(of: url)
    }
}

//
//  DevEventsFetcher.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation
import RxSwift
import RxRelay

final class DevEventsFetcher {
    
    struct Input {
        var requestFetchingEvents: Observable<Void>?
    }
    
    struct Output {
        var devEvents: Observable<[SectionOfEvents]>
    }
    
    static let shared: DevEventsFetcher = DevEventsFetcher()
    
    let networkService: NetworkService
    let parser: Parser
    let disposeBag = DisposeBag()
    
    private var devEvents = PublishRelay<[SectionOfEvents]>()
    
    private init() {
        self.networkService = NetworkService()
        self.parser = Parser()
        
        fetchDevEvents()
    }
    
    private func fetchDevEvents() {
        networkService.fetchHTML()
            .flatMap({ self.parser.parse(html: $0) })
            .subscribe(
                onSuccess: { [weak self] events in
                    self?.devEvents.accept(events)
                },
                onFailure: { error in
                    
                })
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        input.requestFetchingEvents?
            .subscribe(onNext: { [weak self] _ in
                self?.fetchDevEvents()
            })
            .disposed(by: disposeBag)
        
        let devEvents = devEvents.share()
        return Output(devEvents: devEvents)
    }
}

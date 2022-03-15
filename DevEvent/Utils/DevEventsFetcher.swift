//
//  DevEventsFetcher.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation
import RxSwift
import RxRelay

struct DevEventsFetcher {
    let networkService: NetworkService
    let parser: Parser
    let disposeBag = DisposeBag()
    
    var devEvents = BehaviorRelay<[SectionOfEvents]>(value: [])
    
    init() {
        self.networkService = NetworkService.shared
        self.parser = Parser()
        
        fetchDevEvents()
    }
    
    func fetchDevEvents() {
        networkService.fetchHTML()
            .flatMap({ parser.parse(html: $0) })
            .subscribe(
                onSuccess: { events in
                    devEvents.accept(events)
                },
                onFailure: { error in
                    
                })
            .disposed(by: disposeBag)
    }
}

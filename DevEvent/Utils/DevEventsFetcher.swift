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
        var error: Observable<NetworkServiceError>
    }
    
    static let shared: DevEventsFetcher = DevEventsFetcher()
    
    let networkService: NetworkService
    let parser: Parser
    let disposeBag = DisposeBag()
    
    private var devEvents = PublishRelay<[SectionOfEvents]>()
    private var error = PublishRelay<NetworkServiceError>()
    
    private init() {
        self.networkService = NetworkService()
        self.parser = Parser()
    }
    
    private func fetchDevEvents() async {
        let result = await networkService.fetchHTML()
        
        switch result {
        case .success(let html):
            parser.parse(html: html)
                .subscribe(with: self, onSuccess: { owner, result in
                    owner.devEvents.accept(result)
                }, onFailure: { owner, error in
                    owner.error.accept(.failedParse)
                })
                .disposed(by: disposeBag)
            break
        case .failure(let error):
            self.error.accept(error)
        }
    }
    
    func transform(input: Input) -> Output {
        input.requestFetchingEvents?
            .subscribe(onNext: { _ in
                Task {
                    await self.fetchDevEvents()
                }
            })
            .disposed(by: disposeBag)
        
        return Output(devEvents: devEvents.asObservable(),
                      error: error.asObservable())
    }
}

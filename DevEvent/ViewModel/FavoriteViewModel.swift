//
//  FavoriteViewModel.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/16.
//

import Foundation
import RxSwift
import RxRelay

class FavoriteViewModel: ViewModelType {
    
    struct Input {
        var requestFetchingEvents: Observable<Void>
    }
    
    struct Output {
        var dataSources: Observable<[SectionOfEvents]>
        var isNetworkConnect: Observable<Bool>
    }
    
    private lazy var input = PersistanceManager.Input()
    private lazy var output = PersistanceManager.shared.transform(input: input)
    
    private let eventsFromServer: BehaviorRelay<[SectionOfEvents]> = BehaviorRelay(value: [])
    private let favoriteEvents: BehaviorRelay<[EventCoreData]> = BehaviorRelay(value: [])
    
    let disposeBag = DisposeBag()
    
    init() {
        fetchFavoriteEvents()
    }
    
    private func fetchFavoriteEvents() {
        DevEventsFetcher()
            .devEvents
            .subscribe(onNext: { sectionOfEvents in
                self.eventsFromServer.accept(sectionOfEvents)
            }, onError: { error in
                // TODO: - 에러 핸들링
                print("🍎 error:\(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        PersistanceManager
            .shared
            .transform(input: PersistanceManager.Input())
            .favoriteCoreDataEvents
            .subscribe (onNext: { eventCoreData in
                self.favoriteEvents.accept(eventCoreData)
            }, onError: { error in
                // TODO: - 에러 핸들링
                print("🍎 error:\(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        // Input
        input.requestFetchingEvents
            .subscribe(onNext: { _ in
                self.fetchFavoriteEvents()
            })
            .disposed(by: disposeBag)
        
        // Output
        let relay: BehaviorRelay<[SectionOfEvents]> = BehaviorRelay(value: [])
        
        let dataSources = Observable.combineLatest(eventsFromServer, favoriteEvents)
            .map { eventsFromServer, favoriteEvents -> [SectionOfEvents] in
                var eventsFromServer = eventsFromServer
                for (i, sectionOfEvents) in eventsFromServer.enumerated() {
                    let items = sectionOfEvents.items.filter { event in
                        return favoriteEvents.contains(where: { event.isEqual(to: $0) })
                    }
                    
                    eventsFromServer[i] = SectionOfEvents(header: sectionOfEvents.header,
                                                          items: items)
                }
                
                return eventsFromServer.filter({ !$0.items.isEmpty })
            }
        
        dataSources
            .subscribe(onNext: { result in
                relay.accept(result)
            })
            .disposed(by: disposeBag)
        
        return Output(dataSources: relay.asObservable(),
                      isNetworkConnect: NetworkConnectionManager.shared.isConnectedNetwork)
    }
    
    func removeFavorite(event: Event) -> Single<Bool> {
        return PersistanceManager.shared.removeFavoriteEvent(event)
    }
}

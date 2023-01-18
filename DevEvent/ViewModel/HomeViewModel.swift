//
//  HomeViewModel.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation
import RxSwift
import RxRelay

final class HomeViewModel: ViewModelType {
    
    struct Input {
        var requestFetchingEvents: Observable<Void>
    }
    
    struct Output {
        var dataSources: Observable<[SectionOfEvents]>
        var isNetworkConnect: Observable<Bool>
    }
    
    private lazy var requestFetchingEvents: PublishSubject<Void> = PublishSubject()
    private lazy var devEventsFetcherInput = DevEventsFetcher.Input(requestFetchingEvents: requestFetchingEvents)
    private lazy var devEventsFetcherOutput = DevEventsFetcher.shared.transform(input: devEventsFetcherInput)
    
    private let eventsFromServer = PublishRelay<[SectionOfEvents]>()
    private let favoriteEvents: BehaviorRelay<[EventCoreData]> = BehaviorRelay(value: [])
    
    let disposeBag = DisposeBag()

    // MARK: - init
    init() {
        fetchAllEvents()
    }
    
    // TODO: - refactor
    func transform(input: Input) -> Output {
        input.requestFetchingEvents
            .subscribe(onNext: { _ in
                self.requestFetchingEvents
                    .onNext(())
            })
            .disposed(by: disposeBag)
        
        let dataSources = Observable.combineLatest(eventsFromServer, favoriteEvents)
            .map { eventsFromServer, favoriteEvents -> [SectionOfEvents] in
                var eventsFromServer = eventsFromServer
                for (i, sectionOfEvents) in eventsFromServer.enumerated() {
                    var items = sectionOfEvents.items
                    
                    for(j, event) in items.enumerated() {
                        items[j].isFavorite = favoriteEvents.contains(where: { event.isEqual(to: $0) })
                    }
                    
                    eventsFromServer[i] = SectionOfEvents(header: sectionOfEvents.header,
                                                          items: items)
                }
                
                return eventsFromServer
            }
        
        return Output(dataSources: dataSources,
                      isNetworkConnect: NetworkConnectionManager.shared.isConnectedNetwork)
    }
    
    private func fetchAllEvents() {
        devEventsFetcherOutput
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
    
    func addFavorite(event: Event) -> Single<Bool> {
        return PersistanceManager.shared.addFavorteEvent(event)
    }
    
    func removeFavorite(event: Event) -> Single<Bool> {
        return PersistanceManager.shared.removeFavoriteEvent(event)
    }
}

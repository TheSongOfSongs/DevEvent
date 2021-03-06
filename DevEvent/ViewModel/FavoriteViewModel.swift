//
//  FavoriteViewModel.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/16.
//

import Foundation
import RxSwift
import RxRelay

final class FavoriteViewModel: ViewModelType {
    
    struct Input {
        var requestFetchingEvents: Observable<Void>
    }
    
    struct Output {
        var dataSources: Observable<[SectionOfEvents]>
        var isNetworkConnect: Observable<Bool>
    }
    
    private lazy var devEventsFetcherInput = DevEventsFetcher.Input()
    private lazy var devEventsFetcherOutput = DevEventsFetcher.shared.transform(input: devEventsFetcherInput)
    
    private let eventsFromServer: BehaviorRelay<[SectionOfEvents]> = BehaviorRelay(value: [])
    private let favoriteEvents: BehaviorRelay<[EventCoreData]> = BehaviorRelay(value: [])
    
    let disposeBag = DisposeBag()
    
    init() {
        fetchFavoriteEvents()
    }
    
    private func fetchFavoriteEvents() {
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
                // Github에 올라와있는 이벤트 리스트만 필터링
                var eventsFromServer = eventsFromServer
                for (i, sectionOfEvents) in eventsFromServer.enumerated() {
                    let items = sectionOfEvents.items.filter { event in
                        return favoriteEvents.contains(where: { event.isEqual(to: $0) })
                    }
                    
                    eventsFromServer[i] = SectionOfEvents(header: sectionOfEvents.header,
                                                          items: items)
                }
                
                // 종료된 이벤트 Section 추가
                let events = eventsFromServer.flatMap({ $0.items })
                var endedEvents: [Event] = []
                favoriteEvents.forEach { event in
                    if events.first(where: { $0.isEqual(to: event) }) == nil {
                        endedEvents.append(Event(eventCoreData: event))
                    }
                }
                
                eventsFromServer.append(SectionOfEvents(header: "종료된 이벤트",
                                                        items: endedEvents))
                
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

//
//  FavoriteViewModel.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/16.
//

import Foundation
import RxSwift

class FavoriteViewModel: ViewModelType {
    
    struct Input { }
    
    struct Output {
        var dataSources: Observable<[SectionOfEvents]>
    }
    
    private lazy var input = PersistanceManager.Input()
    private lazy var output = PersistanceManager.shared.transform(input: input)
    
    private let eventsFromServer: Observable<[SectionOfEvents]>
    private let favoriteEvents: Observable<[EventCoreData]>
    
    let disposeBag = DisposeBag()
    
    init() {
        let eventsFromServer: BehaviorSubject<[SectionOfEvents]> = BehaviorSubject(value: [])
        let favoriteEvents: BehaviorSubject<[EventCoreData]> = BehaviorSubject(value: [])
        
        self.eventsFromServer = eventsFromServer.share()
        self.favoriteEvents = favoriteEvents.share()
        
        DevEventsFetcher()
            .devEvents
            .subscribe(onNext: { sectionOfEvents in
                eventsFromServer.onNext(sectionOfEvents)
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
                favoriteEvents.onNext(eventCoreData)
            }, onError: { error in
                // TODO: - 에러 핸들링
                print("🍎 error:\(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    func transform(input: Input) -> Output {
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
                
                return eventsFromServer
            }
        
        return Output(dataSources: dataSources)
    }
    
    func removeFavorite(event: Event) -> Single<Bool> {
        return PersistanceManager.shared.removeFavoriteEvent(event)
    }
}

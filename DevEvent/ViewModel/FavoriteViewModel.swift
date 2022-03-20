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
    
    struct Input { }
    
    struct Output {
        var dataSources: Observable<[SectionOfEvents]>
    }
    
    private lazy var input = PersistanceManager.Input()
    private lazy var output = PersistanceManager.shared.transform(input: input)
    
    private let eventsFromServer: BehaviorRelay<[SectionOfEvents]> = BehaviorRelay(value: [])
    private let favoriteEvents: BehaviorRelay<[EventCoreData]> = BehaviorRelay(value: [])
    
    let disposeBag = DisposeBag()
    
    init() {
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
                
                return eventsFromServer
            }
        
        dataSources
            .subscribe(onNext: { result in
                relay.accept(result)
            })
            .disposed(by: disposeBag)
        
        return Output(dataSources: relay.asObservable())
    }
    
    func removeFavorite(event: Event) -> Single<Bool> {
        return PersistanceManager.shared.removeFavoriteEvent(event)
    }
}

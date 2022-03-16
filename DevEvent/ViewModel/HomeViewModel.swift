//
//  HomeViewModel.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation
import RxSwift
import RxRelay

class HomeViewModel: ViewModelType {
    
    struct Input { }
    
    struct Output {
        var dataSources: Observable<[SectionOfEvents]>
    }
    
    private lazy var input = PersistanceManager.Input()
    private lazy var output = PersistanceManager.shared.transform(input: input)
    
    private let eventsFromServer: Observable<[SectionOfEvents]>
    private let favoriteEvents: Observable<[EventCoreData]>
    
    let disposeBag = DisposeBag()

    // MARK: - init
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
    
    
    // TODO: - refactor
    func transform(input: Input) -> Output {
        let dataSources = Observable.combineLatest(eventsFromServer, favoriteEvents)
            .map { eventsFromServer, favoriteEvents -> [SectionOfEvents] in
                var eventsFromServer = eventsFromServer
                for (i, sectionOfEvents) in eventsFromServer.enumerated() {
                    var items = sectionOfEvents.items
                    
                    for(j, event) in items.enumerated() {
                        let isFavorite: Bool = {
                            if favoriteEvents.contains(where: { event.isEqual(to: $0) }) {
                                return true
                            } else {
                                return false
                            }
                        }()

                        items[j].isFavorite = isFavorite
                    }
                    
                    eventsFromServer[i] = SectionOfEvents(header: sectionOfEvents.header,
                                                          items: items)
                }
                
                return eventsFromServer
            }

        return Output(dataSources: dataSources)
    }
    
    func addFavorite(event: Event) -> Single<Bool> {
        return PersistanceManager.shared.addFavorteEvent(event)
    }
}

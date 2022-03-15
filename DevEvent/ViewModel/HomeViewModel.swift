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
    
    let disposeBag = DisposeBag()

    // MARK: - init
    init() { }
    
    func transform(input: Input) -> Output {
        let dataSources: BehaviorRelay<[SectionOfEvents]> = BehaviorRelay(value: [])
        
        // TODO: - 즐겨찾기 리스트 가져오기
        
        DevEventsFetcher()
            .devEvents
            .subscribe(onNext: { sectionOfEvents in
                dataSources.accept(sectionOfEvents)
            }, onError: { error in
                // TODO: - 에러 핸들링
                print("🍎 error:\(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        return Output(dataSources: dataSources.asObservable())
    }
}

//
//  NetworkService.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation

import RxSwift
import SwiftSoup

enum FetchingEventsError: Error {
    case urlError
    case parsingError
    case unknown
    case other(Error)
    
    static func map(_ error: Error) -> FetchingEventsError {
      return (error as? FetchingEventsError) ?? .other(error)
    }
}

/// 데이터 스크래핑을 위해 네트워크 통신을 담당하는 singleton 클래스
final class NetworkService {
    
    static let shared = NetworkService()
    
    
    private init() { }
    let githubURLString = "https://github.com/brave-people/Dev-Event/blob/master/README.md"
    
    /// 스크래핑을 통해 가져온 HTML을 MonthlyEvent 타입으로 가공하는 함수
    func fetchHTML() -> Single<String> {
        return Single<String>.create { [weak self] single in
            guard let self = self else {
                single(.failure(FetchingEventsError.unknown))
                return Disposables.create()
            }

            guard let url = URL(string: self.githubURLString) else {
                single(.failure(FetchingEventsError.urlError))
                return Disposables.create()
            }
            
            DispatchQueue.global().async {
                do {
                    let html = try String(contentsOf: url, encoding: .utf8)
                    
                    DispatchQueue.main.async {
                        single(.success(html))
                    }
                    
                } catch let error {
                    DispatchQueue.main.async {
                        single(.failure(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}

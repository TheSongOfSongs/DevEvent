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
    case dataError
    case unknown
    case other(Error)
    
    static func map(_ error: Error) -> FetchingEventsError {
      return (error as? FetchingEventsError) ?? .other(error)
    }
}

/// 데이터 스크래핑을 위해 네트워크 통신을 담당하는 singleton 클래스
final class NetworkService {
    
    static let shared = NetworkService()
    
    let session: URLSessionProtocol
    
    let githubURLString = "https://github.com/brave-people/Dev-Event/blob/master/README.md"
    
    private init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
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
            
            self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let data = data,
                      let html = String(data: data, encoding: .utf8) else {
                    single(.failure(FetchingEventsError.dataError))
                    return
                }
                
                single(.success(html))
            }.resume()
            
            return Disposables.create()
        }
    }
}

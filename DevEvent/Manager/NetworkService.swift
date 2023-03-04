//
//  NetworkService.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation

import RxSwift
import SwiftSoup

enum NetworkServiceError: Error {
    case urlError
    case failedParse
    case failedRequest
    case invalidResponse
    case invalidData
    case unknown
}

/// 데이터 스크래핑을 위해 네트워크 통신을 담당하는 singleton 클래스
final class NetworkService {
    
    var session: URLSessionProtocol
    
    static let githubURLString = "https://github.com/brave-people/Dev-Event/blob/master/README.md"
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /// 스크래핑을 통해 가져온 HTML을 MonthlyEvent 타입으로 가공하는 함수
    func fetchHTML() async -> Result<String, NetworkServiceError> {
        guard let url = URL(string: NetworkService.githubURLString) else {
            return(.failure(.urlError))
        }
        
        do {
            let (data, response) = try await session.data(with: url)
            
            guard let response = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            
            guard response.statusCode == 200 else {
                return .failure(.failedRequest)
            }
            
            guard !data.isEmpty,
                  let html = String(data: data, encoding: .utf8) else {
                return .failure(.invalidData)
            }
            
            return .success(html)
        } catch let error {
            NSLog("❗️ error: \(error.localizedDescription)")
            return .failure(NetworkServiceError.failedRequest)
        }
    }
}

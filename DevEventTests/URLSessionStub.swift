//
//  URLSessionStub.swift
//  DevEventTests
//
//  Created by Jinhyang Kim on 2023/02/27.
//

import Foundation
@testable import DevEvent

class URLSessionStub: URLSessionProtocol {
    
    typealias Response = (stubbedData: Data, stubbedResponse: URLResponse)
    
    private let stubbedData: Data
    private let stubbedResponse: URLResponse
    
    public init(response: Response) {
        self.stubbedData = response.stubbedData
        self.stubbedResponse = response.stubbedResponse
    }
    
    public func data(with url: URL) -> (data: Data, response: URLResponse) {
        return (data: stubbedData, response: stubbedResponse)
    }
    
    static func make(data: Data, response: URLResponse) -> URLSessionStub {
        let urlSessionStub: URLSessionStub = {
            let urlSessionStubResponse: URLSessionStub.Response = (stubbedData: data,
                                                                   stubbedResponse: response)
            
            return URLSessionStub(response: urlSessionStubResponse)
        }()
        return urlSessionStub
    }
}

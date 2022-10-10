//
//  DevEventSlowTests.swift
//  DevEventSlowTests
//
//  Created by Jinhyang Kim on 2022/10/04.
//

import XCTest
@testable import DevEvent

/// 비동기로 실행된는 함수에 관한 테스트
final class DevEventSlowTests: XCTestCase {
    
    var urlSession: URLSession!
    
    let networkConnectionManager = NetworkConnectionManager.shared
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        urlSession = URLSession(configuration: .default)
    }
    
    override func tearDownWithError() throws {
        urlSession = nil
        try super.tearDownWithError()
    }
    
    ///  github의 페이지가 유효하고 에러 발생하지 않는지 확인하는 테스트
    func testApiCallCompletes() throws {
        try XCTSkipUnless(
            networkConnectionManager.isReachable,
            "Network connectivity needed for this test."
        )
        
        // given
        let url = URL(string: NetworkService.githubURLString)!
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        let dataTask = urlSession.dataTask(with: url) { _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
}

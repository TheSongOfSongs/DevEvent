//
//  DevEventFakeTests.swift
//  DevEventTests
//
//  Created by Jinhyang Kim on 2022/10/04.
//

import XCTest
@testable import DevEvent
@testable import RxSwift

final class DevEventFakeTests: XCTestCase {
    
    var parser: Parser!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        parser = Parser()
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        parser = nil
        disposeBag = nil
    }
    
    /// 가짜 데이터를 갖고 HTML에서 [SectionOfEvents]로 변환되는지 확인하는 테스트
    func testParsingHTMLToArrayOfSectionOfEvents() async throws {
        // given
        // 번들에서 fake로 만든 데이터 html 가져오기
        let testBundle = Bundle(for: type(of: self))
        let filePath = testBundle.path(forResource: "MockData1", ofType: "html")!
        let fileURL = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: fileURL)
        
        // Mock URLSession 만들기
        let urlSessionStub: URLSessionStub = {
            let urlString = NetworkService.githubURLString
            let url = URL(string: urlString)!
            let response = HTTPURLResponse(url: url,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            return URLSessionStub.make(data: data,
                                       response: response)
        }()
        
        let networkService = NetworkService(session: urlSessionStub)
        let promise = expectation(description: "Value received!")
        
        // ✅ when
        let result = await networkService.fetchHTML()
        
        switch result {
        case .success(let html):
            parser.parse(html: html)
                .subscribe(onSuccess: { events in
                    XCTAssertEqual(events.count, 3)
                    XCTAssertEqual(events.first!.header, "22년 10월")
                    XCTAssertEqual(events.last!.items.count, 2)
                    promise.fulfill()
                })
                .disposed(by: disposeBag)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [promise], timeout: 10)
    }
    
    func test_실패_statusCode가_200이고_데이터_디코딩에_실패할_때() async throws {
        // given
        let urlSessionStub: URLSessionStub = {
            let urlString = NetworkService.githubURLString
            let response = HTTPURLResponse(url: URL(string: urlString)!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            return URLSessionStub.make(data: Data(),
                                       response: response)
        }()
        
        // when
        let networkService = NetworkService(session: urlSessionStub)
        
        var result: NetworkServiceError?
        if case let .failure(error) = await networkService.fetchHTML() {
            result = error
        }
        
        // then
        XCTAssertEqual(result, .invalidData)
    }
    
    func test_statusCode가_500일_때() async throws {
        // given
        let urlSessionStub: URLSessionStub = {
            let urlString = NetworkService.githubURLString
            let response = HTTPURLResponse(url: URL(string: urlString)!,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            return URLSessionStub.make(data: Data(),
                                       response: response)
        }()
        
        // when
        let networkService = NetworkService(session: urlSessionStub)
        
        var result: NetworkServiceError?
        if case let .failure(error) = await networkService.fetchHTML() {
            result = error
        }
        
        // then
        XCTAssertEqual(result, .failedRequest)
    }
}

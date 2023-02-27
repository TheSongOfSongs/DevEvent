//
//  URLSessionProtocol.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/10/05.
//

import Foundation

protocol URLSessionProtocol {
    func data(with url: URL) async throws -> (data: Data, response: URLResponse)
}

extension URLSession: URLSessionProtocol {
    func data(with url: URL) async throws -> (data: Data, response: URLResponse) {
        return try await data(from: url)
    }
}

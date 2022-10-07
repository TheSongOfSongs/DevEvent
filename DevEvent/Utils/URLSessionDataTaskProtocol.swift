//
//  URLSessionDataTaskProtocol.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/10/05.
//

import Foundation

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }

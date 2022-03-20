//
//  ToasterMessage.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/20.
//

import Foundation

enum ToasterMessage {
    case checkNetwork
    
    var message: String {
        switch self {
        case .checkNetwork:
            return "네트워크 연결을 확인해주세요!"
        }
    }
}

//
//  Entity.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/15.
//

import Foundation

enum Entity: String {
    case eventCoreData
    
    var name: String {
        switch self {
        case .eventCoreData:
            return "EventCoreData"
        }
    }
}


enum EventCoreDataKey: String {
    case name
    case url
    case registeredDate
}

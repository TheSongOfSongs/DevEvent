//
//  Event.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation

struct Event: Identifiable {
    var id = UUID()
    var name: String = ""
    var urlString: String = ""
    var detail: EventDetail?
    
    var url: URL? {
        return URL(string: urlString)
    }
}

struct EventDetail {
    var category: String?
    var host: String?
    var eventPeriodName: String?
    var duration: String?
}

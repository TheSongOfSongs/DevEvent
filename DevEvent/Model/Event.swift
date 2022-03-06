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
    var url: String = ""
    var detail: EventDetail?
}

struct EventDetail {
    var category: String?
    var host: String?
    var startDate: String?
    var endDate: String?
    var eventPeriodName: String?
}

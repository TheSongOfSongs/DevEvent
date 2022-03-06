//
//  MonthlyEvent.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation

struct MonthlyEvent: Identifiable {
    var id = UUID()
    var sectionName: String
    var events: [Event]
}

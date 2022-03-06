//
//  MonthlyEvent.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation
import RxDataSources

struct SectionOfEvents {
  var header: String
  var items: [Item]
}

extension SectionOfEvents: SectionModelType {
    typealias Item = Event
    
    init(original: SectionOfEvents, items: [Item]) {
        self = original
        self.items = items
    }
}

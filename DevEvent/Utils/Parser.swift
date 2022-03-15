//
//  Parser.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation

import SwiftSoup
import RxSwift

struct Parser {
    
    func parse(html: String) -> Single<[SectionOfEvents]> {
        return Single<[SectionOfEvents]>.create { single in
            var results: [SectionOfEvents] = []
            
            do {
                let doc = try SwiftSoup.parse(html)
                
                guard let readme = try doc.select("div#readme").first() else {
                    single(.failure(FetchingEventsError.parsingError))
                    return Disposables.create()
                }
                
                let sections = try readme.select("h2")
                    .filter({ header in
                        return try header.text().isEventSectionFormat
                    })
                
                // 월별 순회
                try sections.forEach { section in
                    let sectionName = try section.text()
                    var events: [Event] = []
                    
                    defer {
                        let monthlyEvent = SectionOfEvents(header: sectionName, items: events)
                        results.append(monthlyEvent)
                    }
                    
                    guard let eventElements = try section
                            .nextElementSibling()?
                            .children() else {
                                return
                            }
                    
                    // 월별 > 이벤트 순회
                    try eventElements.forEach({ event in
                        let link = try event.select("a")
                        let name = try link.text()
                        let url = try link.attr("href")
                        let detail = try event.select("ul")
                        let event = Event(name: name,
                                          urlString: url,
                                          detail: parse(detail: detail))
                        events.append(event)
                    })
                }
                
                single(.success(results))
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    
    /// HTML에서 Event 상세정보를 뽑아낸 값을 EventDetail로 가공하는 함수
    func parse(detail: Elements) -> EventDetail? {
        var category: String?
        var host: String?
        var eventPeriodName: String?
        var duration: String?
        
        do {
            let details = try detail.select("li")
            try details.forEach { detail in
                let detail = try detail
                    .text()
                    .split(separator: ":")
                    .map({ String($0) })
                switch detail.first {
                case "주최":
                    host = detail.last
                case "분류":
                    category = detail.last
                default: // 이벤트 기간
                    eventPeriodName = detail.first
                    
                    if detail.count > 2 {
                        duration = "\(detail[1]):\(detail[2])"
                    } else {
                        duration = detail.last ?? "-"
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        return EventDetail(category: category,
                           host: host,
                           eventPeriodName: eventPeriodName,
                           duration: duration)
    }
}

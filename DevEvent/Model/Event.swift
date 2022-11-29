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
    var isFavorite: Bool = false
    
    var url: URL? {
        return URL(string: urlString)
    }
    
    func isEqual(to eventCoreData: EventCoreData) -> Bool {
        return name == eventCoreData.name && url == eventCoreData.url
    }
}

extension Event {
    init(eventCoreData: EventCoreData) {
        self.name = eventCoreData.name ?? ""
        self.urlString = eventCoreData.url?.absoluteString ?? ""
        self.detail = eventCoreData.detail
        self.isFavorite = true
    }
}

public class EventDetail: NSObject, NSSecureCoding {
    
    public static var supportsSecureCoding: Bool = true
    
    var category: String?
    var host: String?
    var eventPeriodName: String?
    var duration: String?
    
    public func encode(with coder: NSCoder) {
        coder.encode(category, forKey: "category")
        coder.encode(host, forKey: "host")
        coder.encode(host, forKey: "eventPeriodName")
        coder.encode(host, forKey: "duration")
    }
    
    public required init?(coder: NSCoder) {
        if let category = coder.decodeObject(of: NSString.self, forKey: "category") {
            self.category = category as String
        }
        
        if let host = coder.decodeObject(of: NSString.self, forKey: "host") {
            self.host = host as String
        }
        
        if let eventPeriodName = eventPeriodName {
            self.eventPeriodName = eventPeriodName as String
        }
        
        if let duration = duration {
            self.duration = duration as String
        }
    }
    
    init(category: String?, host: String?, eventPeriodName: String?, duration: String?) {
        self.category = category
        self.host = host
        self.eventPeriodName = eventPeriodName
        self.duration = duration
    }
}

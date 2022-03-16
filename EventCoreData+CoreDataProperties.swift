//
//  EventCoreData+CoreDataProperties.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/15.
//
//

import Foundation
import CoreData


extension EventCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventCoreData> {
        return NSFetchRequest<EventCoreData>(entityName: "EventCoreData")
    }

    @NSManaged public var name: String?
    @NSManaged public var url: URL?
    @NSManaged public var registeredDate: Date?

}

extension EventCoreData : Identifiable {

}

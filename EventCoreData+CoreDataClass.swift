//
//  EventCoreData+CoreDataClass.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/15.
//
//

import Foundation
import CoreData

@objc(EventCoreData)
public class EventCoreData: NSManagedObject {

}

extension EventCoreData {
    class func fetchRequest(event: Event) -> NSFetchRequest<EventCoreData> {
        let request = NSFetchRequest<EventCoreData>(entityName: Entity.eventCoreData.name)
        
        let predicate: NSPredicate = {
            if let eventURL = event.url {
                return NSPredicate(format: "name == %@ && url = %@", event.name, eventURL as CVarArg)
            } else {
                return NSPredicate(format: "name == %@", event.name)
            }
        }()
        
        request.predicate = predicate
        return request
    }
}

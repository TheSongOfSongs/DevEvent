//
//  EventDetailValueTransformer.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/11/29.
//

import Foundation

// It has to be a subclass of `NSSecureUnarchiveFromDataTransformer` and we need to expose it to ObjC.
@objc(EventDetailValueTransformer)
final class EventDetailValueTransformer: NSSecureUnarchiveFromDataTransformer {

    // The name of the transformer. This is what we will use to register the transformer `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: EventDetailValueTransformer.self))

    // Our class `EventDetail` should in the allowed class list. (This is what the unarchiver uses to check for the right class)
    override static var allowedTopLevelClasses: [AnyClass] {
        return [EventDetail.self]
    }

    // Registers the transformer.
    public static func register() {
        let transformer = EventDetailValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

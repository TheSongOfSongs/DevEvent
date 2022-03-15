//
//  PersistanceManager.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/15.
//

import UIKit
import CoreData
import Differentiator
import RxSwift

final class PersistanceManager {
    
    static let shared = PersistanceManager()
    
    let appDelegate: AppDelegate
    let context: NSManagedObjectContext
    
    private init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    /// CoreData의 모든 Event를 가져오는 메서드
    @discardableResult
    func fetchEvents() -> Result<[EventCoreData], Error> {
        do {
            let event = try context.fetch(EventCoreData.fetchRequest()) as? [EventCoreData]
            // Binding 해주기
            return .success(event ?? [])
        } catch let error {
            return .failure(error)
        }
    }
    
    /// CoreData에 Event를 즐겨찾기 추가해주는 메서드
    func addFavorteEvent(_ event: Event) -> Single<Bool> {
        let entity = NSEntityDescription.entity(forEntityName: Entity.eventCoreData.name,
                                                in: context)
        
        if let entity = entity {
            let object = NSManagedObject(entity: entity, insertInto: context)
            object.setValue(event.name, forKey: EventCoreDataKey.name.rawValue)
            object.setValue(event.url, forKey: EventCoreDataKey.url.rawValue)
            object.setValue(Date(), forKey: EventCoreDataKey.registeredDate.rawValue)
        }
        
        return Single<Bool>.create { [weak self] single in
            do {
                try self?.context.save()
                single(.success(true))
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    /// CoreData의 즐겨찾기 리스트에서 Event를 삭제하는 메서드
    func removeFavoriteEvent(_ event: Event) -> Single<Bool> {
        return Single<Bool>.create { single in
            switch self.findEventCoreData(by: event) {
            case .success(let event):
                self.context.delete(event!)
                
                do {
                    try self.context.save()
                    single(.success(true))
                } catch let error {
                    single(.failure(error))
                }
            case .failure(let error):
                single(.failure(error))
            }
        
            return Disposables.create()
        }
    }
    
    /// Event 객체로 EventCoreData 가져오기
    private func findEventCoreData(by event: Event) -> Result<EventCoreData?, Error> {
        let request = EventCoreData.fetchRequest(event: event)
        do {
            let coreData = try context.fetch(request)
            return .success(coreData.first)
        } catch let error {
            return .failure(error)
        }
    }
}

//
//  DataStorage.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 01.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit
import CoreData

class DataStorage {
    
    static let shared = DataStorage()
    
    private let writeQueue = DispatchQueue(label: "write_serial_queue")
    private let readQueue = DispatchQueue(label: "read_serial_queue")
    
    private weak var appDelegate: AppDelegate!
    private var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    private init() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
    }
    
    func fetch<T: NSFetchRequestResult>(request: NSFetchRequest<T>,
                                        completionQueue queue: DispatchQueue,
                                        completion: @escaping ((_ data: [T]) -> Void)) {
        readQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            do {
                let reuslt = try self.context.fetch(request)
                queue.async {
                    completion(reuslt)
                }
            } catch {
                print(error.localizedDescription)
                queue.async {
                    completion([])
                }
            }
        }
    }
    
    func entity<T: NSManagedObject>(type: T.Type) -> T? {
        guard let description = NSEntityDescription.entity(forEntityName: String(describing: type), in: context) else {
            assertionFailure("Can't create entity description")
            return nil
        }
        return T(entity: description, insertInto: context)
    }
    
    private func save() {
        appDelegate.saveContext()
    }
}

//
//  DataStorage.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 01.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit
import CoreData

/*
     Для записи и чтения из базы данных в разных потоках использовался разный контекст.
     Но, т.к. чтение списка партнеров (fetch(_,_,_)) может исользоваться как для отображения,
     так и для записи(связывание с точками или удаление), поэтому необходимо указывать цель операции для выбора нужного контекста.
*/

class DataStorage {
    
    enum OperationGoal {
        case read
        case write
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TestTinkoff")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy private var readContext: NSManagedObjectContext = {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return privateContext
    }()
    
    lazy private var writeContext: NSManagedObjectContext = {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = readContext
        return privateContext
    }()
    
    static let shared = DataStorage()

    private init() {}
    
    func fetch<T: NSFetchRequestResult>(request: NSFetchRequest<T>,
                                        goal: OperationGoal,
                                        completion: @escaping ((_ data: [T]) -> Void)) {
        let context = contextFor(goal: goal)
        context.perform {
            do {
                let reuslt = try context.fetch(request)
                completion(reuslt)
            } catch {
                print(error.localizedDescription)
                completion([])
            }
        }
    }
    
    func remove<T: NSFetchRequestResult>(request: NSFetchRequest<T>, completion: @escaping (() -> Void)) {
        fetch(request: request, goal: .write) { [unowned self] results in
            self.writeContext.perform { [unowned self] in
                for result in results {
                    guard let object = result as? NSManagedObject else { continue }
                    self.writeContext.delete(object)
                }
                try? self.writeContext.save()
                completion()
            }
        }
    }
    
    func entity<T: NSManagedObject>(type: T.Type) -> T? {
        guard let description = NSEntityDescription.entity(forEntityName: String(describing: type), in: writeContext) else {
            assertionFailure("Can't create entity description")
            return nil
        }
        return T(entity: description, insertInto: writeContext)
    }
    
    func save(_ entityAllocationClosure: @escaping (() -> Void), _ completion: @escaping (() -> Void)) {
        writeContext.perform { [unowned self] in
            entityAllocationClosure()
            try? self.writeContext.save()
            completion()
        }
    }
    
    private func contextFor(goal: OperationGoal) -> NSManagedObjectContext {
        switch goal {
        case .read:
            return readContext
        case .write:
            return writeContext
        }
    }
}

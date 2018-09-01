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
    
    func fetch<T: NSFetchRequestResult>(request: NSFetchRequest<T>, completion: @escaping ((_ data: [T]) -> Void)) {
        readQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            do {
                let reuslt = try self.context.fetch(request)
                completion(reuslt)
            } catch {
                print(error.localizedDescription)
                completion([])
            }
        }
    }
    
    func save() {
        appDelegate.saveContext()
    }
    
}

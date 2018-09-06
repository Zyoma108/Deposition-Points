//
//  ImageStorage.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 04.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit

class ImageStorage {

    static let shared = ImageStorage()
    
    private init() {}
    
    private let fileManager = FileManager()
    private let queue = DispatchQueue.global(qos: .userInteractive)
    private let semaphore = DispatchSemaphore(value: 1)
    
    private lazy var imageCachePath: URL = {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("/icons")
    }()
    
    
    func readImageWith(name: String, completion: @escaping (_ data: (image: UIImage, creationDate: Date)?) -> Void) {
        queue.async { [unowned self] in
            let path = self.imageCachePath.appendingPathComponent("/" + name).path
            
            self.semaphore.wait()
            
            if self.fileManager.fileExists(atPath: path),
                let image = UIImage(contentsOfFile: path),
                let attributes = try? self.fileManager.attributesOfItem(atPath: path),
                let creationDate = attributes[.creationDate] as? Date {
                completion((image: image, creationDate: creationDate))
            } else {
                completion(nil)
            }
            
            self.semaphore.signal()
        }
    }
    
    func saveImage(_ image: UIImage, withName name: String, completion: ((_ success: Bool) -> Void)?) {
        queue.async { [unowned self] in
            let url = self.imageCachePath.appendingPathComponent("/" + name)
            
            if let representation = UIImageJPEGRepresentation(image, 1) {
                
                self.semaphore.wait()
                self.createCachePathIfNeeded()
                
                do {
                    try representation.write(to: url)
                    completion?(true)
                } catch {
                    print("Can't save image \(error.localizedDescription)")
                    completion?(false)
                }
                
                self.semaphore.signal()
            } else {
                completion?(false)
            }
        }
    }
    
    private func createCachePathIfNeeded() {
        guard !fileManager.fileExists(atPath: imageCachePath.path) else { return }
        do {
            try fileManager.createDirectory(at: imageCachePath, withIntermediateDirectories: true)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
}

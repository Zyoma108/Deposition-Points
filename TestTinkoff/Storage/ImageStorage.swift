//
//  ImageStorage.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 04.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit

class ImageStorage {
    
    typealias DisplayImageCompletion = ((_ image: UIImage?) -> Void)
    
    static let shared = ImageStorage()
    private var fileManager: FileManager!
    
    private let queue = DispatchQueue.global(qos: .userInteractive)
    private let semaphore = DispatchSemaphore(value: 1)
    
    private init() {
        queue.async { [unowned self] in
            self.fileManager = FileManager()
            self.createCachePathIfNeeded()
        }
    }
    
    private lazy var imageCachePath: URL = {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("/icons")
    }()
    
    func cacheImageWith(url: String, completion: @escaping ((_ image: UIImage?) -> Void)) {
        queue.async { [unowned self] in
            self.readCachedImage(url, completion: completion)
        }
    }
    
    private func readCachedImage(_ url: String, completion: @escaping DisplayImageCompletion) {
        let path = imageCachePath.appendingPathComponent("/" + url.md5).path
        
        semaphore.wait()
        guard fileManager.fileExists(atPath: path),
            let attributes = try? fileManager.attributesOfItem(atPath: path),
            let creationDate = attributes[.creationDate] as? Date else {
                semaphore.signal()
                downloadImage(url: url, completion: completion)
                return
        }
        
        let image = UIImage(contentsOfFile: path)
        semaphore.signal()
        
        DispatchQueue.main.async {
            completion(image)
        }
        
        checkLastModifedOf(url: url) { [unowned self] date in
            if let lastModifiedDate = date {
                if creationDate > lastModifiedDate {
                    return
                }
            }
            self.downloadImage(url: url, completion: completion)
        }
    }
    
    
    private func downloadImage(url: String, completion: @escaping DisplayImageCompletion) {
        let request = GetRequest(domain: url, path: nil, parameters: nil)
        request.send { [unowned self] result, _ in
            self.queue.async {
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data),
                        let representation = UIImageJPEGRepresentation(image, 1) {
                        DispatchQueue.main.async {
                            completion(image)
                        }
                        
                        self.semaphore.wait()
                        try? representation.write(to: self.imageCachePath.appendingPathComponent(url.md5))
                        self.semaphore.signal()
                        
                    } else {
                        print("Can't parse image")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func checkLastModifedOf(url: String, completion: @escaping ((_ date: Date?) -> Void)) {
        let request = ReadHeadRequest(url: url)
        request.send { [unowned self] _ , headers in
            self.queue.async {
                let lastModifedString = headers?["Last-Modified"] as? String
                
                let formetter = DateFormatter()
                formetter.locale = Locale(identifier: "en_EN")
                formetter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                if let dateString = lastModifedString {
                    let date = formetter.date(from: dateString)
                    completion(date)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func createCachePathIfNeeded() {
        do {
            try fileManager.createDirectory(at: imageCachePath, withIntermediateDirectories: true)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
}

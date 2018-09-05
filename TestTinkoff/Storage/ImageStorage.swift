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
    
    private init() {
        queue.async { [unowned self] in
            self.fileManager = FileManager()
            self.createCachePathIfNeeded()
        }
    }
    
    private var imageCachePath: URL {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("/icons")
    }
    
    func cacheImageWith(url: String, completion: @escaping ((_ image: UIImage?) -> Void)) {
        queue.async { [unowned self] in
            self.readCachedImage(url) { cachedImage in
                if let cachedImage = cachedImage {
                    DispatchQueue.main.async {
                        completion(cachedImage)
                    }
                } else {
                    self.queue.async {
                        self.downloadImage(url: url, completion: completion)
                    }
                }
            }
        }
    }
    
    private func downloadImage(url: String, completion: @escaping DisplayImageCompletion) {
        let request = GetRequest(domain: url, path: nil, parameters: nil)
        request.send { [unowned self] result, _ in
            self.queue.async {
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data),
                        let representation = UIImagePNGRepresentation(image) {
                        DispatchQueue.main.async {
                            completion(image)
                        }
                        do {
                            try representation.write(to: self.imageCachePath.appendingPathComponent(url.md5))
                        } catch {
                            print(error.localizedDescription)
                        }
                    } else {
                        print("Can't parse image")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func readCachedImage(_ url: String, completion: @escaping DisplayImageCompletion) {
        let contents = try? fileManager.contentsOfDirectory(at: imageCachePath,
                                                            includingPropertiesForKeys: nil,
                                                            options: .skipsHiddenFiles)
        
        if let cachedContent = contents?.first(where: { content in
            if let fileName = content.absoluteString.components(separatedBy: "/").last,
                fileName == url.md5 {
                return true
            } else {
                return false
            }
        }),
            let attributes = try? fileManager.attributesOfItem(atPath: cachedContent.path),
            let creationDate = attributes[.creationDate] as? Date {
            
            completion(UIImage(contentsOfFile: cachedContent.path))
            checkLastModifedOf(url: url) { [unowned self] date in
                if let lastModifiedDate = date,
                    lastModifiedDate < creationDate {
                    // display cached image
                } else {
                    self.downloadImage(url: url, completion: completion)
                }
            }
        } else {
            downloadImage(url: url, completion: completion)
        }
    }
    
    private func checkLastModifedOf(url: String, completion: @escaping ((_ date: Date?) -> Void)) {
        let request = ReadHeadRequest(url: url)
        request.send { [unowned self] _ , headers in
            self.queue.async {
                let lastModifedString = headers?["Last-Modified"] as? String
                
                let formetter = DateFormatter()
                formetter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                if let dateString = lastModifedString {
                    completion(formetter.date(from: dateString))
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

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
    
    private init() {
        createCachePathIfNeeded()
    }
    
    private var imageCachePath: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("/icons")
    }
    
    func saveImageWith(url: String, completion: @escaping ((_ image: UIImage?) -> Void)) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let `self` = self else { return }
            
            if let cached = self.readCachedImage(url) {
                DispatchQueue.main.async {
                    completion(cached)
                }
                return
            }
            
            let request = GetRequest(domain: url, path: nil, parameters: nil)
            request.send { result, _ in
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
    
    private func readCachedImage(_ url: String) -> UIImage? {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: imageCachePath,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for content in contents {
                if let fileName = content.absoluteString.components(separatedBy: "/").last,
                    fileName == url.md5 {
                    let readedImage = UIImage(contentsOfFile: content.path)
                    return readedImage
                }
            }
            return nil
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    private func createCachePathIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: imageCachePath, withIntermediateDirectories: true)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
}

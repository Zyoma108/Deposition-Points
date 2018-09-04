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
        let request = GetRequest(domain: url, path: nil, parameters: nil)
        request.send { result in
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
    
    func filesList() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: imageCachePath,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            print(contents)
        } catch {
            print(error.localizedDescription)
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

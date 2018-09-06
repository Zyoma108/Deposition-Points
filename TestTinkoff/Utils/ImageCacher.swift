//
//  ImageCacher.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 05.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit

class ImageCacher {
    
    private let queue = DispatchQueue.global(qos: .userInitiated)
    
    private let displayImage: ((_ image: UIImage) -> Void)
    private let imageUrl: String
    private let imageName: String
    
    private static let formatter = DateFormatter.httpDateFormatter
    
    init(imageUrl: String, completion: @escaping ((_ image: UIImage) -> Void)) {
        self.displayImage = completion
        self.imageUrl = imageUrl
        self.imageName = imageUrl.md5
        
        ImageStorage.shared.readImageWith(name: imageName) { [weak self] data in
            self?.queue.async { [weak self] in
                guard let `self` = self else { return }
                
                if let data = data {
                    self.needDisplayImage(data.image)
                    self.reDownloadImageIfNeeded(creationDate: data.creationDate)
                } else {
                    self.downloadImage()
                }
            }
        }
    }
    
    private func needDisplayImage(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
             self?.displayImage(image)
        }
    }
    
    private func downloadImage() {
        let request = GetRequest(domain: imageUrl, path: nil, parameters: nil)
        request.send { [weak self] result, _ in
            self?.queue.async {
                guard let `self` = self else { return }
                
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        
                        self.needDisplayImage(image)
                        ImageStorage.shared.saveImage(image, withName: self.imageName, completion: nil)
                        
                    } else {
                        print("Can't parse image")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func reDownloadImageIfNeeded(creationDate: Date) {
        let request = ReadHeadRequest(url: imageUrl)
        request.send { [weak self] _ , headers in
            self?.queue.async { [weak self] in
                guard let `self` = self else { return }
                
                let lastModifedString = headers?["Last-Modified"] as? String
                
                if let dateString = lastModifedString,
                    let lastModifiedDate = ImageCacher.formatter.date(from: dateString) {
                    if creationDate > lastModifiedDate {
                        return
                    }
                }
                self.downloadImage()
            }
        }
    }
    
}

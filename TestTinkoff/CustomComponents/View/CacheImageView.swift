//
//  CacheImageView.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 05.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit

class CacheImageView: UIImageView {
    
    private var cacher: ImageCacher?

    func setImageWith(url: String?) {
        image = nil
        if let url = url {
            cacher = ImageCacher(imageUrl: url) { [weak self] image in
                self?.image = image
            }
        } else {
            cacher = nil
        }
    }
    
}

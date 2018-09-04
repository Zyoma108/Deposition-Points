//
//  UIImageView+Cache.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 04.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageWith(url: String?) {
        guard let url = url else { return }
        
        ImageStorage.shared.saveImageWith(url: url) { [weak self] image in
            self?.image = image
        }
    }
    
}

//
//  UIImageView+Cache.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 04.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageWith(name: String?) {
        guard let name = name else { return }
        
        ImageStorage.shared.saveImageWith(name: name) { [weak self] image in
            self?.image = image
        }
    }
    
}

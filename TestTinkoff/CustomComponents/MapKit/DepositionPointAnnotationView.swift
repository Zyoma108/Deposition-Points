//
//  DepositionPointAnnotationView.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 04.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit
import MapKit

class DepositionPointAnnotationView: MKAnnotationView {
    
    lazy var imageView: UIImageView = {
        let image = UIImageView(frame: bounds)
        addSubview(image)
        return image
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
    
}

//
//  AlertControllerFactory.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 06.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit

struct AlertButton {
    
    let title: String
    let style: UIAlertActionStyle
    let handler: ((UIAlertAction) -> Void)?
    
    init(title: String, style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

struct AlertParameters {

    let title: String?
    let message: String?
    let button: AlertButton
    let secondButton: AlertButton?
    
    init(title: String?, message: String?, firstButton: AlertButton, secondButton: AlertButton? = nil) {
        self.title = title
        self.message = message
        self.button = firstButton
        self.secondButton = secondButton
    }
    
}

class AlertControllerFactory {
    
    static func alertVCWith(parameters: AlertParameters) -> UIAlertController {
        let vc = UIAlertController(title: parameters.title, message: parameters.message, preferredStyle: .alert)

        let firstAction = UIAlertAction(title: parameters.button.title,
                                        style: parameters.button.style,
                                        handler: parameters.button.handler)
        vc.addAction(firstAction)
        
        if let secondButton = parameters.secondButton {
            let secondAction = UIAlertAction(title: secondButton.title,
                                            style: secondButton.style,
                                            handler: secondButton.handler)
            vc.addAction(secondAction)
        }
        
        return vc
    }
    
}

//
//  DateFormatter+httpDate.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 06.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static var httpDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_EN")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter
    }
    
}

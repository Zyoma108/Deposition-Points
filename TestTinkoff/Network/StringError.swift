//
//  StringError.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

struct StringError: LocalizedError {
    
    var errorDescription: String?
    
    init(description: String) {
        self.errorDescription = description
    }
}

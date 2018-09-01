//
//  Request.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

enum RequestResult {
    case success(data: Data)
    case failure(error: Error)
}

typealias RequestCompletion = ((_ result: RequestResult) -> Void)

protocol Request {
    func send(_ completion: @escaping RequestCompletion)
}

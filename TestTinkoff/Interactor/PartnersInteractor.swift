//
//  PartnersInteractor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

class PartnersInteractor: Interactor {
    
    typealias T = [Partner]
    
    var request: Request {
        let method = TinkoffAPIMethod.depositionPartners(accountType: "Credit")
        return api.request(method)
    }
    
}

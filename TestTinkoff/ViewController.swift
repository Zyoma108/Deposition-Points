//
//  ViewController.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataStorage.shared.fetch(request: PartnerEntity.fetchRequest()) { result in
            print(result)
        }

//        let interactor = PointInteractor(latitude: 55.755786, longitude: 37.617633, radius: 1000)
//        interactor.receive { result in
//            switch result {
//            case .success(let result):
//                print(result)
//            case .failure(let error):
//                print(error)
//            }
//        }
    }

}


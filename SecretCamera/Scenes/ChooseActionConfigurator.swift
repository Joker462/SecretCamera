//
//  ChooseActionConfigurator.swift
//  SecretCamera
//
//  Created by Hung on 9/20/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation
protocol ChooseActionConfigurator {
    func configure(viewController: ChooseActionViewController)
}

class ChooseActionConfiguratorImplemetation: ChooseActionConfigurator {
    
    fileprivate let cover: Cover
    
    init(cover: Cover) {
        self.cover = cover
    }
    
    func configure(viewController: ChooseActionViewController) {
        let router = ChooseActionRouterImplementation(viewController: viewController)
        let presenter = ChooseActionPresenterImplementation(view: viewController, router: router, cover: cover)
        viewController.presenter = presenter
    }
}

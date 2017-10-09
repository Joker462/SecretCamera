//
//  CoversConfigurator.swift
//  SecretCamera
//
//  Created by Hung on 9/8/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation


protocol CoversConfigurator {
    func configure(viewController: CoversViewController)
}

class CoversConfiguratorImplemetation: CoversConfigurator {
    
    func configure(viewController: CoversViewController) {
        let router = CoversRouterImplementation(viewController: viewController)
        let presenter = CoversPresenterImplementation(view: viewController, router: router)
        viewController.presenter = presenter
    }
}

//
//  SettingsConfigurator.swift
//  SecretCamera
//
//  Created by Hung on 8/21/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

protocol SettingsConfigurator {
    func configure(viewController: SettingsViewController)
}

class SettingsConfiguratorImplemetation: SettingsConfigurator {
    
    fileprivate let cover: Cover
    
    init(cover: Cover) {
        self.cover = cover
    }
    
    func configure(viewController: SettingsViewController) {
        let router = SettingsRouterImplementation(viewController: viewController)
        let presenter = SettingsPresenterImplementation(view: viewController, router: router, cover: cover)
        viewController.presenter = presenter
    }
}

//
//  OptionSettingsConfigurator.swift
//  SecretCamera
//
//  Created by Hung on 9/15/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

protocol OptionSettingsConfigurator {
    func configure(viewController: OptionSettingsViewController)
}

class OptionSettingsConfiguratorImplemetation: OptionSettingsConfigurator {
    
    fileprivate let settingWithOptions: SettingWithOptions
    
    init(settingWithOptions: SettingWithOptions) {
        self.settingWithOptions = settingWithOptions
    }
    
    func configure(viewController: OptionSettingsViewController) {
        let presenter = OptionSettingsPresenterImplementation(view: viewController, settingWithOptions: settingWithOptions)
        viewController.presenter = presenter
    }
}

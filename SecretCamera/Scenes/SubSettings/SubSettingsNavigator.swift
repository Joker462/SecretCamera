//
//  SubSettingsNavigator.swift
//  SecretCamera
//
//  Created by MMI001 on 11/6/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class SubSettingsNavigator: BaseNavigator {
    
    // MARK: - Construction
    init(_ settings: SettingWithOptions) {
        let scene = SubSettingsViewController.instantiateFromStoryboard(storyboardName: "Main")
        super.init(scene)
        
        scene.viewModel = SubSettingsViewModel(navigator: self,
                                               output: scene,
                                               settings: settings)
    }
}

// MARK: - Navigate -
extension SubSettingsNavigator: Navigate {
    enum NavigateOption {}
    
    func navigate(option: NavigateOption) {}
}

//
//  ActionsNavigator.swift
//  SecretCamera
//
//  Created by MMI001 on 10/31/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class ActionsNavigator: BaseNavigator {
    
    // MARK: - Construction
    init() {
        let scene = ActionsViewController.instantiateFromStoryboard(storyboardName: "Main")
        super.init(scene)
        
        scene.viewModel = ActionsViewModel(navigator: self,
                                           output: scene)
    }
}

// MARK: - Navigate -
extension ActionsNavigator: Navigate {
    enum NavigateOption {
        case settings
    }
    
    func navigate(option: NavigateOption) {
        switch option {
        case .settings:
            navigationController?.pushScene(SettingsNavigator())
            break
        }
    }
}

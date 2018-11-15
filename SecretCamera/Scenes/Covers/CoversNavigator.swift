//
//  CoversNavigator.swift
//  SecretCamera
//
//  Created by MMI001 on 10/30/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class CoversNavigator: BaseNavigator {
    
    // MARK: - Construction
    init() {
        let scene = CoversViewController.instantiateFromStoryboard(storyboardName: "Main")
        super.init(scene)
        
        scene.viewModel = CoversViewModel(navigator: self, output: scene)
    }
}

// MARK: - Navigate -
extension CoversNavigator: Navigate {
    enum NavigateOption {
        case actions
    }
    
    func navigate(option: NavigateOption) {
        switch option {
        case .actions:
            navigationController?.pushScene(ActionsNavigator())
            break
        }
    }
}

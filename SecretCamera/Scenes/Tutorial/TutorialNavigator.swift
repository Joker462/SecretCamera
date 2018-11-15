//
//  TutorialNavigator.swift
//  SecretCamera
//
//  Created by MMI001 on 10/30/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class TutorialNavigator: BaseNavigator {
    
    // MARK: - Construction
    init() {
        let scene = TutorialViewController.instantiateFromStoryboard(storyboardName: "Main")
        super.init(scene)
        
        scene.viewModel = TutorialViewModel(navigator: self, output: scene)
    }
}

// MARK: - Navigate -
extension TutorialNavigator: Navigate {
    enum NavigateOption {
        case covers
    }
    
    func navigate(option: NavigateOption) {
        switch option {
        case .covers:
            navigationController?.setRootScene(CoversNavigator(), animated: true)
            break
        }
    }
}

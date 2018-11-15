//
//  VideoNavigator.swift
//  SecretCamera
//
//  Created by MMI001 on 11/7/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class VideoNavigator: BaseNavigator {
    
    // MARK: - Construction
    init() {
        let scene = VideoViewController.instantiateFromStoryboard(storyboardName: "Main")
        super.init(scene)
        
        scene.viewModel = VideoViewModel(navigator: self, output: scene)
    }
}

// MARK: - Navigate -
extension VideoNavigator: Navigate {
    enum NavigateOption {
        case dismiss
    }
    
    func navigate(option: NavigateOption) {
        switch option {
        case .dismiss:
            navigationController?.popViewController(animated: true)
            break
        }
    }
}

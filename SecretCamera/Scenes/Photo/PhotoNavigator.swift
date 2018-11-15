//
//  PhotoNavigator.swift
//  SecretCamera
//
//  Created by MMI001 on 11/12/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class PhotoNavigator: BaseNavigator {
    
    // MARK: - Construction
    init() {
        let scene = PhotoViewController.instantiateFromStoryboard(storyboardName: "Main")
        super.init(scene)
        
        scene.viewModel = PhotoViewModel(navigator: self, output: scene)
    }
}

// MARK: - Navigate -
extension PhotoNavigator: Navigate {
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

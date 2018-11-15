//
//  UINavigationController.swift
//  CoreMVVM
//
//  Created by Joker on 9/5/18.
//  Copyright © 2018 joker. All rights reserved.
//

import UIKit

// MARK: - Transition customize methods -
extension UINavigationController {
    func pushScene(_ navigator: BaseNavigator, animated: Bool = true) {
        pushViewController(navigator.scene, animated: animated)
    }
    
    func setRootScene(_ navigator: BaseNavigator, animated: Bool = false) {
        setViewControllers([navigator.scene], animated: animated)
    }
}

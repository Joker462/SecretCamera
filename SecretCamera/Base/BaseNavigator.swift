//
//  BaseNavigator.swift
//  Test
//
//  Created by MMI001 on 10/10/18.
//  Copyright © 2018 MMI001. All rights reserved.
//

import UIKit

// Navigate
protocol Navigate {
    associatedtype NavigateOption
    func navigate(option: NavigateOption)
}

class BaseNavigator {
    // Properties
    var navigationController: UINavigationController? {
        return scene.navigationController
    }
    
    var tabBarController: UITabBarController? {
        return scene.tabBarController ?? navigationController?.tabBarController
    }
    
    unowned let scene: UIViewController
    
    // Constructions
    init(_ scene: UIViewController) {
        self.scene = scene
    }
}

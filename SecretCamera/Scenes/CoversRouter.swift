//
//  CoversRouter.swift
//  SecretCamera
//
//  Created by Hung on 9/13/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

protocol CoversRouter: ViewRouter {
    func presentChooseActionView(cover: Cover)
}

class CoversRouterImplementation: CoversRouter {
    // Variables
    weak fileprivate var viewController: CoversViewController?
    
    // MARK: - Constructions
    init(viewController: CoversViewController) {
        self.viewController = viewController
    }
    
    // MARK: - SettingsRouter
    func presentChooseActionView(cover: Cover) {
        viewController?.performSegue(withIdentifier: "CoversSceneToChooseActionScene", sender: cover)
    }
    
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chooseActionViewController = segue.destination as? ChooseActionViewController, let cover = sender as? Cover {
            chooseActionViewController.configurator = ChooseActionConfiguratorImplemetation(cover: cover)
        }
    }
}


//
//  CoverPreviewRouter.swift
//  SecretCamera
//
//  Created by Hung on 9/13/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

protocol CoverPreviewRouter: ViewRouter {
    func presentSettingsView(_ cover: Cover)
    func dismissView()
}

class CoverPreviewRouterImplementation: CoverPreviewRouter {
    // Variables
    weak fileprivate var viewController: CoverPreviewViewController?
    
    // MARK: - Constructions
    init(viewController: CoverPreviewViewController) {
        self.viewController = viewController
    }
    
    // MARK: - SettingsRouter
    func presentSettingsView(_ cover: Cover) {
        viewController?.performSegue(withIdentifier: "CoverPreviewSceneToSettingsScene", sender: cover)
    }
    
    func dismissView() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsViewController = segue.destination as? SettingsViewController, let cover = sender as? Cover {
            settingsViewController.configurator = SettingsConfiguratorImplemetation(cover: cover)
        }
    }
}

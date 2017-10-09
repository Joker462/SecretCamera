//
//  ChooseActionRouter.swift
//  SecretCamera
//
//  Created by Hung on 9/20/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit
protocol ChooseActionRouter: ViewRouter {
    func presentCoverPreviewView(cover: Cover)
}

class ChooseActionRouterImplementation: ChooseActionRouter {
    
    // Variables
    weak fileprivate var viewController: ChooseActionViewController?
    
    // MARK: - Constructions
    init(viewController: ChooseActionViewController) {
        self.viewController = viewController
    }
    
    // MARK: - ChooseActionRouter
    func presentCoverPreviewView(cover: Cover) {
        viewController?.performSegue(withIdentifier: "ChooseActionSceneToCoverPreviewScene", sender: cover)
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let coverPreviewViewController = segue.destination as? CoverPreviewViewController, let cover = sender as? Cover {
            coverPreviewViewController.configurator = CoverPreviewConfiguratorImplemetation(cover: cover)
        }
    }
}

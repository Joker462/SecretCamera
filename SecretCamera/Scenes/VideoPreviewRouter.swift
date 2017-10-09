//
//  VideoPreviewRouter.swift
//  SecretCamera
//
//  Created by Hung on 9/23/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

protocol VideoPreviewRouter: ViewRouter {
    func dismissView()
}

class VideoPreviewRouterImplemetation: VideoPreviewRouter {
    // Variables
    weak fileprivate var viewController: VideoPreviewViewController?
    
    // MARK: - Constructions
    init(viewController: VideoPreviewViewController) {
        self.viewController = viewController
    }
    
    // MARK: - SettingsRouter
    func presentPhotosView() {
        viewController?.performSegue(withIdentifier: "", sender: nil)
    }
    
    func dismissView() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}


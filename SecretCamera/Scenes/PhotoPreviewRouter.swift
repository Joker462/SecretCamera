//
//  PhotoPreviewRouter.swift
//  SecretCamera
//
//  Created by Hung on 8/30/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

protocol PhotoPreviewRouter: ViewRouter {
    func dismissView()
}

class PhotoPreviewRouterImplemetation: PhotoPreviewRouter {
    // Variables
    weak fileprivate var viewController: PhotoPreviewViewController?
    
    // MARK: - Constructions
    init(viewController: PhotoPreviewViewController) {
        self.viewController = viewController
    }
    
    // MARK: - SettingsRouter
    func dismissView() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}

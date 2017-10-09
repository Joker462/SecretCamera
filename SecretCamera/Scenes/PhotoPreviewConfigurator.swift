//
//  PhotoPreviewConfigurator.swift
//  SecretCamera
//
//  Created by Hung on 8/30/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

protocol PhotoPreviewConfigurator {
    func configure(viewController: PhotoPreviewViewController)
}

class PhotoPreviewConfiguratorImplemetation: PhotoPreviewConfigurator {
    
    fileprivate let action: Action
    
    init(action: Action) {
        self.action = action
    }
    
    func configure(viewController: PhotoPreviewViewController) {
        let router = PhotoPreviewRouterImplemetation(viewController: viewController)
        let presenter = PhotoPreviewPresenterImplementation(view: viewController, router: router, action: action)
        viewController.presenter = presenter
    }
}

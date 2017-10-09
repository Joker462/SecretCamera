//
//  CoverPreviewConfigurator.swift
//  SecretCamera
//
//  Created by Hung on 9/12/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

protocol CoverPreviewConfigurator {
    func configure(viewController: CoverPreviewViewController)
}

class CoverPreviewConfiguratorImplemetation: CoverPreviewConfigurator {
    
    fileprivate let cover: Cover
    
    init(cover: Cover) {
        self.cover = cover
    }
    
    func configure(viewController: CoverPreviewViewController) {
        let router = CoverPreviewRouterImplementation(viewController: viewController)
        let presenter = CoverPreviewPresenterImplementation(view: viewController, router: router, cover: cover)
        viewController.presenter = presenter
    }
    
}

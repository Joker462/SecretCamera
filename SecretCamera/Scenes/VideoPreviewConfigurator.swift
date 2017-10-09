//
//  VideoPreviewConfigurator.swift
//  SecretCamera
//
//  Created by Hung on 9/23/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation
protocol VideoPreviewConfigurator {
    func configure(viewController: VideoPreviewViewController)
}

class VideoPreviewConfiguratorImplemetation: VideoPreviewConfigurator {
    
    fileprivate let action: Action
    
    init(action: Action) {
        self.action = action
    }
    
    func configure(viewController: VideoPreviewViewController) {
        let router = VideoPreviewRouterImplemetation(viewController: viewController)
        let presenter = VideoPreviewPresenterImplementation(view: viewController, router: router, action: action)
        viewController.presenter = presenter
    }
}

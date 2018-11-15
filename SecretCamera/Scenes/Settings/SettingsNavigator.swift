//
//  SettingsNavigator.swift
//  SecretCamera
//
//  Created by MMI001 on 11/1/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class SettingsNavigator: BaseNavigator {
    
    // MARK: - Construction
    init() {
        let scene = SettingsViewController.instantiateFromStoryboard(storyboardName: "Main")
        super.init(scene)
        
        scene.viewModel = SettingsViewModel(navigator: self, output: scene)
    }
}

// MARK: - Navigate -
extension SettingsNavigator: Navigate {
    enum NavigateOption {
        case subSettings (SettingWithOptions, IndexPath)
        case video
        case photo
    }
    
    func navigate(option: NavigateOption) {
        switch option {
        case .subSettings(let settings, let settingOptionsIndexPath):
            let subSettingsNavigator = SubSettingsNavigator(settings)
            navigationController?.pushScene(subSettingsNavigator)
            
            (subSettingsNavigator.scene as? SubSettingsViewController)?.optionTapped = { [weak self] in
                (self?.scene as? SettingsViewController)?.tableView.reloadRows(at: [settingOptionsIndexPath], with: .none)
            }
            break
        case .video:
            navigationController?.pushScene(VideoNavigator())
            break
        case .photo:
            navigationController?.pushScene(PhotoNavigator())
            break
        }
    }
}

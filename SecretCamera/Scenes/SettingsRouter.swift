//
//  SettingsRouter.swift
//  SecretCamera
//
//  Created by Hung on 8/21/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

protocol SettingsRouter: ViewRouter {
    func presentPhotoPreviewView(cover: Cover)
    func presentVideoPreview(cover: Cover)
    func presentOptionSettingsView(settingWithOptions: SettingWithOptions?, indexPath: IndexPath)
}

class SettingsRouterImplementation: SettingsRouter {
    // Variables
    weak fileprivate var viewController: SettingsViewController?
    fileprivate var indexPath: IndexPath?
    
    // MARK: - Constructions
    init(viewController: SettingsViewController) {
        self.viewController = viewController
    }
    
    // MARK: - SettingsRouter
    func presentPhotoPreviewView(cover: Cover) {
        viewController?.performSegue(withIdentifier: "SettingsSceneToPhotoPreviewScene", sender: cover)
    }
    
    func presentVideoPreview(cover: Cover) {
        viewController?.performSegue(withIdentifier: "SettingsSceneToVideoPreviewScene", sender: cover)
    }
    
    func presentOptionSettingsView(settingWithOptions: SettingWithOptions?, indexPath: IndexPath) {
        if let settingWithOptions = settingWithOptions {
            viewController?.performSegue(withIdentifier: "SettingsSceneToOptionSettingsScene", sender: settingWithOptions)
            self.indexPath = indexPath
        }
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let optionSettingsViewController = segue.destination as? OptionSettingsViewController, let settingWithOptions = sender as? SettingWithOptions {
            optionSettingsViewController.configurator = OptionSettingsConfiguratorImplemetation(settingWithOptions: settingWithOptions)
            
            optionSettingsViewController.optionTapped = {
                if let indexPath = self.indexPath {
                    DispatchQueue.main.async {
                        self.viewController?.tableView?.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        } else if let cover = sender as? Cover {
            let action = cover.actions[cover.actionIndex!]
            if let photoPreviewViewController = segue.destination as? PhotoPreviewViewController {
                photoPreviewViewController.coverViewType = cover.name == "Black" ? .Black : (cover.name == "Web" ? .Web : .Game)
                photoPreviewViewController.configurator = PhotoPreviewConfiguratorImplemetation(action: action)
            } else if let videoPreviewViewController = segue.destination as? VideoPreviewViewController {
                videoPreviewViewController.coverViewType = cover.name == "Black" ? .Black : (cover.name == "Web" ? .Web : .Game)
                videoPreviewViewController.configurator = VideoPreviewConfiguratorImplemetation(action: action)
            }
        }
    }
}

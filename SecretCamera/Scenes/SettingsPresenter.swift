//
//  SettingsPresenter.swift
//  SecretCamera
//
//  Created by Hung on 8/21/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

protocol SettingsView: class {
    func setUpTableView()
    func setNavigationBar(_ title: String)
    func showPermissionAlert(_ title: String, and message: String)
    func show(message: String)
}

protocol SettingsPresenter {
    var router: SettingsRouter { get }
    func viewDidLoad()
    func viewWillAppear()
    
    func getSettingType(_ indexPath: IndexPath) -> SettingType
    func configure(cell: BaseTableViewCellView, for indexPath: IndexPath)
    func settingValueChanged(bool: Bool, indexPath: IndexPath)
    func settingsSelected(_ indexPath: IndexPath)
    
    // Photo/Video Settings
    func getSettingsCount() -> Int
    // Camera Settings
    func getCameraSettingsCount() -> Int
    
    // Events
    func startButtonTapped()
}

class SettingsPresenterImplementation: SettingsPresenter {

    // Variables
    weak fileprivate var view:  SettingsView?
    fileprivate let cover:      Cover
    internal let router:        SettingsRouter
    
    fileprivate var isPermissionSuccess: Bool = true
    
    // MARK: - Constructions
    init(view: SettingsView, router: SettingsRouter, cover: Cover) {
        self.view = view
        self.router = router
        self.cover = cover
    }
    
    // MARK: - SettingsPresenter
    func viewDidLoad() {
        view?.setUpTableView()
        requestCameraPermission()
    }
    
    func viewWillAppear() {
        let title = cover.actionIndex == 1 ? "Video Settings" : "Photo Settings"
        view?.setNavigationBar(title)
    }
}

// MARK: - Private
private extension SettingsPresenterImplementation {
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (granted) in
            if granted {
                // Request microphone permission
                self.requestMicrophonePermission()
            } else {
                self.isPermissionSuccess = false
            }
        }
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                // Request Library premission
                self.requestLibraryPermission()
            } else {
                self.isPermissionSuccess = false
            }
        }
    }
    
    func requestLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                self.isPermissionSuccess = false
            }
        }
    }
}

// MARK: - Events
extension SettingsPresenterImplementation {
    func startButtonTapped() {
        if isPermissionSuccess, let actionIndex = cover.actionIndex {
            if cover.name == "Web", !Utils.checkConnection() {
                view?.show(message: "Internet not available.\nCross check your internet connectivity and try again")
            } else {
                if actionIndex == 0 {
                    router.presentPhotoPreviewView(cover: cover)
                } else {
                    router.presentVideoPreview(cover: cover)
                }
            }
        } else {
            view?.showPermissionAlert("Secret Camera", and: "Secret Camera doesn't have enough permission to run, please change privacy settings")
        }
    }
}

// MARK: - Settings
extension SettingsPresenterImplementation {
    
    /// Get cell type
    ///
    /// - Parameter indexPath: IndexPath
    /// - Returns: CellType
    func getSettingType(_ indexPath: IndexPath) -> SettingType {
        let actionIndex = cover.actionIndex ?? 0
        switch indexPath.section {
        case 0:
            return cover.actions[actionIndex].settings[indexPath.row].type
        default:
            return cover.actions[actionIndex].cameraSettings[indexPath.row].type
        }
    }
    
    func configure(cell: BaseTableViewCellView, for indexPath: IndexPath) {
        let actionIndex = cover.actionIndex ?? 0
        switch indexPath.section {
        case 0:
            cell.display(anyItem: cover.actions[actionIndex].settings[indexPath.row])
            break
        default:
            cell.display(anyItem: cover.actions[actionIndex].cameraSettings[indexPath.row])
            break
        }
    }
    
    func settingValueChanged(bool: Bool, indexPath: IndexPath) {
        var settingWithSwitch: SettingWithSwitch?
        let actionIndex = cover.actionIndex ?? 0
        switch indexPath.section {
        case 0:
            settingWithSwitch = cover.actions[actionIndex].settings[indexPath.row] as? SettingWithSwitch
            break
        default:
            settingWithSwitch = cover.actions[actionIndex].cameraSettings[indexPath.row] as? SettingWithSwitch
            break
        }
        settingWithSwitch?.isSelected = bool
    }
    
    func settingsSelected(_ indexPath: IndexPath) {
        var settingWithOptions: SettingWithOptions?
        let actionIndex = cover.actionIndex ?? 0
        switch indexPath.section {
        case 0:
            settingWithOptions = cover.actions[actionIndex].settings[indexPath.row] as? SettingWithOptions
            break
        default:
            settingWithOptions = cover.actions[actionIndex].cameraSettings[indexPath.row] as? SettingWithOptions
            break
        }
        router.presentOptionSettingsView(settingWithOptions: settingWithOptions, indexPath: indexPath)
    }
}

// MARK: - Photo/Video Settings
extension SettingsPresenterImplementation {
    func getSettingsCount() -> Int {
        let actionIndex = cover.actionIndex ?? 0
        return cover.actions[actionIndex].settings.count
    }
}

// MARK: - Camera Settings
extension SettingsPresenterImplementation {
    func getCameraSettingsCount() -> Int {
        let actionIndex = cover.actionIndex ?? 0
        return cover.actions[actionIndex].cameraSettings.count
    }
}

//
//  SettingsViewModel.swift
//  SecretCamera
//
//  Created by MMI001 on 11/1/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

// MARK: - Input -
protocol SettingsViewInput {
    // View cycle triggers
    func viewDidLoad()
    
    func nextTapped()
    
    // Table View control
    func getSettingsCount() -> Int
    func getCameraSettingsCount() -> Int
    func getSettingType(_ indexPath: IndexPath) -> SettingType
    func configure(cell: BaseTableViewCellView, for indexPath: IndexPath)
    func settingValueChanged(bool: Bool, indexPath: IndexPath)
    func settingsSelected(_ indexPath: IndexPath)
}

// MARK: - Output -
protocol SettingsViewOutput: class {
    func setupNavigationBar(_ title: String?)
    func setupTableView()
    
    func show(_ message: String)
}

final class SettingsViewModel: SettingsViewInput {
    
    // MARK: - Output protocol
    weak var output: SettingsViewOutput?
    
    // MARK: - Properties
    fileprivate let navigator: SettingsNavigator
    fileprivate let action: Action
    fileprivate var isPermissionSuccess: Bool = true
    
    // MARK: - Construction
    init(navigator: SettingsNavigator, output: SettingsViewOutput) {
        self.navigator = navigator
        self.output = output
        action = Database.shared.coverSelected.actions[Database.shared.coverSelected.actionIndex!]
    }
    
    // MARK: - View cycle triggers
    func viewDidLoad() {
        requestCameraPermission()
        output?.setupNavigationBar(Database.shared.coverSelected.actionIndex == 0 ? "Photo Settings" : "Video Settings")
        output?.setupTableView()
    }
    
    // MARK: - Events
    func nextTapped() {
        guard isPermissionSuccess else {
            output?.show("Secret Camera doesn't have enough permission to run, please change privacy settings")
            return
        }
        
        if Database.shared.coverSelected.actionIndex == 0 {
            // Photo
            navigator.navigate(option: .photo)
        } else {
            // Video
            navigator.navigate(option: .video)
        }
    }
}

// MARK: - Private methods -
private extension SettingsViewModel {
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
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

// MARK: - Table view control -
extension SettingsViewModel {
    func getSettingsCount() -> Int {
        return action.settings.count
    }
    
    func getCameraSettingsCount() -> Int {
        return action.cameraSettings.count
    }
    
    func getSettingType(_ indexPath: IndexPath) -> SettingType {
        switch indexPath.section {
        case 0:
            return action.settings[indexPath.row].type
        default:
            return action.cameraSettings[indexPath.row].type
        }
    }
    
    func configure(cell: BaseTableViewCellView, for indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            cell.display(anyItem: action.settings[indexPath.row])
            break
        default:
            cell.display(anyItem: action.cameraSettings[indexPath.row])
            break
        }
    }
    
    func settingValueChanged(bool: Bool, indexPath: IndexPath) {
        var settingWithSwitch: SettingWithSwitch?
        switch indexPath.section {
        case 0:
            settingWithSwitch = action.settings[indexPath.row] as? SettingWithSwitch
            break
        default:
            settingWithSwitch = action.cameraSettings[indexPath.row] as? SettingWithSwitch
            break
        }
        settingWithSwitch?.isSelected = bool
    }
    
    func settingsSelected(_ indexPath: IndexPath) {
        var settingWithOptions: SettingWithOptions?
        switch indexPath.section {
        case 0:
            settingWithOptions = action.settings[indexPath.row] as? SettingWithOptions
            break
        default:
            settingWithOptions = action.cameraSettings[indexPath.row] as? SettingWithOptions
            break
        }
        
        if let settingOptions = settingWithOptions {
            navigator.navigate(option: .subSettings(settingOptions, indexPath))
        }
    }
}

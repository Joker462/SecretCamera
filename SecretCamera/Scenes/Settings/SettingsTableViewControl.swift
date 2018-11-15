//
//  SettingsTableViewControl.swift
//  SecretCamera
//
//  Created by Hung on 9/6/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation
import UIKit

final class SettingsTableViewControl: NSObject {
    fileprivate let viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel, tableView: UITableView) {
        self.viewModel = viewModel
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource
extension SettingsTableViewControl: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Photo/Video Settings
            return viewModel.getSettingsCount()
        default:
            // Camera Settings
            return viewModel.getCameraSettingsCount()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingType = viewModel.getSettingType(indexPath)
        let cell = setUpCell(due: settingType, tableView: tableView, indexPath: indexPath)
        return cell
    }

    private func setUpCell(due toType: SettingType, tableView: UITableView, indexPath: IndexPath) -> BaseTableViewCell {
        switch toType {
        case .SettingWithSwitch:
            return tableView.dequeueReusableCell(withIdentifier: SettingSwitchCell.identifier, for: indexPath) as! SettingSwitchCell
        case .SettingLogoWithOption:
            return tableView.dequeueReusableCell(withIdentifier: SettingLogoWithValueDisclosureCell.identifier, for: indexPath) as! SettingLogoWithValueDisclosureCell
        default:
            return tableView.dequeueReusableCell(withIdentifier: SettingLogoWithSwitchCell.identifier, for: indexPath) as! SettingLogoWithSwitchCell
        }
    }
}

// MARK: - TableViewCellDelegate
extension SettingsTableViewControl: TableViewCellDelegate {
    func valueChanged(value: Bool, indexPath: IndexPath) {
        viewModel.settingValueChanged(bool: value, indexPath: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension SettingsTableViewControl: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? BaseTableViewCell {
            cell.indexPath = indexPath
            cell.delegate = self
            viewModel.configure(cell: cell, for: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 * CGFloat(ScaleValue.SCREEN_HEIGHT)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.settingsSelected(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

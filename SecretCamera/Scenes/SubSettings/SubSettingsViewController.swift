//
//  SubSettingsViewController.swift
//  SecretCamera
//
//  Created by MMI001 on 11/6/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class SubSettingsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!

    // MARK: - Properties
    var viewModel: SubSettingsViewModel!
    var optionTapped: (()->Void)?
    // MARK: - View cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
}

// MARK: - SubSettingsViewOutput - 
extension SubSettingsViewController: SubSettingsViewOutput {
    func setupTableView() {
        tableView.registerCellNib(anyClass: SettingCheckMarkCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource -
extension SubSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCheckMarkCell.identifier, for: indexPath) as! SettingCheckMarkCell
        viewModel.configure(cell: cell, for: indexPath)
        cell.setHiddenCheckMark(viewModel.checkSettingOptionSelected(indexPath))
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension SubSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            optionTapped?()
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let oldSettingOptionIndexPath = viewModel.getOldSettingOptionSelected()
        if oldSettingOptionIndexPath != indexPath {
            if let oldSelectedCell = tableView.cellForRow(at: oldSettingOptionIndexPath) as? SettingCheckMarkCell {
                oldSelectedCell.setHiddenCheckMark(true)
            }
            viewModel.settingOptionSelected(at: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

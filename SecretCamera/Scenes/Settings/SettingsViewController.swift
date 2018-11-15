//
//  SettingsViewController.swift
//  SecretCamera
//
//  Created by MMI001 on 11/1/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var viewModel: SettingsViewModel?
    fileprivate var control: SettingsTableViewControl?
    
    // MARK: - View cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
}

// MARK: - Events -
private extension SettingsViewController {
    @IBAction func nextButtonTapped() {
        viewModel?.nextTapped()
    }
}

// MARK: - SettingsViewOutput - 
extension SettingsViewController: SettingsViewOutput {
    func setupNavigationBar(_ title: String?) {
        navigationItem.title = title
    }
    
    func setupTableView() {
        // Register cells
        tableView.registerCellNib(anyClass: SettingSwitchCell.self)
        tableView.registerCellNib(anyClass: SettingLogoWithSwitchCell.self)
        tableView.registerCellNib(anyClass: SettingLogoWithValueDisclosureCell.self)
        
        tableView.tableFooterView = UIView()
        guard let viewModel = viewModel else { return }
        control = SettingsTableViewControl(viewModel: viewModel, tableView: tableView)
    }
    
    func show(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(alertController, animated: true)
    }
}

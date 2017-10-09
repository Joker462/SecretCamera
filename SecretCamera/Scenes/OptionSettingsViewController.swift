//
//  OptionSettingsViewController.swift
//  SecretCamera
//
//  Created by Hung on 9/15/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class OptionSettingsViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var tableView: UITableView?
    
    // Variables
    var configurator:   OptionSettingsConfiguratorImplemetation!
    var presenter:      OptionSettingsPresenter!
    var optionTapped: (()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(viewController: self)
        presenter.viewDidLoad()
    }
    
    deinit {
        print("Option Settings deinit")
    }
}

// MARK: - OptionSettingsView
extension OptionSettingsViewController: OptionSettingsView {
    func setUpTableView() {
        tableView?.registerCellNib(anyClass: SettingCheckMarkCell.self)
        tableView?.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension OptionSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNumberOfOptionSetting()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCheckMarkCell.identifier, for: indexPath) as! SettingCheckMarkCell
        return cell
    }
}

// MARK: - UITableViewDelegate
extension OptionSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SettingCheckMarkCell {
            cell.indexPath = indexPath
            cell.delegate = self
            presenter.configure(cell: cell, for: indexPath)
            cell.setHiddenCheckMark(presenter.checkOptionSelected(indexPath))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - TableViewCellDelegate
extension OptionSettingsViewController: TableViewCellDelegate {
    func selected(indexPath: IndexPath) {
        optionTapped?()
        if let oldSelectedCell = tableView?.cellForRow(at: presenter.getOldOptionSelected()) as? SettingCheckMarkCell {
           oldSelectedCell.setHiddenCheckMark(true)
        }
        presenter.optionSelected(indexPath.row)
        tableView?.reloadRows(at: [indexPath], with: .automatic)
    }
}

//
//  SettingsViewController.swift
//  SecretCamera
//
//  Created by Hung on 8/14/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var tableView:   UITableView?
    
    // Variables
    var configurator:   SettingsConfiguratorImplemetation!
    var presenter:      SettingsPresenter!
    fileprivate var settingsTableViewControl: SettingsTableViewControl?
    
    // MARK: - Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(viewController: self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    // MARK: - Override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        presenter.router.prepare(for: segue, sender: sender)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    deinit {
        print("Settings View deinit")
    }
}

// MARK: - SettingsView
extension SettingsViewController: SettingsView {
    func setUpTableView() {
        // Register cells
        tableView?.registerCellNib(anyClass: SettingSwitchCell.self)
        tableView?.registerCellNib(anyClass: SettingLogoWithSwitchCell.self)
        tableView?.registerCellNib(anyClass: SettingLogoWithValueDisclosureCell.self)

        tableView?.tableFooterView = UIView()
        // Set data source and delegate for table view
        settingsTableViewControl = SettingsTableViewControl(presenter: presenter, tableView: tableView)
        tableView?.reloadData()
    }
    
    func setNavigationBar(_ title: String) {
        navigationItem.title = title
    }
    
    func showPermissionAlert(_ title: String, and message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func show(message: String) {
        let alertController = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Events
extension SettingsViewController {

    @IBAction func startButtonTapped(_ sender: Any) {
        presenter.startButtonTapped()
    }
}

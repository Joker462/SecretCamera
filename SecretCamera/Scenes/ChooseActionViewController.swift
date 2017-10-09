//
//  ChooseActionViewController.swift
//  SecretCamera
//
//  Created by Hung on 9/20/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class ChooseActionViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var tableView:   UITableView?
    
    // Variables
    var configurator:   ChooseActionConfiguratorImplemetation!
    var presenter:      ChooseActionPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(viewController: self)
        presenter.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        presenter.router.prepare(for: segue, sender: sender)
    }
    
    deinit {
        print("Choose Action View deinit")
    }
}

// MARK: - ChooseActionView
extension ChooseActionViewController: ChooseActionView {
    func setUpTableView() {
        tableView?.registerCellNib(anyClass: SettingLogoWithValueDisclosureCell.self)
        tableView?.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ChooseActionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // HARDCODE Photo/Video rows
        return presenter.getActionsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingLogoWithValueDisclosureCell.identifier, for: indexPath) as! SettingLogoWithValueDisclosureCell
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChooseActionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SettingLogoWithValueDisclosureCell {
            cell.configureCell(anyItem: presenter.getAction(at: indexPath.row))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 * CGFloat(ScaleValue.SCREEN_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.actionSelected(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

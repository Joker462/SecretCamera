//
//  ActionsViewController.swift
//  SecretCamera
//
//  Created by MMI001 on 10/31/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class ActionsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: - Properties
    var viewModel: ActionsViewModel?
    
    // MARK: - View cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
}

// MARK: - ActionsViewOutput - 
extension ActionsViewController: ActionsViewOutput {
    func setupNavigationBar() {
        title = "Actions"
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.registerCellNib(anyClass: SettingLogoWithValueDisclosureCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource -
extension ActionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingLogoWithValueDisclosureCell.identifier, for: indexPath) as! SettingLogoWithValueDisclosureCell
        viewModel?.configureCell(cell, at: indexPath.row)
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension ActionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 * CGFloat(ScaleValue.SCREEN_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        viewModel?.didSelectRowAt(index: indexPath.row)
    }
}

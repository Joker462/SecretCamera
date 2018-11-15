//
//  SubSettingsViewModel.swift
//  SecretCamera
//
//  Created by MMI001 on 11/6/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import Foundation

// MARK: - Input -
protocol SubSettingsViewInput {
    // View cycle triggers
    func viewDidLoad()
    
    // Table view control
    func numberOfRows() -> Int
    func configure(cell: BaseTableViewCellView, for indexPath: IndexPath)
    func checkSettingOptionSelected(_ indexPath: IndexPath) -> Bool
    func getOldSettingOptionSelected() -> IndexPath
    func settingOptionSelected(at index: Int)
}

// MARK: - Output -
protocol SubSettingsViewOutput: class {
    func setupTableView()
}

final class SubSettingsViewModel: SubSettingsViewInput {
    
    // MARK: - Output protocol
    weak var output: SubSettingsViewOutput?
    
    // MARK: - Properties
    fileprivate let navigator: SubSettingsNavigator
    fileprivate let settings: SettingWithOptions
    
    // MARK: - Construction
    init(navigator: SubSettingsNavigator,
         output: SubSettingsViewOutput,
         settings: SettingWithOptions) {
        self.navigator = navigator
        self.output = output
        self.settings = settings
    }
    
    // MARK: - View cycle triggers
    func viewDidLoad() {
        output?.setupTableView()
    }
}

// MARK: - Table view control -
extension SubSettingsViewModel {
    func numberOfRows() -> Int {
        return settings.options.count
    }
    
    func configure(cell: BaseTableViewCellView, for indexPath: IndexPath) {
        cell.display(anyItem: settings.options[indexPath.row])
    }
    
    func checkSettingOptionSelected(_ indexPath: IndexPath) -> Bool {
        return settings.index != indexPath.row
    }
    
    func getOldSettingOptionSelected() -> IndexPath {
        return IndexPath(row: settings.index, section: 0)
    }
    
    func settingOptionSelected(at index: Int) {
        settings.index = index
    }
}

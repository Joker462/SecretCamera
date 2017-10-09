//
//  OptionSettingsPresenter.swift
//  SecretCamera
//
//  Created by Hung on 9/15/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

protocol OptionSettingsView: class {
    func setUpTableView()
}

protocol OptionSettingsPresenter {
    func viewDidLoad()
    func getNumberOfOptionSetting() -> Int
    func configure(cell: BaseTableViewCellView, for indexPath: IndexPath)
    func checkOptionSelected(_ indexPath: IndexPath) -> Bool
    func getOldOptionSelected() -> IndexPath
    func optionSelected(_ index: Int)
}

final class OptionSettingsPresenterImplementation: OptionSettingsPresenter {
    
    fileprivate weak var view: OptionSettingsView?
    fileprivate let settingWithOptions: SettingWithOptions
    
    init(view: OptionSettingsView, settingWithOptions: SettingWithOptions) {
        self.view = view
        self.settingWithOptions = settingWithOptions
    }
    
    // MARK: - OptionSettingsPresenter
    func viewDidLoad() {
        view?.setUpTableView()
    }
    
    func getNumberOfOptionSetting() -> Int {
        return settingWithOptions.options.count
    }
    
    func configure(cell: BaseTableViewCellView, for indexPath: IndexPath) {
        cell.display(anyItem: settingWithOptions.options[indexPath.row])
    }
    
    func checkOptionSelected(_ indexPath: IndexPath) -> Bool {
        return settingWithOptions.index != indexPath.row
    }
    
    func getOldOptionSelected() -> IndexPath {
        return IndexPath(row: settingWithOptions.index, section: 0)
    }
    
    func optionSelected(_ index: Int) {
        settingWithOptions.index = index
    }
}

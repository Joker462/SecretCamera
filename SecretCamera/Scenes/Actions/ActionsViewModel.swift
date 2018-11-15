//
//  ActionsViewModel.swift
//  SecretCamera
//
//  Created by MMI001 on 10/31/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import Foundation

// MARK: - Input -
protocol ActionsViewInput {
    // View cycle triggers
    func viewDidLoad()
    // Table view
    func numberOfRows() -> Int
    func configureCell(_ cell: BaseTableViewCell, at index: Int)
    func didSelectRowAt(index: Int)
}

// MARK: - Output -
protocol ActionsViewOutput: class {
    func setupNavigationBar()
    func setupTableView()
}

final class ActionsViewModel: ActionsViewInput {
    
    // MARK: - Output protocol
    weak var output: ActionsViewOutput?
    
    // MARK: - Properties
    fileprivate let navigator: ActionsNavigator
    
    // MARK: - Construction
    init(navigator: ActionsNavigator, output: ActionsViewOutput) {
        self.navigator = navigator
        self.output = output
    }
    
    // MARK: - View cycle triggers
    func viewDidLoad() {
        output?.setupNavigationBar()
        output?.setupTableView()
    }
    
    // MARK: - Table view
    func numberOfRows() -> Int {
        return Database.shared.coverSelected.actions.count
    }
    
    func configureCell(_ cell: BaseTableViewCell, at index: Int) {
        cell.configureCell(anyItem: Database.shared.coverSelected.actions[index])
    }
    
    func didSelectRowAt(index: Int) {
        Database.shared.coverSelected.actionIndex = index
        navigator.navigate(option: .settings)
    }
}

//
//  CoversViewModel.swift
//  SecretCamera
//
//  Created by MMI001 on 10/30/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import Foundation

// MARK: - Input -
protocol CoversViewInput {
    // View cycle triggers
    func viewDidLoad()
    // Events
    func nextTapped()
    // iCarousel Control
    func numberOfItems() -> Int
    func didSelectItemAt(at index: Int)
    func getCoverImageNamed(at index: Int) -> String
    func getCoverName(at index: Int) -> String
}

// MARK: - Output -
protocol CoversViewOutput: class {
    func setupNavigationBar()
    func setupCarouselView()
}

final class CoversViewModel: CoversViewInput {
    
    // MARK: - Output protocol
    weak var output: CoversViewOutput?
    
    // MARK: - Properties
    fileprivate let navigator: CoversNavigator
    
    // MARK: - Construction
    init(navigator: CoversNavigator, output: CoversViewOutput) {
        self.navigator = navigator
        self.output = output
    }
    
    // MARK: - View cycle triggers
    func viewDidLoad() {
        output?.setupNavigationBar()
        output?.setupCarouselView()
    }
}

// MARK: - iCarousel control -
extension CoversViewModel {
    func numberOfItems() -> Int {
        return Database.shared.covers.count
    }
    
    func didSelectItemAt(at index: Int) {
        Database.shared.coverIndexSelected = index
    }
    
    func getCoverName(at index: Int) -> String {
        return Database.shared.covers[index].name
    }
    
    func getCoverImageNamed(at index: Int) -> String {
        return Database.shared.covers[index].imageNamed
    }
}

// MARK: - Events -
extension CoversViewModel {
    func nextTapped() {
        navigator.navigate(option: .actions)
    }
}

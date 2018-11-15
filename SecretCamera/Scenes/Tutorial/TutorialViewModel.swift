//
//  TutorialViewModel.swift
//  SecretCamera
//
//  Created by MMI001 on 10/30/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import Foundation

struct Tutorial {
    let title: String
    let imageNamed: String
}

// MARK: - Input -
protocol TutorialViewInput {
    // View cycle triggers
    func viewDidLoad()
    
    func getTitleSubview(at index: Int) -> String
    func getImageNamedSubview(at index: Int) -> String
    
    func skipTapped()
}

// MARK: - Output -
protocol TutorialViewOutput: class {
    // subview of scrollview
    func createSubviewForScrollView(with totalSubview: Int)
}

final class TutorialViewModel: TutorialViewInput {
    
    // MARK: - Output protocol
    weak var output: TutorialViewOutput?
    
    // MARK: - Properties
    fileprivate let navigator: TutorialNavigator
    fileprivate let tutorials: [Tutorial] = [Tutorial(title: "Choose a cover view", imageNamed: "tutorial_1"),
                                             Tutorial(title: "Choose an action", imageNamed: "tutorial_2"),
                                             Tutorial(title: "Setup settings", imageNamed: "tutorial_3")]
    
    // MARK: - Construction
    init(navigator: TutorialNavigator, output: TutorialViewOutput) {
        self.navigator = navigator
        self.output = output
    }
    
    // MARK: - View cycle triggers
    func viewDidLoad() {
        output?.createSubviewForScrollView(with: tutorials.count)
    }
}


// MARK: - ScrollView methods -
extension TutorialViewModel {
    func getTitleSubview(at index: Int) -> String {
        return tutorials[index].title
    }
    
    func getImageNamedSubview(at index: Int) -> String {
        return tutorials[index].imageNamed
    }
}

// MARK: - Events -
extension TutorialViewModel {
    func skipTapped() {
        Utils.saveItemUserDefault(identifier: "secret_camera_skip_tutorial", value: true)
        navigator.navigate(option: .covers)
    }
}

//
//  CoversViewController.swift
//  SecretCamera
//
//  Created by MMI001 on 10/30/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class CoversViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet fileprivate weak var iCarouselView: iCarousel!
    
    // MARK: - Properties
    var viewModel: CoversViewModel?
    fileprivate var control: CoversCarouselControl?
    
    // MARK: - View cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
}

// MARK: - Events -
private extension CoversViewController {
    @IBAction func nextButtonTapped() {
        viewModel?.nextTapped()
    }
}

// MARK: - CoversViewOutput - 
extension CoversViewController: CoversViewOutput {
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        title = "Covers"
    }
    
    func setupCarouselView() {
        guard let viewModel = viewModel else { return }
        control = CoversCarouselControl(viewModel: viewModel, carouselView: iCarouselView)
    }
}

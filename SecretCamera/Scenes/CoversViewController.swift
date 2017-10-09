//
//  CoversViewController.swift
//  SecretCamera
//
//  Created by Hung on 9/7/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class CoversViewController: UIViewController {
    
    // IBOutlets 
    @IBOutlet weak var carouselView:    iCarousel?
    
    // Variables
    let configurator =  CoversConfiguratorImplemetation()
    var presenter:      CoversPresenter!

    fileprivate var coversCarouselControl: CoversCarouselControl?
    
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
    
    deinit {
        print("Cover View deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        presenter.router.prepare(for: segue, sender: sender)
    }
}

// MARK: - Events
extension CoversViewController {
    @IBAction func nextButtonTapped(_ sender: Any) {
        presenter.nextButtonTapped()
    }
}

// MARK: - CoversView
extension CoversViewController: CoversView {
    
    func setUpCarouselView() {
        coversCarouselControl = CoversCarouselControl(presenter: presenter, carouselView: carouselView)
        carouselView?.type = .linear
        carouselView?.bounces = false
        carouselView?.reloadData()
    }
    
    func showNavigationBar(_ title: String) {
        navigationItem.title = title
    }
}


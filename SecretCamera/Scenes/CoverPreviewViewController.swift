//
//  CoverPreviewViewController.swift
//  SecretCamera
//
//  Created by Hung on 9/11/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class CoverPreviewViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var nextButton: UIButton?
    
    // Variables
    var configurator:   CoverPreviewConfiguratorImplemetation!
    var presenter:      CoverPreviewPresenter!
    
    // MARK: - Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        configurator.configure(viewController: self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        print("Cover Preview View deinit")
    }
    
    // MARK: - Override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        presenter.router.prepare(for: segue, sender: sender)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Events
    func previewViewTapped(_ sender: UITapGestureRecognizer) {
        presenter.previewViewTapped()
    }
    
    func previewViewSwipeRight(_ sender: UISwipeGestureRecognizer) {
        presenter.previewViewSwipeRight()
    }
    
    func previewViewSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        presenter.previewViewSwipeLeft()
    }
    
    @IBAction private func nextButtonTapped(_ sender: Any) {
        presenter.previewViewTapped()
    }
}

// MARK: - CoverPreviewView
extension CoverPreviewViewController: CoverPreviewView {
    func setUpPreview(_ imageNamed: String) {
        let offsetY: CGFloat = DeviceType.IPHONE_X ? (Screen.HEIGHT - 667) : 0
        let previewImageView = UIImageView(frame: CGRect(x: 0, y: offsetY/2, width: Screen.WIDTH, height: Screen.HEIGHT - offsetY))
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.image = UIImage(named: imageNamed)
        view.insertSubview(previewImageView, belowSubview: nextButton!)
    }
    
    func setUpTapOnPreviewEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewViewTapped(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setUpSwipeRightOnPreviewEvent() {
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(previewViewSwipeRight(_:)))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
    }
    
    func setUpSwipeLeftOnPreviewEvent() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(previewViewSwipeLeft(_:)))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
    }
}

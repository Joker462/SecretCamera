//
//  PhotoPreviewViewController.swift
//  SecretCamera
//
//  Created by Hung on 8/17/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit
import AVFoundation

enum CoverViewType {
    case Black
    case Web
    case Game
}

class PhotoPreviewViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var previewView:     PreviewView?
    fileprivate var coverView:          UIView?
    
    // Variables
    var configurator:   PhotoPreviewConfiguratorImplemetation!
    var presenter:      PhotoPreviewPresenter!
    var coverViewType:  CoverViewType = .Black
    
    // MARK: - Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(viewController: self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if coverViewType != .Web {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
        presenter.viewWillAppear(coverViewType: coverViewType)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if coverViewType != .Web {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        presenter.viewWillDisappear()
    }
    
    override var prefersStatusBarHidden: Bool {
        return coverViewType != .Web
    }
    
    deinit {
        print("Photo Preview View deinit")
    }
}

// MARK: - Cover View
extension PhotoPreviewViewController: UITextFieldDelegate {
    func setUpCoverView() {
        if coverViewType == .Black {
            coverView = BlackCoverView(frame: CGRect(x: 0, y: 0, width: Screen.WIDTH, height: Screen.HEIGHT))
            view.insertSubview(coverView!, aboveSubview: previewView!)
            
            (coverView as? BlackCoverView)?.captureButtonTapped = { [weak self] in
                self?.presenter.captureButtonTapped()
            }
            (coverView as? BlackCoverView)?.doubleTap = { [weak self] in
                self?.presenter.dismissView()
            }
        } else if coverViewType == .Web {
            coverView = WebCoverView(frame: CGRect(x: 0, y: 0, width: Screen.WIDTH, height: Screen.HEIGHT))
            view.insertSubview(coverView!, aboveSubview: previewView!)
        } else {
            coverView = GameCoverView(frame: CGRect(x: 0, y: 0, width: Screen.WIDTH, height: Screen.HEIGHT))
            view.insertSubview(coverView!, aboveSubview: previewView!)
            
            (coverView as? GameCoverView)?.captureButtonTapped = { [weak self] in
                self?.presenter.captureButtonTapped()
            }
            (coverView as? GameCoverView)?.doneButtonTapped = { [weak self] in
                self?.presenter.dismissView()
            }
        }
    }
    
    func setUpCaptureButton(_ hidden: Bool) {
        if coverViewType == .Black, let blackCoverView = coverView as? BlackCoverView {
            blackCoverView.createCaptureButton(hidden)
        }
        if coverViewType == .Game, let gameCoverView = coverView as? GameCoverView {
            gameCoverView.createCaptureButton(hidden)
        }
    }
    
    // Navigation Bar for Web Cover
    func setUpNavigationBarForWebCoverView() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonBarTapped(_:)))
        navigationItem.leftBarButtonItem = doneButton
        
        let captureButton = UIBarButtonItem(image: UIImage(named: "capture_logo"), style: .plain, target: self, action: #selector(captureButtonBarTapped(_:)))
        navigationItem.rightBarButtonItem = captureButton
        
        let searchTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 200 * (Screen.WIDTH/375), height: 30 * (Screen.HEIGHT/667)))
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = UIColor.white
        searchTextField.text = "apple.com"
        searchTextField.returnKeyType = .go
        searchTextField.delegate = self
        navigationItem.titleView = searchTextField
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            if let webCoverView = self.coverView as? WebCoverView {
                webCoverView.load("apple.com")
            }
        }
        
    }
    @objc
    func doneButtonBarTapped(_ sender: Any) {
        presenter.dismissView()
    }
    
    @objc
    func captureButtonBarTapped(_ sender: Any) {
        presenter.captureButtonTapped()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let webCoverView = coverView as? WebCoverView {
            webCoverView.load(textField.text ?? "")
        }
        return false
    }
}

// MARK: - CameraPreviewView
extension PhotoPreviewViewController: PhotoPreviewView {
    func setUpVideoPreview(session: AVCaptureSession) {
        // Set up the video preview view.
        previewView?.session = session
    }
    
    func setCameraPreview(_ videoOrientation: AVCaptureVideoOrientation) {
        previewView?.videoPreviewLayer.connection.videoOrientation = videoOrientation
    }
    
    func showAnimationCaptureOnPreview() {
        previewView?.videoPreviewLayer.opacity = 0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.previewView?.videoPreviewLayer.opacity = 1
        }
    }
    
    func applicationDidEnterBackground() {
        if let gameCoverView = coverView as? GameCoverView {
            gameCoverView.endGame()
        }
    }
}

//
//  VideoPreviewViewController.swift
//  SecretCamera
//
//  Created by Hung on 9/22/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPreviewViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var previewView: PreviewView?
    fileprivate var coverView:  UIView?
    
    // Variables
    var configurator:   VideoPreviewConfiguratorImplemetation!
    var presenter:      VideoPreviewPresenter!
    var coverViewType:  CoverViewType = .Black
    
    // MARK: Life cycles
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
        print("Video Preview View deinit")
    }
}

// MARK: - CoverView
extension VideoPreviewViewController: UITextFieldDelegate {
    func setUpCoverView() {
        if coverViewType == .Black {
            coverView = BlackCoverView(frame: CGRect(x: 0, y: 0, width: Screen.WIDTH, height: Screen.HEIGHT))
            view.insertSubview(coverView!, aboveSubview: previewView!)
            (coverView as? BlackCoverView)?.doubleTap = { [weak self] in
                self?.presenter.dismissView()
            }
        } else if coverViewType == .Web {
            coverView = WebCoverView(frame: CGRect(x: 0, y: 0, width: Screen.WIDTH, height: Screen.HEIGHT))
            view.insertSubview(coverView!, aboveSubview: previewView!)
        } else {
            coverView = GameCoverView(frame: CGRect(x: 0, y: 0, width: Screen.WIDTH, height: Screen.HEIGHT))
            view.insertSubview(coverView!, aboveSubview: previewView!)
            
            (coverView as? GameCoverView)?.doneButtonTapped = { [weak self] in
                self?.presenter.dismissView()
            }
        }
    }
    
    func setUpNavigationBarForWebCoverView() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonBarTapped(_:)))
        navigationItem.leftBarButtonItem = doneButton
        
        let searchTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 200 * ScaleValue.SCREEN_WIDTH, height: 30 * ScaleValue.SCREEN_HEIGHT))
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = UIColor.white
        searchTextField.text = "apple.com"
        searchTextField.returnKeyType = .go
        searchTextField.delegate = self
        navigationItem.titleView = searchTextField
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            if let webCoverView = self?.coverView as? WebCoverView {
                webCoverView.load("apple.com")
            }
        }
    }
    @objc
    func doneButtonBarTapped(_ sender: Any) {
        presenter.dismissView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let webCoverView = coverView as? WebCoverView {
            webCoverView.load(textField.text ?? "")
        }
        return false
    }
}

// MARK: - VideoPreviewView
extension VideoPreviewViewController: VideoPreviewView {
    func setUpVideoPreview(session: AVCaptureSession) {
        // Set up the video preview view.
        previewView?.session = session
    }
    
    func setCameraPreview(_ videoOrientation: AVCaptureVideoOrientation) {
        previewView?.videoPreviewLayer.connection.videoOrientation = videoOrientation
    }
    
    func showAnimationStartRecordOnPreview() {
        previewView?.videoPreviewLayer.opacity = 0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.previewView?.videoPreviewLayer.opacity = 1
        }
    }
    
    func applicationWillResignActive() {
        if let gameCoverView = coverView as? GameCoverView {
            gameCoverView.endGame()
        }
    }
}

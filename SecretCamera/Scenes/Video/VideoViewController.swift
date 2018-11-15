//
//  VideoViewController.swift
//  SecretCamera
//
//  Created by MMI001 on 11/7/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var previewView: PreviewView!
    
    // MARK: - Properties
    fileprivate var coverView:  UIView?
    var viewModel: VideoViewModel?
    
    // MARK: - View cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: .UIApplicationWillResignActive, object: nil)
        viewModel?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        viewModel?.viewWillDisappear()
    }
    
    override var prefersStatusBarHidden: Bool {
        return viewModel!.prefersStatusBarHidden()
    }
    
    deinit {
        print("Video scene deinit")
    }
    
    @objc
    private func applicationWillResignActive() {
        (coverView as? GameCoverView)?.endGame()
        viewModel?.applicationWillResignActive()
    }
}

// MARK: - Event methods -
private extension VideoViewController {
    @objc func doneButtonTapped() {
        viewModel?.dimiss()
    }
}

// MARK: - VideoViewOutput - 
extension VideoViewController: VideoViewOutput {
    func setupBlackCover() {
        let blackCover = BlackCoverView(frame: UIScreen.main.bounds)
        view.insertSubview(blackCover, aboveSubview: previewView)
        
        blackCover.doubleTap = { [weak self] in
            self?.viewModel?.dimiss()
        }
        coverView = blackCover
    }
    
    func setupGameCover() {
        let gameCover = GameCoverView(frame: UIScreen.main.bounds)
        view.insertSubview(gameCover, aboveSubview: previewView)

        gameCover.doneButtonTapped = { [weak self] in
            self?.viewModel?.dimiss()
        }
        coverView = gameCover
    }
    
    func setupWebCover() {
        setupNavigationBar()
        let webCover = WebCoverView(frame: UIScreen.main.bounds)
        view.insertSubview(webCover, aboveSubview: previewView)
        webCover.requestFinished = { [weak self] url in
            (self?.navigationItem.titleView as? UITextField)?.text = url
        }
        coverView = webCover
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
            guard let _ = self else { return }
            webCover.load("google.com")
        }
    }
    
    func setNavigationBar(isHidden: Bool) {
        navigationController?.setNavigationBarHidden(isHidden, animated: true)
    }
    
    func setupVideoPreview(session: AVCaptureSession) {
        previewView.session = session
    }
    
    func setCameraPreview(videoOrientation: AVCaptureVideoOrientation) {
        previewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
    }
    
    func showStartRecordAnimation() {
        previewView?.videoPreviewLayer.opacity = 0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.previewView?.videoPreviewLayer.opacity = 1
        }
    }
}

// MARK: - Private methods -
private extension VideoViewController {
    func setupNavigationBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.leftBarButtonItem = doneButton
        
        let searchTextField = UITextField(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: 200*ScaleValue.SCREEN_HEIGHT, height: 30*ScaleValue.SCREEN_HEIGHT))
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = .white
        searchTextField.text = "google.com"
        searchTextField.returnKeyType = .go
        searchTextField.delegate = self
        navigationItem.titleView = searchTextField
    }
}

// MARK: - UITextFieldDelegate -
extension VideoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webCover = coverView as? WebCoverView {
            webCover.load(textField.text ?? "")
        }
        return textField.resignFirstResponder()
    }
}

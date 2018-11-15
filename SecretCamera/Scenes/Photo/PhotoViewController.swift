//
//  PhotoViewController.swift
//  SecretCamera
//
//  Created by MMI001 on 11/12/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit
import AVFoundation

final class PhotoViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var previewView:     PreviewView!
    fileprivate var coverView:          UIView?
    
    // MARK: - Properties
    var viewModel: PhotoViewModel?
    
    // MARK: - View cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return viewModel!.prefersStatusBarHidden()
    }
}

// MARK: - Events -
extension PhotoViewController {
    @objc
    private func applicationWillEnterForeground() {
        viewModel?.applicationWillEnterForeground()
    }
    
    @objc func applicationDidEnterBackground() {
        (coverView as? GameCoverView)?.endGame()
        viewModel?.applicationDidEnterBackground()
    }
    
    @objc
    private func doneButtonBarTapped(_ sender: Any) {
        viewModel?.dismiss()
    }
    
    @objc
    private func captureButtonBarTapped(_ sender: Any) {
        viewModel?.capture()
    }
}

// MARK: - PhotoViewOutput - 
extension PhotoViewController: PhotoViewOutput {
    
    func setupBlackCover() {
        let blackView = BlackCoverView(frame: UIScreen.main.bounds)
        blackView.captureButtonTapped = { [weak self] in
            self?.viewModel?.capture()
        }
        
        blackView.doubleTap = { [weak self] in
            self?.viewModel?.dismiss()
        }
        
        view.insertSubview(blackView, aboveSubview: previewView)
        coverView = blackView
    }
    
    func setupGameCover() {
        let gameView = GameCoverView(frame: UIScreen.main.bounds)
        gameView.captureButtonTapped = { [weak self] in
            self?.viewModel?.capture()
        }
        
        gameView.doneButtonTapped = { [weak self] in
            self?.viewModel?.dismiss()
        }
        
        view.insertSubview(gameView, aboveSubview: previewView)
        coverView = gameView
    }
    
    func setupWebCover() {
        setupNavigationBar()
        let webView = WebCoverView(frame: UIScreen.main.bounds)
        view.insertSubview(webView, aboveSubview: previewView)
        coverView = webView
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
            guard let _ = self else { return }
            webView.load("google.com")
        }
    }
    
    func setNavigationBar(isHidden: Bool) {
        navigationController?.setNavigationBarHidden(isHidden, animated: true)
    }
    
    func setupCaptureButton(_ hidden: Bool) {
        DispatchQueue.main.async { [weak self] in
            (self?.coverView as? BlackCoverView)?.createCaptureButton(hidden)
            (self?.coverView as? GameCoverView)?.createCaptureButton(hidden)
        }
    }
    
    func setupVideoPreview(session: AVCaptureSession) {
        // Set up the video preview view.
        previewView?.session = session
    }
    
    func setCameraPreview(videoOrientation: AVCaptureVideoOrientation) {
        previewView?.videoPreviewLayer.connection?.videoOrientation = videoOrientation
    }
    
    func showAnimationCaptureOnPreview() {
        previewView?.videoPreviewLayer.opacity = 0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.previewView?.videoPreviewLayer.opacity = 1
        }
    }
}

// MARK: - Private methods -
private extension PhotoViewController {
    func setupNavigationBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonBarTapped(_:)))
        navigationItem.leftBarButtonItem = doneButton
        
        let captureButton = UIBarButtonItem(image: UIImage(named: "capture_logo"), style: .plain, target: self, action: #selector(captureButtonBarTapped(_:)))
        navigationItem.rightBarButtonItem = captureButton
        
        let searchTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 200*ScaleValue.SCREEN_HEIGHT, height: 30*ScaleValue.SCREEN_HEIGHT))
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = UIColor.white
        searchTextField.text = "google.com"
        searchTextField.returnKeyType = .go
        searchTextField.delegate = self
        navigationItem.titleView = searchTextField
    }
}

// MARK: - UITextFieldDelegate -
extension PhotoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webCoverView = coverView as? WebCoverView {
            webCoverView.load(textField.text ?? "")
        }
        return textField.resignFirstResponder()
    }
}

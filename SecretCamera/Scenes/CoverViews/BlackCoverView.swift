//
//  BlackCoverView.swift
//  SecretCamera
//
//  Created by Hung on 9/25/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class BlackCoverView: UIView {
    
    // Variables
    var doubleTap:  (() -> Void)?
    var captureButtonTapped: (() -> Void)?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        backgroundColor = UIColor.black
        setUpEvents()
    }
    
    // Create Capture Button
    func createCaptureButton(_ isHidden: Bool) {
        let captureImage = UIImage(named: "capture_logo")
        let captureFrame = CGRect(x: Screen.WIDTH - (captureImage!.size.width + 12), y: 30, width: captureImage!.size.width, height: captureImage!.size.height)
        let captureButton = UIButton(frame: captureFrame)
        captureButton.setImage(captureImage, for: .normal)
        captureButton.alpha = isHidden ? 0.011 : 1
        addSubview(captureButton)
        
        captureButton.addTarget(self, action: #selector(captureTapped(_:)), for: .touchUpInside)
    }
}

// MARK: Events
extension BlackCoverView {
    func setUpEvents() {
        // Double Tap Gesture
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)
    
        // Swipe Right Gesture
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRightGesture.direction = .right
        self.addGestureRecognizer(swipeRightGesture)
        
        // Swipe Left Gesture
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeftGesture.direction = .left
        self.addGestureRecognizer(swipeLeftGesture)
    }
    // @objc methods
    @objc
    fileprivate func captureTapped(_ sender: Any) {
        captureButtonTapped?()
    }
    
    @objc
    private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        doubleTap?()
    }
    
    @objc
    private func handleSwipeRight(_ sender: UISwipeGestureRecognizer) {
        if self.alpha == 1 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 0.011
                })
            }
        }
    }
    
    @objc
    private func handleSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        if self.alpha <= 0.011 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}

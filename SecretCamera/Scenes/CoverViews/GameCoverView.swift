//
//  GameCoverView.swift
//  SecretCamera
//
//  Created by Hung on 9/28/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class GameCoverView: UIView {

    // Variables
    fileprivate var scoreLabel:         UILabel?
    fileprivate var questionLabel:      UILabel?
    fileprivate var playButton:         UIButton?
    fileprivate var correctButton:      UIButton?
    fileprivate var irCorrectButton:    UIButton?
    fileprivate var progressView:       UIProgressView?
    
    fileprivate let padding: CGFloat    = 50
    fileprivate var score: Int          = 0
    fileprivate var isCorrect: Bool     = false
    fileprivate var timer: Timer?
    
    var captureButtonTapped: (() -> Void)?
    var doneButtonTapped: (() -> Void)?
    
    override func draw(_ rect: CGRect) {
        backgroundColor = UIColor(hex: "#9A9A9A")
        createUI(rect: rect)
        setUpEvents()
        createDoneButton()
        super.draw(rect)
    }
    
    func createCaptureButton(_ isHidden: Bool) {
        let captureImage = UIImage(named: "capture_logo")
        let captureFrame = CGRect(x: Screen.WIDTH - (captureImage!.size.width + 12), y: 30, width: captureImage!.size.width, height: captureImage!.size.height)
        let captureButton = UIButton(frame: captureFrame)
        captureButton.setImage(captureImage, for: .normal)
        captureButton.alpha = isHidden ? 0.011 : 1
        addSubview(captureButton)
        
        captureButton.addTarget(self, action: #selector(captureTapped(_:)), for: .touchUpInside)
    }

    func createDoneButton() {
        let offsetY: CGFloat = DeviceType.IPHONE_X ? 35 : 15
        let doneImage = UIImage(named: "done_logo")
        let doneFrame = CGRect(x: 15, y: offsetY, width: doneImage!.size.width, height: doneImage!.size.height)
        let doneButton = UIButton(frame: doneFrame)
        doneButton.setImage(doneImage, for: .normal)
        doneButton.alpha = isHidden ? 0.011 : 1
        addSubview(doneButton)
        
        doneButton.addTarget(self, action: #selector(doneTapped(_:)), for: .touchUpInside)
    }
    
    func endGame() {
        timer?.invalidate()
        progressView?.progress = 1
        questionLabel?.text = ""
        irCorrectButton?.isHidden = true
        correctButton?.isHidden = true
        playButton?.isHidden = false
    }
}

// MARK: - Private methods
private extension GameCoverView {
    func createUI(rect: CGRect) {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView?.trackTintColor = .clear
        progressView?.frame = CGRect(x: 0, y: rect.height - 2, width: rect.size.width, height: 2)
        progressView?.progress = 1
        
        scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        scoreLabel?.textColor = UIColor.white
        scoreLabel?.textAlignment = .center
        scoreLabel?.font = UIFont.boldSystemFont(ofSize: 40 * CGFloat(ScaleValue.FONT))
        scoreLabel?.center = CGPoint(x: rect.size.width/2, y: padding + 25)
        scoreLabel?.text = "\(score)"
        
        questionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200 * ScaleValue.SCREEN_WIDTH, height: 120 * ScaleValue.SCREEN_HEIGHT))
        questionLabel?.textColor = UIColor.white
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 40 * CGFloat(ScaleValue.FONT))
        questionLabel?.textAlignment = .center
        questionLabel?.numberOfLines = 0
        questionLabel?.center = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
        questionLabel?.text = "Crazy\nMath"
        
        let buttonSize: CGFloat = 100 * CGFloat(ScaleValue.SCREEN_WIDTH)
        playButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        playButton?.center = CGPoint(x: rect.size.width/2, y: rect.size.height - (padding + (buttonSize/2)))
        playButton?.setImage(UIImage(named: "play_button"), for: .normal)
        playButton?.setImage(UIImage(named: "play_button_highlight"), for: .highlighted)
        playButton?.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        
        correctButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        correctButton?.center = CGPoint(x: padding + (buttonSize/2), y: rect.size.height - (padding + (buttonSize/2)))
        correctButton?.setImage(UIImage(named: "correct_button"), for: .normal)
        correctButton?.setImage(UIImage(named: "correct_button_highlight"), for: .highlighted)
        correctButton?.addTarget(self, action: #selector(correctButtonTapped(_:)), for: .touchUpInside)
        correctButton?.isHidden = true
        
        irCorrectButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        irCorrectButton?.center = CGPoint(x: rect.size.width - (padding + (buttonSize/2)), y: rect.size.height - (padding + (buttonSize/2)))
        irCorrectButton?.setImage(UIImage(named: "ircorrect_button"), for: .normal)
        irCorrectButton?.setImage(UIImage(named: "ircorrect_button_highlight"), for: .highlighted)
        irCorrectButton?.addTarget(self, action: #selector(irCorrectButtonTapped(_:)), for: .touchUpInside)
        irCorrectButton?.isHidden = true
        
        insertSubview(progressView!, at: 2)
        insertSubview(scoreLabel!, at: 1)
        insertSubview(questionLabel!, at: 1)
        insertSubview(playButton!, at: 1)
        insertSubview(correctButton!, at: 1)
        insertSubview(irCorrectButton!, at: 1)
    }
    
    func startGame() {
        let a = random(min: 0, max: 10)
        let b = random(min: 0, max: 10)
        var result = random(min: 0, max: 20)
        
        if random(min: 0, max: 1) == 0 {
            // Minus
            if a > b {
                result = random(min: 0, max: 100) <= 75 ? (a - b) : result
                questionLabel?.text = "\(a) - \(b)\n= \(result)"
                isCorrect = (a - b == result)
            } else {
                result = random(min: 0, max: 100) <= 75 ? (b - a) : result
                questionLabel?.text = "\(b) - \(a)\n = \(result)"
                isCorrect = (b - a == result)
            }
        } else {
            // Add
            result = random(min: 0, max: 100) <= 75 ? (a + b) : result
            questionLabel?.text = "\(a) + \(b)\n= \(result)"
            isCorrect = (a + b == result)
        }
        startTimer()
    }
    
    func random(min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
    
    func startTimer() {
        progressView?.progress = 1
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_) in
            self.progressView?.progress = self.progressView!.progress - 0.1
            if self.progressView?.progress == 0 {
                // End Game
                self.endGame()
            }
        })
    }
    
}

// MARK: - Events
private extension GameCoverView {
    func setUpEvents() {
        // Swipe Right Gesture
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRightGesture.direction = .right
        self.addGestureRecognizer(swipeRightGesture)
        
        // Swipe Left Gesture
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeftGesture.direction = .left
        self.addGestureRecognizer(swipeLeftGesture)
    }
    // MARK: - @objc methods
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
    
    @objc
    func playButtonTapped(_ sender: Any) {
        score = 0
        scoreLabel?.text = "\(score)"
        
        playButton?.isHidden = true
        correctButton?.isHidden = false
        irCorrectButton?.isHidden = false
        
        // Start game
        startGame()
    }
    
    @objc
    func correctButtonTapped(_ sender: Any) {
        if !isCorrect { endGame() }
        score = score + 1
        scoreLabel?.text = "\(score)"
        startGame()
    }
    
    @objc
    func irCorrectButtonTapped(_ sender: Any) {
        if isCorrect { endGame() }
        score = score + 1
        scoreLabel?.text = "\(score)"
        startGame()
    }
    
    @objc
    func captureTapped(_ sender: Any) {
        captureButtonTapped?()
    }
    
    @objc
    func doneTapped(_ sender: Any) {
        endGame()
        doneButtonTapped?()
    }
}

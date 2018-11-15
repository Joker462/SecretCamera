//
//  WebCoverView.swift
//  SecretCamera
//
//  Created by Hung on 9/25/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit
import WebKit

class WebCoverView: UIView {

    fileprivate var progressView: UIProgressView?
    fileprivate var webView: WKWebView?
    fileprivate var barView: UIView?
    
    var requestFinished: ((_ urlString: String?) -> Void)?
    
    override func draw(_ rect: CGRect) {
        setUpWebView(rect)
        super.draw(rect)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView?.progress = Float(webView!.estimatedProgress)
        }
    }
    
    func load(_ link: String) {
        var link = link
        if !link.contains("https://") {
            link = "https://" + link.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let url = URL(string: link) {
            let urlRequest = URLRequest(url: url)
            webView?.load(urlRequest)
        }
    }
}

// MARK: - Private methods
private extension WebCoverView {
    func setUpWebView(_ rect: CGRect) {
        let heightBar: CGFloat = DeviceType.IPHONE_X ? 60 : 49
        barView = UIView(frame: CGRect(x: 0, y: rect.size.height - heightBar, width: rect.size.width, height: heightBar))
        barView?.backgroundColor = UIColor.white
        if let barView = barView {
            addSubview(barView)
            setUpEvents(barView: barView)
        }
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView?.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: 2)
        progressView?.progress = 0
        progressView?.trackTintColor = .clear
        barView?.addSubview(progressView!)
        
        webView = WKWebView(frame: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height - heightBar))
        webView?.navigationDelegate = self
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        insertSubview(webView!, belowSubview: barView!)
    }
}

// MARK: WKNavigationDelegate
extension WebCoverView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let viewController = self.superview?.superview?.parentViewController {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
        progressView?.progress = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView?.progress = 0
        var url = webView.url?.absoluteString.replacingOccurrences(of: "https://www.", with: "")
        url?.removeLast()
        requestFinished?(url)
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
}

// MARK: - Gesture
private extension WebCoverView {
    func setUpEvents(barView: UIView) {

        // Swipe Right Gesture
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRightGesture.direction = .right
        barView.addGestureRecognizer(swipeRightGesture)
        
        // Swipe Left Gesture
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeftGesture.direction = .left
        barView.addGestureRecognizer(swipeLeftGesture)
    }
    
    // @objc methods
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

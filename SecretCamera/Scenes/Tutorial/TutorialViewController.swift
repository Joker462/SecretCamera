//
//  TutorialViewController.swift
//  SecretCamera
//
//  Created by MMI001 on 10/30/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import UIKit

final class TutorialViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet fileprivate weak var scrollView:  UIScrollView?
    @IBOutlet fileprivate weak var pageControl: UIPageControl?
    
    // MARK: - Properties
    var viewModel: TutorialViewModel?
    
    // MARK: - View cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    deinit {
        print("Tutorial scene deinit")
    }
    
    // MARK: - Event
    @IBAction private func skipButtonTapped() {
        viewModel?.skipTapped()
    }
}

// MARK: - TutorialViewOutput - 
extension TutorialViewController: TutorialViewOutput {
    func createSubviewForScrollView(with totalSubview: Int) {
        var offsetX: CGFloat = 0
        scrollView?.contentSize = CGSize(width: Screen.WIDTH * CGFloat(totalSubview), height: Screen.HEIGHT)
        scrollView?.delegate = self
        
        for i in 0..<totalSubview {
            let containerViewFrame = CGRect(x: offsetX, y: 0, width: Screen.WIDTH, height: Screen.HEIGHT)
            let tutorialContainerView = TutorialContainerView(frame: containerViewFrame)
            tutorialContainerView.titleLabel.text = viewModel?.getTitleSubview(at: i)
            tutorialContainerView.pictureImageView.image = UIImage(named: viewModel?.getImageNamedSubview(at: i) ?? "")
            scrollView?.addSubview(tutorialContainerView)
            
            offsetX += Screen.WIDTH
        }
        
        pageControl?.currentPage = 0
        pageControl?.numberOfPages = totalSubview
    }
}

// MARK: - UIScrollViewDelegate -
extension TutorialViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl?.currentPage = Int(pageNumber)
    }
}

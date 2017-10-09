//
//  TutorialViewController.swift
//  SecretCamera
//
//  Created by Hung on 9/28/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var scrollView:   UIScrollView?
    @IBOutlet weak var pageControl:  UIPageControl?
    fileprivate var currentPage:     Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTutorials()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView?.delegate = self
        pageControl?.currentPage = 0
        pageControl?.numberOfPages = 4
    }
}

// MARK: Events
private extension TutorialViewController {
    @IBAction func skipButtonTapped(_ sender: Any) {
        Utils.saveItemUserDefault(identifier: "secret_camera_skip_tutorial", value: true)
        performSegue(withIdentifier: "TutorialSceneToCoversScene", sender: nil)
    }
}

// MARK: - Private methods
private extension TutorialViewController {
    func createTutorials() {
        var offsetX: CGFloat = 0
        let offsetY: CGFloat = DeviceType.IPHONE_X ? (Screen.HEIGHT - 667) : 0
        scrollView?.contentSize = CGSize(width: Screen.WIDTH * 4, height: Screen.HEIGHT - offsetY)
        for i in 1...4 {
            let imageView = UIImageView(frame: CGRect(x: offsetX, y: offsetY/2, width: Screen.WIDTH, height: Screen.HEIGHT - offsetY))
            imageView.image = UIImage(named: "tutorial_\(i)")
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            scrollView?.insertSubview(imageView, at: 1)
            offsetX = offsetX + Screen.WIDTH
        }
    }
}
// MARK: UIScrollViewDelegate
extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl?.currentPage = Int(pageNumber)
        currentPage = Int(pageNumber)
        
    }
}

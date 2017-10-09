//
//  CoverPreviewPresenter.swift
//  SecretCamera
//
//  Created by Hung on 9/12/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation


protocol CoverPreviewView: class {
    func setUpPreview(_ imageNamed: String)
    func setUpTapOnPreviewEvent()
    func setUpSwipeRightOnPreviewEvent()
    func setUpSwipeLeftOnPreviewEvent()
}

protocol CoverPreviewPresenter {
    var router: CoverPreviewRouter { get }
    func viewDidLoad()
    func previewViewTapped()
    func previewViewSwipeRight()
    func previewViewSwipeLeft()
}

class CoverPreviewPresenterImplementation: CoverPreviewPresenter {
    internal let router:        CoverPreviewRouter
    fileprivate let cover:      Cover
    fileprivate weak var view:  CoverPreviewView?
    
    init(view: CoverPreviewView, router: CoverPreviewRouter, cover: Cover) {
        self.view = view
        self.router = router
        self.cover = cover
    }
    
    // MARK: - CoverPreviewPresenter
    func viewDidLoad() {
        if let actionIndex = cover.actionIndex {
            view?.setUpPreview(cover.actions[actionIndex].imagePreviewNamed)
        }
        
        // Events
        view?.setUpTapOnPreviewEvent()
        view?.setUpSwipeRightOnPreviewEvent()
        view?.setUpSwipeLeftOnPreviewEvent()
    }
    
    func previewViewTapped() {
        router.presentSettingsView(cover)
    }
    
    func previewViewSwipeRight() {
        router.dismissView()
    }
    
    func previewViewSwipeLeft() {
        router.presentSettingsView(cover)
    }
}

//
//  ChooseActionPresenter.swift
//  SecretCamera
//
//  Created by Hung on 9/20/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation


protocol ChooseActionView: class {
    func setUpTableView()
}

protocol ChooseActionPresenter {
    var router: ChooseActionRouter { get }
    func viewDidLoad()
    
    func getActionsCount() -> Int
    func actionSelected(at index: Int)
    func getAction(at index: Int) -> Action
    
}


final class ChooseActionPresenterImplementation: ChooseActionPresenter {
    
    internal let router:        ChooseActionRouter
    fileprivate weak var view:  ChooseActionView?
    fileprivate let cover:      Cover

    init(view: ChooseActionView, router: ChooseActionRouter, cover: Cover) {
        self.view = view
        self.router = router
        self.cover = cover
    }
    
    // MARK: - ChooseActionPresenter
    func viewDidLoad() {
        view?.setUpTableView()
    }
    
    func getActionsCount() -> Int {
        return cover.actions.count
    }
    
    func getAction(at index: Int) -> Action {
        return cover.actions[index]
    }
    
    func actionSelected(at index: Int) {
        cover.actionIndex = index
        router.presentCoverPreviewView(cover: cover)
    }
}

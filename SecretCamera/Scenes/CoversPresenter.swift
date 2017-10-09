//
//  CoversPresenter.swift
//  SecretCamera
//
//  Created by Hung on 9/7/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation


protocol CoversView: class {
    func showNavigationBar(_ title: String)
    func setUpCarouselView()
}

protocol CoversPresenter {
    var router: CoversRouter { get }
    // Cycles
    func viewDidLoad()
    func viewWillAppear()
    // Covers
    func getCoverListCount() -> Int
    func getCoverImageView(at index: Int) -> String
    func getCoverName(at index: Int) -> String
    func getCover() -> Cover
    // iCarousel
    func carouselChanged(_ index: Int)
    func carouselSelected(_ index: Int)
    
    func nextButtonTapped()
}

class CoversPresenterImplementation: CoversPresenter {
    internal let router:                CoversRouter
    fileprivate weak var view:          CoversView?
    fileprivate var covers:             [Cover] = []
    fileprivate var lastIndexPicked:    Int = 0
    
    init(view: CoversView, router: CoversRouter) {
        self.view = view
        self.router = router
        createCovers()
    }
    
    // MARK: - CoversPresenter
    func viewDidLoad() {
        view?.setUpCarouselView()
    }
    
    func viewWillAppear() {
        view?.showNavigationBar("Choose a cover")
    }
    
    func getCoverListCount() -> Int {
        return covers.count
    }
    
    func getCoverName(at index: Int) -> String {
        return covers[index].name
    }
    
    func getCoverImageView(at index: Int) -> String {
        return covers[index].imageNamed
    }
    
    func getCover() -> Cover {
        return covers[lastIndexPicked]
    }
    
    func carouselChanged(_ index: Int) {
        lastIndexPicked = index
    }
    
    func carouselSelected(_ index: Int) {
        lastIndexPicked = index
    }
    
    func nextButtonTapped() {
        router.presentChooseActionView(cover: covers[lastIndexPicked])
    }
}

// MARK: - Private
private extension CoversPresenterImplementation {
    func createCovers() {
        let blackCover = Cover(name: "Black", imageNamed: "black_cover")
        blackCover.actions.first?.imagePreviewNamed = "black_cover_photo_preview"
        blackCover.actions.last?.imagePreviewNamed = "black_cover_video_preview"
        covers.append(blackCover)
        
        let webCover = Cover(name: "Web", imageNamed: "web_cover")
        webCover.actions.first?.imagePreviewNamed = "web_cover_photo_preview"
        webCover.actions.last?.imagePreviewNamed = "web_cover_video_preview"
        covers.append(webCover)
        
        let gameCover = Cover(name:  "Game", imageNamed: "game_cover")
        gameCover.actions.first?.imagePreviewNamed = "game_cover_photo_preview"
        gameCover.actions.last?.imagePreviewNamed = "game_cover_video_preview"
        covers.append(gameCover)
        
        // Photo Settings
        let photoRepeatSetting = SettingLogoWithSwitch(name: "Auto Repeat", imageNamed: "ic_auto_repeat_settings_screen", isSelected: false)
        let photoTimeSetting = PhotoTimeSetting(name: "Time", imageNamed: "ic_time_settings_screen")
        
        // Video Setting
        let videoRecordSetting = VideoStartRecordSetting(name: "Start Record After", imageNamed: "ic_time_settings_screen")
    
        // Camera Setting
        let cameraPositionSetting = CameraPositionSetting(name: "Position", imageNamed: "ic_position_settings_screen")
        let hideCaptureSetting = SettingWithSwitch(name: "Hide Capture Button", isSelected: false)
        let cameraQualitySetting = CameraQualitySetting(name: "Quality", imageNamed: "ic_quality_settings_screen")
        
        covers.forEach {
            $0.actions.first?.settings.append(photoRepeatSetting)
            $0.actions.first?.settings.append(photoTimeSetting)
            $0.actions.last?.settings.append(videoRecordSetting)
            $0.actions.first?.cameraSettings.append(cameraPositionSetting)
            $0.actions.last?.cameraSettings.append(cameraPositionSetting)
            $0.actions.last?.cameraSettings.insert(cameraQualitySetting, at: 0)
        }
        // Add hide capture setting for Black and Game cover in Photo action
        blackCover.actions.first?.cameraSettings.append(hideCaptureSetting)
        gameCover.actions.first?.cameraSettings.append(hideCaptureSetting)
        
    }
}

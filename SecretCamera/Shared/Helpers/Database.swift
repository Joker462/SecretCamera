//
//  Database.swift
//  SecretCamera
//
//  Created by MMI001 on 11/1/18.
//  Copyright © 2018 Hung. All rights reserved.
//

import Foundation

enum CoverViewType {
    case Black
    case Web
    case Game
}

final class Database {
    static let shared = Database()
    
    var covers: [Cover] = []
    var coverIndexSelected: Int = 0 
    var coverSelected: Cover! {
        return covers[coverIndexSelected]
    }
    
    init() {
        createCovers()
    }
}

private extension Database {
    func createCovers() {
        let blackCover = Cover(name: "Black", imageNamed: "black_cover")
        blackCover.actions.first?.imagePreviewNamed = "black_cover_photo_preview"
        blackCover.actions.last?.imagePreviewNamed = "black_cover_video_preview"
        covers.append(blackCover)
        
        let webCover = Cover(name: "Web", imageNamed: "web_cover")
        webCover.actions.first?.imagePreviewNamed = "web_cover_photo_preview"
        webCover.actions.last?.imagePreviewNamed = "web_cover_video_preview"
        covers.append(webCover)
        
        let gameCover = Cover(name: "Game", imageNamed: "game_cover")
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

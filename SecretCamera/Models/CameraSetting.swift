
//
//  CameraSetting.swift
//  SecretCamera
//
//  Created by Hung on 8/14/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

final class CameraQualitySetting: SettingLogoWithOptions {
    
    init(name: String, imageNamed: String) {
        let options = ["Low", "Medium", "High"]
        super.init(name: name, imageNamed: imageNamed, options: options)
    }
}

final class CameraPositionSetting: SettingLogoWithOptions {
    
    init(name: String, imageNamed: String) {
        let options = ["Back", "Front"]
        super.init(name: name, imageNamed: imageNamed, options: options)
    }
}

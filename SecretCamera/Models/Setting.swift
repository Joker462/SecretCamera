//
//  Setting.swift
//  SecretCamera
//
//  Created by Hung on 9/5/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

enum SettingType {
    case SettingWithSwitch
    case SettingLogoWithSwitch
    case SettingLogoWithOption
}

class Setting {
    var name: String
    var type: SettingType = .SettingWithSwitch
    
    init(name: String) {
        self.name = name
    }
}

class SettingWithLogo: Setting {
    var imageNamed: String
    
    init(name: String, imageNamed: String) {
        self.imageNamed = imageNamed
        super.init(name: name)
    }
}

class SettingWithSwitch: Setting {
    var isSelected: Bool
    
    init(name: String, isSelected: Bool) {
        self.isSelected = isSelected
        super.init(name: name)
    }
}

class SettingLogoWithSwitch: SettingWithSwitch {
    var imageNamed: String
    
    init(name: String, imageNamed: String, isSelected: Bool) {
        self.imageNamed = imageNamed
        super.init(name: name, isSelected: isSelected)
        type = .SettingLogoWithSwitch
    }
}

class SettingWithDetail: SettingWithLogo {
    var detail: String
    
    init(name: String, imageNamed: String, detail: String) {
        self.detail = detail
        super.init(name: name, imageNamed: imageNamed)
        type = .SettingLogoWithOption
    }
}

class SettingWithOptions: Setting {
    var options: [String]
    var index:   Int
    
    init(name: String, options: [String]) {
        self.options = options
        index = 0
        super.init(name: name)
        type = .SettingLogoWithOption
    }
}

class SettingLogoWithOptions: SettingWithOptions {
    var imageNamed: String
    
    init(name: String, imageNamed: String, options: [String]) {
        self.imageNamed = imageNamed
        super.init(name: name, options: options)
    }
}

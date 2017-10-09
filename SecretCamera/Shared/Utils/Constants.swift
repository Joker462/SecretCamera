//
//  Constants.swift
//  SecretCamera
//
//  Created by Hung on 8/14/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation
import UIKit

// get ratio screen
struct RATIO {
    static let SCREEN_WIDTH               = (DeviceType.IPHONE_4_OR_LESS ? 1.0 : Screen.WIDTH / 375.0)
    static let SCREEN_HEIGHT              = (DeviceType.IPHONE_4_OR_LESS ? 1.0 : Screen.HEIGHT / 667.0)
    static let SCREEN                     = ((RATIO.SCREEN_WIDTH + RATIO.SCREEN_HEIGHT) / 2.0)
}

// get scale screen
struct ScaleValue {
    static let SCREEN_WIDTH         = (DeviceType.IPAD ? 1.8 : ((DeviceType.IPHONE_6 || DeviceType.IPHONE_X) ? 1.174 : (DeviceType.IPHONE_6P ? 1.295 : 1.0)))
    static let SCREEN_HEIGHT        = (DeviceType.IPAD ? 2.4 : ((DeviceType.IPHONE_6 || DeviceType.IPHONE_X) ? 1.171 : (DeviceType.IPHONE_6P ? 1.293 : 1.0)))
    static let FONT                 = (DeviceType.IPAD ? 1.0 : (DeviceType.IPHONE_6P ? 1.27 : ((DeviceType.IPHONE_6 || DeviceType.IPHONE_X) ? 1.15 : 1.0)))
}

// get screen size
struct Screen {
    static let BOUNDS   = UIScreen.main.bounds
    static let WIDTH    = UIScreen.main.bounds.size.width
    static let HEIGHT   = UIScreen.main.bounds.size.height
    static let MAX      = max(Screen.WIDTH, Screen.HEIGHT)
    static let MIN      = min(Screen.WIDTH, Screen.HEIGHT)
}

// get device type
struct DeviceType {
    static let IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX <  568.0
    static let IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX == 568.0
    static let IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX == 667.0
    static let IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX == 736.0
    static let IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX == 812.0
    static let IPAD              = UIDevice.current.userInterfaceIdiom == .pad   && Screen.MAX == 1024.0
}

// RegularExpression
struct Rex {
    static let link        =    "http?://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?"
    static let mail        =    "[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,4}"
    static let number      =    "\\([0-9]+\\)"
    static let multiLine   =    "\\n"
    static let onlyNumber  =    "[0-9]+"
    static let password    =    "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
    static let cost        =    "\\d+(\\.\\d*)?"
    static let qrcode      =    "qr=([0-9]+)"
}

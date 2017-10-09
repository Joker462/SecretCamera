//
//  UIInterfaceOrientation.swift
//  SecretCamera
//
//  Created by Hung on 9/18/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit
import  AVFoundation

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}

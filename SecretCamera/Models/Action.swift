//
//  Action.swift
//  SecretCamera
//
//  Created by Hung on 9/22/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

final class Action {
    let name: String
    let imageNamed: String
    var imagePreviewNamed: String = ""
    
    var settings: [Setting] = []
    var cameraSettings: [Setting] = []
    
    init(name: String, imageNamed: String) {
        self.name = name
        self.imageNamed = imageNamed
    }
}

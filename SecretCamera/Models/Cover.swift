//
//  Cover.swift
//  SecretCamera
//
//  Created by Hung on 8/24/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

final class Cover {
    let name:               String
    let imageNamed:         String
    // Video/Photo
    let actions = [Action(name: "Photo", imageNamed: "ic_photo"),
                   Action(name: "Video", imageNamed: "ic_video")]
    var actionIndex:    Int?
    
    init(name: String, imageNamed: String) {
        self.name = name
        self.imageNamed = imageNamed
    }
}

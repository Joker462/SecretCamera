//
//  NSObject.swift
//  CoreMVVM
//
//  Created by Joker on 8/20/18.
//  Copyright © 2018 joker. All rights reserved.
//

import Foundation

extension NSObject {
    
    class var identifier: String {
        let components = String(describing: self).components(separatedBy: ".")
        return components.count > 1 ? components.last! : components.first!
    }
}

//
//  Enum.swift
//  SecretCamera
//
//  Created by Hung on 9/15/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation
func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

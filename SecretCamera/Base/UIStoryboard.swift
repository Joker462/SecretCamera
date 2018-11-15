//
//  UIStoryboard.swift
//  CoreMVVM
//
//  Created by Joker on 8/24/18.
//  Copyright © 2018 joker. All rights reserved.
//

import UIKit

public extension UIStoryboard {
    /// SwifterSwift: Instantiate a UIViewController using its class name
    ///
    /// - Parameter name: UIViewController type
    /// - Returns: The view controller corresponding to specified class name
    public func instantiateViewController<T: UIViewController>(withClass name: T.Type) -> T? {
        return instantiateViewController(withIdentifier: name.identifier) as? T
    }

}

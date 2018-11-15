//
//  UIViewController.swift
//  CoreMVVM
//
//  Created by Joker on 8/20/18.
//  Copyright © 2018 joker. All rights reserved.
//

import UIKit

// MARK: - Initializations -
public extension UIViewController {
    
    /// Instantiate controller from defaut storyboard 'Main'
    ///
    /// - Returns: View controller
    public class func instantiateFromStoryboard() -> Self {
        return instantiateFromStoryboardHelper(type: self, storyboardName: "Main")
    }
    
    
    /// Instantiate controller from storyboard name
    ///
    /// - Parameter storyboardName: name of storyboard
    /// - Returns: view controller
    public class func instantiateFromStoryboard(storyboardName: String) -> Self {
        return instantiateFromStoryboardHelper(type: self, storyboardName: storyboardName)
    }
    
    /// Instantiate controller from storyboard
    ///
    /// - Parameter storyboard: storyboard contain self
    /// - Returns: view controller
    public class func instantiateFromStoryboard(storyboard: UIStoryboard) -> Self {
        return instantiateFromStoryboardHelper(type: self, storyboard: storyboard)
    }
    
    
}

// MARK: - Private extension -
private extension UIViewController {
    private class func instantiateFromStoryboardHelper<T>(type: T.Type, storyboardName: String) -> T where T: UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: T.identifier) as? T else {
            fatalError("Not find view controller have identifier \(T.identifier)")
        }
        return controller
    }
    
    private class func instantiateFromStoryboardHelper<T>(type: T.Type, storyboard: UIStoryboard) -> T where T: UIViewController {
        guard let controller = storyboard.instantiateViewController(withIdentifier: T.identifier) as? T else {
            fatalError("Not find view controller have identifier \(T.identifier)")
        }
        return controller
    }
}

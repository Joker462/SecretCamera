//
//  UITableView.swift
//  SecretCamera
//
//  Created by Hung on 9/6/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

extension UITableView {
    func registerCellNib(anyClass: AnyClass) {
        let identifier = String.className(aClass: anyClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        register(nib, forCellReuseIdentifier: identifier)
    }
}

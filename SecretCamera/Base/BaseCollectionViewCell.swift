//
//  BaseCollectionViewCell.swift
//  rhombus
//
//  Created by Hung on 3/11/17.
//  Copyright © 2017 originallyUS. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath?
    
    func configureCell<T>(anyItem: T) {
        
    }
}

@objc protocol CollectionViewCellDelegate: class {
    @objc optional func seleted(indexPath: IndexPath)
}

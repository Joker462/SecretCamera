//
//  BaseTableViewCell.swift
//  rhombus
//
//  Created by Hung on 3/11/17.
//  Copyright © 2017 originallyUS. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath?
    weak var delegate:  TableViewCellDelegate?
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .default
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func configureCell<T>(anyItem: T) {
        
    }
}

@objc protocol TableViewCellDelegate: class {
    @objc optional func selected(indexPath: IndexPath)
    @objc optional func valueChanged(value: Bool, indexPath: IndexPath)
}


protocol BaseTableViewCellView {
    func display(anyItem: Any?)
}

extension BaseTableViewCell: BaseTableViewCellView {
    func display(anyItem: Any?) {}
}

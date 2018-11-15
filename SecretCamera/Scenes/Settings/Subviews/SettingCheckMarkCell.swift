//
//  SettingCheckMarkCell.swift
//  SecretCamera
//
//  Created by Hung on 9/15/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class SettingCheckMarkCell: BaseTableViewCell {

    // IBOutlets
    @IBOutlet weak var titleLabel:          UILabel?
    @IBOutlet weak var checkMarkImageView:  UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .default
        titleLabel?.font = UIFont.systemFont(ofSize: 13 * CGFloat(ScaleValue.FONT))
        checkMarkImageView?.isHidden = true
    }
    
    func setHiddenCheckMark(_ bool: Bool) {
        checkMarkImageView?.isHidden = bool
    }
}

// MARK: - BaseTableViewCellView
extension SettingCheckMarkCell {
    override func display(anyItem: Any?) {
        if let text = anyItem as? String {
            titleLabel?.text = text
        }
    }
}

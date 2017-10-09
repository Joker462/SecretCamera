//
//  SettingLogoWithValueDisclosureCell.swift
//  SecretCamera
//
//  Created by Hung on 9/6/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class SettingLogoWithValueDisclosureCell: BaseTableViewCell {

    // IBOutlets
    @IBOutlet weak var logoImageView:   UIImageView?
    @IBOutlet weak var titleLabel:      UILabel?
    @IBOutlet weak var detailLabel:     UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoImageView?.contentMode = .scaleAspectFit
        titleLabel?.font = UIFont.systemFont(ofSize: 13 * CGFloat(ScaleValue.FONT))
        detailLabel?.font = UIFont.systemFont(ofSize: 13 * CGFloat(ScaleValue.FONT))
    }
    
    override func configureCell<T>(anyItem: T) {
        if let action = anyItem as? Action {
            detailLabel?.isHidden = true
            
            titleLabel?.text = action.name
            logoImageView?.image = UIImage(named: action.imageNamed)
        }
    }
    
    
}


// MARK: - BaseTableViewCellView
extension SettingLogoWithValueDisclosureCell {
    override func display(anyItem: Any?) {
        if let setting = anyItem as? SettingLogoWithOptions {
            logoImageView?.image = UIImage(named: setting.imageNamed)
            titleLabel?.text = setting.name
            detailLabel?.text = setting.options[setting.index]
        }
    }
}

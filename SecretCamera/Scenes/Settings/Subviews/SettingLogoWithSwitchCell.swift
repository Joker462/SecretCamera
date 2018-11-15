//
//  SettingLogoWithSwitchCell.swift
//  SecretCamera
//
//  Created by Hung on 9/6/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class SettingLogoWithSwitchCell: BaseTableViewCell {

    // IBOutlets
    @IBOutlet weak var logoImageView:   UIImageView?
    @IBOutlet weak var titleLabel:      UILabel?
    @IBOutlet weak var selectSwitch:    UISwitch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        logoImageView?.contentMode = .scaleAspectFit
        titleLabel?.font = UIFont.systemFont(ofSize: 13 * CGFloat(ScaleValue.FONT))
        selectSwitch?.isOn = false
    }
    
    @IBAction func selectedSwitchValueChanged(_ sender: Any) {
        if let indexPath = indexPath, let selectedSwitch = sender as? UISwitch {
            delegate?.valueChanged!(value: selectedSwitch.isOn, indexPath: indexPath)
        }
    }
}

// MARK: - BaseTableViewCellView
extension SettingLogoWithSwitchCell {
    override func display(anyItem: Any?) {
        if let setting = anyItem as? SettingLogoWithSwitch {
            logoImageView?.image = UIImage(named: setting.imageNamed)
            titleLabel?.text = setting.name
            selectSwitch?.isOn = setting.isSelected
        }
    }
}

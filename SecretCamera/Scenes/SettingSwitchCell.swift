//
//  SettingSwitchCell.swift
//  SecretCamera
//
//  Created by Hung on 9/6/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class SettingSwitchCell: BaseTableViewCell {

    // IBOutlets
    @IBOutlet weak var titleLabel:      UILabel?
    @IBOutlet weak var selectedSwitch:  UISwitch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        selectedSwitch?.isOn = false
        titleLabel?.font = UIFont.systemFont(ofSize: 13 * CGFloat(ScaleValue.FONT))
    }
    
    @IBAction func selectedSwitchValueChanged(_ sender: Any) {
        if let indexPath = indexPath, let selectedSwitch = sender as? UISwitch {
            delegate?.valueChanged!(value: selectedSwitch.isOn, indexPath: indexPath)
        }
    }
}


// MARK: - BaseTableViewCellView
extension SettingSwitchCell {
    override func display(anyItem: Any?) {
        if let setting = anyItem as? SettingWithSwitch {
            titleLabel?.text = setting.name
            selectedSwitch?.isOn = setting.isSelected
        }
    }
}

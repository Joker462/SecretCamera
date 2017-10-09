//
//  UILabel.swift
//  SecretCamera
//
//  Created by Hung on 8/14/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

extension UILabel {
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let fontName = self.font.fontName
        let fontSize = self.font.pointSize
        self.font = UIFont(name: fontName, size: fontSize * CGFloat(ScaleValue.FONT))
    }
}

//
//  TutorialContainerView.swift
//  SecretCamera
//
//  Created by MMI001 on 10/30/18.
//  Copyright © 2018 Hung. All rights reserved.
//

import UIKit

final class TutorialContainerView: UIView {
    
    // MARK: - Outlets
    @IBOutlet fileprivate var contentView:  UIView!
    @IBOutlet weak var pictureImageView:    UIImageView!
    @IBOutlet weak var titleLabel:          UILabel!
    
    // MARK: - Contructions
    override init(frame: CGRect) { // for using code
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) { // for using IB
        super.init(coder: aDecoder)
        commonInit()
    }
}

// MARK: - Private methods -
private extension TutorialContainerView {
    func commonInit() {
        if let contentView = Bundle.main.loadNibNamed(TutorialContainerView.identifier, owner: self, options: nil)?.first as? UIView {
            addSubview(contentView)
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.contentView = contentView
        }
    }
}

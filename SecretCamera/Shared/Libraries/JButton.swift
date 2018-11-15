//
//  JButton.swift
//  hoidelivery
//
//  Created by Hung on 8/15/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import UIKit

class JButton: UIButton {
    // MARK: Private variable
    fileprivate(set) var roundRectLayer: CAShapeLayer?
    fileprivate(set) var textLabel:         UILabel?
    // MARK: Public interface
    /// Corner radius of the background rectangle
    public var roundRectCornerRadius: CGFloat = 5 {
        didSet {
            setNeedsLayout()
            layoutRoundRectLayer()
        }
    }
    
    /// Color of the background rectangle
    public var roundRectColor: UIColor = UIColor.black {
        didSet {
            setNeedsLayout()
            layoutRoundRectLayer()
        }
    }
    
    public var strokeColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
            layoutRoundRectLayer()
        }
    }
    
    public var roundRectColorSelected: UIColor = UIColor.black
    public var textNormalColor: UIColor = UIColor.blue
    public var textHighlightColor: UIColor = UIColor.black
    
    // isHighlighted
    override var isHighlighted: Bool {
        didSet {
            if !isHighlighted {
                layoutRoundRectLayer()
            }
        }
    }
    
    // MARK: Overrides
    override func draw(_ rect: CGRect) {
        layoutRoundRectLayer()
        isExclusiveTouch = true
    }
    
    // MARK: Actions
    @objc func highlight() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).cgPath
        shapeLayer.fillColor = roundRectColorSelected.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        textLabel?.textColor = textHighlightColor
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
    }
    
    func setup(title: String, fontSize: CGFloat, fontNamed: String, textNormalColor: UIColor, textHighlightColor: UIColor) {
        setAttributedTitle(nil, for: .normal)
        titleLabel?.text = ""
        self.textNormalColor = textNormalColor
        self.textHighlightColor = textHighlightColor
        
        textLabel?.removeFromSuperview()
        textLabel = UILabel()
        textLabel?.textColor = textNormalColor
        textLabel?.text = title
        let font = UIFont(name: fontNamed, size: fontSize * CGFloat(ScaleValue.FONT)) ?? UIFont.systemFont(ofSize: fontSize * CGFloat(ScaleValue.FONT))
        textLabel?.font = font
        textLabel?.textAlignment = .center
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel!)
        
        setConstraints()
    }

    func setup(title: String, font: UIFont, textNormalColor: UIColor, textHighlightColor: UIColor) {
        setAttributedTitle(nil, for: .normal)
        titleLabel?.text = ""
        self.textNormalColor = textNormalColor
        self.textHighlightColor = textHighlightColor
        
        textLabel?.removeFromSuperview()
        textLabel = UILabel()
        textLabel?.textColor = textNormalColor
        textLabel?.text = title
        textLabel?.font = font
        textLabel?.textAlignment = .center
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel!)
        
        setConstraints()
    }

    private func setConstraints() {
        let leadingConstraint = NSLayoutConstraint(item: textLabel!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 8)
        let trailingConstraint = NSLayoutConstraint(item: textLabel!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -8)
        let horConstraint = NSLayoutConstraint(item: textLabel!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let verConstraint = NSLayoutConstraint(item: textLabel!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        addConstraints([trailingConstraint, leadingConstraint, horConstraint, verConstraint])
    }
    
}

// MARK: Private methods
private extension JButton {
    
    func layoutRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).cgPath
        shapeLayer.fillColor = roundRectColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        textLabel?.textColor = textNormalColor
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
        self.addTarget(self, action: #selector(highlight), for: .touchDown)
    }
}

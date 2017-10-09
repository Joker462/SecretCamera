//
//  UIView.swift
//  rhombus
//
//  Created by Hung on 3/11/17.
//  Copyright © 2017 originallyUS. All rights reserved.
//

import Foundation
import UIKit

//  MARK: Layer, Draw UI
/// IMPORTANT: Make sure the constraint is correct
extension UIView {
    
    enum Border {
        case Top
        case Bottom
        case Left
        case Right
    }
    
    func addBorder(borderType: Border, weightBorder: CGFloat = 1.0 ,colorBorder: UIColor = UIColor.black) {
        
        let borderLayer = CAShapeLayer()
        switch borderType {
        case .Top:
            borderLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.width, height: weightBorder)).cgPath
            break
        case .Bottom:
            borderLayer.path = UIBezierPath(rect: CGRect(x: 0, y: self.bounds.height - weightBorder, width: self.bounds.width, height: weightBorder)).cgPath
            break
        case .Left:
            borderLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: weightBorder, height: self.bounds.height)).cgPath
            break
        default:
            // Right
            borderLayer.path = UIBezierPath(rect: CGRect(x: self.bounds.width - weightBorder, y: 0, width: weightBorder, height: self.bounds.height)).cgPath
            break
        }
        borderLayer.fillColor = colorBorder.cgColor
        layer.addSublayer(borderLayer)
    }
    
    func addBorderAround(weightBorder: CGFloat = 1.0, colorBorder: UIColor = UIColor.lightGray) {
        layer.borderWidth = weightBorder
        layer.borderColor = colorBorder.cgColor
    }
}

// MARK: Draw Corner Radius
extension UIView {
    
    /// Add Corners with radius
    /// NOTE: You NEED to use layoutIfNeeded method before or override layoutSubviews method in custom class UIView
    /// - Parameters:
    ///   - corners: UIRectCorner
    ///   - withRadius: CGFloat
    func add(corners: UIRectCorner, withRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: withRadius, height: withRadius))
        let mask = CAShapeLayer()
        mask.frame = bounds
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// MARK: Remove all Subview
extension UIView {
    func removeAllSubView() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
}

// MARK: Load Nib
extension UIView {
    @discardableResult   // Using a discardable return value since the returned view is mostly of no interest to caller when all outlets are already connected.
    func fromNib<T : UIView>() -> T? {
        guard let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?[0] as? T else {
            // xib not loaded, or it's top view is of the wrong type
            return nil
        }
        return view  
    }
}

// MARK: Parent Controller 
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// MARK: Animations
extension UIView {
    // Interaction
    func setInteractionWithAnimation(bool: Bool, alpha: CGFloat = 0.3) {
        if self.isUserInteractionEnabled != bool {
            if bool {
                UIView.animate(withDuration: 0.5, animations: {
                    self.alpha = 1.0
                }, completion: { (_) in
                    self.isUserInteractionEnabled = bool
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.alpha = alpha
                }, completion: { (_) in
                    self.isUserInteractionEnabled = bool
                })
            }
        }
    }
    
    func setInteraction(bool: Bool, alpha: CGFloat = 0.3) {
        if self.isUserInteractionEnabled != bool {
            self.isUserInteractionEnabled = bool
            if bool {
                self.alpha = 1.0
            } else {
                self.alpha = alpha
            }
        }
    }
    
    func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.repeatCount = count ?? 2
        animation.duration = (duration ?? 0.05)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        let value = translation ?? 5
       
        animation.fromValue = NSValue.init(cgPoint: CGPoint(x: center.x - CGFloat(value), y: center.y))
        animation.toValue = NSValue.init(cgPoint: CGPoint(x: center.x + CGFloat(value), y: center.y))
        layer.add(animation, forKey: "position")
    }
    
    func fade(duration: TimeInterval = 1.0, isHidden: Bool = false, completion: @escaping (_ finish: Bool) -> Void) {
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            self.isHidden = isHidden
        }) { (finish) in
            completion(finish)
        }
    }
    
    func zoomIn(duration: TimeInterval = 1.0, completion: ((_ finish: Bool) -> Void)?) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform.identity
        }) { (finish) in
            completion?(finish)
        }
    }
    
    func zoomOut(duration: TimeInterval = 1.0, completion: @escaping (_ finish: Bool) -> Void) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (finish) in
            completion(finish)
        }
    }
    
    func popOut(duration: TimeInterval = 1.0) {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4, options: .allowAnimatedContent, animations: {
            self.transform = .identity
        }, completion: nil)
    }
    
}

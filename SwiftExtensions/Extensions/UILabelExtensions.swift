//
//  UILabelExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/9/7.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public enum UILabelVerticalAlignment: Int{
    case middle
    case top
    case bottom
}

private var kUILabelVerticalAlignmentKey: String = "kUILabelVerticalAlignmentKey";

extension UILabel {
   open  var verticalAlignment: UILabelVerticalAlignment {
        set {
            objc_setAssociatedObject(self, &kUILabelVerticalAlignmentKey, NSNumber.init(value: newValue.rawValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.setNeedsDisplay()
        }
        get {
            let number = (objc_getAssociatedObject(self, &kUILabelVerticalAlignmentKey) as? NSNumber)
            return UILabelVerticalAlignment(rawValue: (number != nil) ? number!.intValue : 0)!
        }
    }
    
    open override class func initialize() {
        DispatchQueue.once(token: kUILabelVerticalAlignmentKey, block: {
            let m1 = class_getInstanceMethod(UILabel.self, #selector(textRect(forBounds:limitedToNumberOfLines:)))
            let m2 = class_getInstanceMethod(UILabel.self, #selector(swz_textRect(forBounds:limitedToNumberOfLines:)))
            let m3 = class_getInstanceMethod(UILabel.self, #selector(drawText(in:)))
            let m4 = class_getInstanceMethod(UILabel.self, #selector(swz_drawText(in:)))
            method_exchangeImplementations(m1, m2)
            method_exchangeImplementations(m3, m4)
        })
    }
    
    @objc private func swz_textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var newRect = swz_textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch self.verticalAlignment {
        case .top:
            newRect.origin.y = bounds.origin.y
        case .bottom:
            newRect.origin.y = bounds.origin.y + bounds.size.height - newRect.size.height
        default:
            newRect.origin.y = bounds.origin.y + (bounds.size.height - newRect.size.height) / 2.0
        }
        return newRect
    }
    
    @objc private func swz_drawText(in rect: CGRect) {
        swz_drawText(in: textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines))
    }
}




















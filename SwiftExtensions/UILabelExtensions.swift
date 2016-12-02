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

private var kUILabelVerticalAlignmentKey: Void?

/// 添加label的 垂直对其属性, 默认居中
extension UILabel {
    open var verticalAlignment: UILabelVerticalAlignment {
        set {
            objc_setAssociatedObject(self, &kUILabelVerticalAlignmentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsDisplay()
        }
        get {
            let alignment = (objc_getAssociatedObject(self, &kUILabelVerticalAlignmentKey) as? UILabelVerticalAlignment)
            return alignment != nil ? alignment! : .middle
        }
    }
    
    open override class func initialize() {
        DispatchQueue.once(&kUILabelVerticalAlignmentKey, execute: {
            
            Runtime.Swizzing.exchange(class: UILabel.self,
                                      fromSEL: #selector(textRect(forBounds:limitedToNumberOfLines:)),
                                      toSEL: #selector(swz_textRect(forBounds:limitedToNumberOfLines:)))
            
            Runtime.Swizzing.exchange(class: UILabel.self,
                                      fromSEL: #selector(drawText(in:)),
                                      toSEL: #selector(swz_drawText(in:)))
        })
    }
    
    @objc private func swz_textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        
        var newRect = swz_textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch verticalAlignment {
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

//
//  UIColor+Extensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/10/19.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

private var kz_isNeedInitKey: Void?

public extension UIColor {

    private var kz_hasInitialized: Bool {
        set {
            objc_setAssociatedObject(self, &kz_isNeedInitKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            let value = objc_getAssociatedObject(self, &kz_isNeedInitKey) as? Bool
            
            return value != nil ? value! : false
        }
    }
    
    private func kz_needInit() -> UIColor {
        
        if !self.kz_hasInitialized {
            
            let color = UIColor(ciColor: CIColor(red: 0, green: 0, blue: 0, alpha: 1))
            
            color.kz_hasInitialized = true
            
            return color
        }
        return self
    }
    
    /// Green
    /// - parameter green: 0 <= green <= 255
    class func green(_ green: CGFloat) -> UIColor { return UIColor().green(green) }
    func green(_ green: CGFloat) -> UIColor {
        
        let green = min(max(0, green), 255)
        
        var color = kz_needInit()
        
        let ciColor = CIColor(red:   color.ciColor.red,
                              green: green / 255.0,
                              blue:  color.ciColor.blue,
                              alpha: color.ciColor.alpha)
        
        color = UIColor(ciColor: ciColor)
        
        color.kz_hasInitialized = true
        
        return color
    }
    
    /// Red
    /// - parameter green: 0 <= red <= 255
    class func red(_ red: CGFloat) -> UIColor { return UIColor().red(red) }
    func red(_ red: CGFloat) -> UIColor {
        
        let red = min(max(0, red), 255)
        
        var color = kz_needInit()
        
        let ciColor = CIColor(red:   red / 255.0,
                              green: color.ciColor.green,
                              blue:  color.ciColor.blue,
                              alpha: color.ciColor.alpha)
        
        color = UIColor(ciColor: ciColor)
        
        color.kz_hasInitialized = true
        
        return color
    }
    
    /// Blue
    /// - parameter green: 0 <= blue <= 255
    class func blue(_ blue: CGFloat) -> UIColor { return UIColor().blue(blue) }
    func blue(_ blue: CGFloat) -> UIColor {
        
        let blue = min(max(0, blue), 255)
        
        var color = kz_needInit()
        
        let ciColor = CIColor(red:   color.ciColor.red,
                              green: color.ciColor.green,
                              blue:  blue / 255.0,
                              alpha: color.ciColor.alpha)
        
        color = UIColor(ciColor: ciColor)
        
        color.kz_hasInitialized = true
        
        return color
    }
    
    /// Alpha
    /// - parameter green: 0 <= alpha <= 1
    class func alpha(_ alpha: CGFloat) -> UIColor { return UIColor().alpha(alpha) }
    func alpha(_ alpha: CGFloat) -> UIColor {
        
        let alpha = min(max(0, alpha), 1)
        
        var color = kz_needInit()
        
        let ciColor = CIColor(red:   color.ciColor.red,
                              green: color.ciColor.green,
                              blue:  color.ciColor.blue,
                              alpha: alpha)
        
        color = UIColor(ciColor: ciColor)
        
        color.kz_hasInitialized = true
        
        return color
    }
    
    
    /// HEX Color
    /// - parameter hex: hex number
    /// example: 0x000000 ... 0xffffff
    class func hex(_ hex: Int) -> UIColor? { return UIColor().hex(hex) }
    func hex(_ hex: Int) -> UIColor? {
        
        let hex = min(max(0x000000, hex), 0xffffff)
        
        var color = kz_needInit()
        
        let ciColor = CIColor(red:   CGFloat((hex >> 16) & 0xff) / 255.0,
                              green: CGFloat((hex >> 8) & 0xff) / 255.0,
                              blue:  CGFloat(hex & 0xff) / 255.0,
                              alpha: color.ciColor.alpha)
        
        color = UIColor(ciColor: ciColor)
        
        color.kz_hasInitialized = true
        
        return color
    }
}

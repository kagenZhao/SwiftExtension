//
//  UIColor+Extensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/10/19.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public extension UIColor {
    private class KZ {
        fileprivate var kz_red: CGFloat? = nil
        fileprivate var kz_green: CGFloat? = nil
        fileprivate var kz_blue: CGFloat? = nil
        fileprivate var kz_alpha: CGFloat? = nil
        init(r: CGFloat? = nil, g: CGFloat? = nil,  b: CGFloat? = nil, a: CGFloat? = nil) {
            kz_red = r
            kz_green = g
            kz_blue = b
            kz_alpha = a
        }
    }
    private static var KZKey = "com.kagen.color.kz.key"
    private var _kz:KZ {
        set {
            objc_setAssociatedObject(self, &UIColor.KZKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &UIColor.KZKey) as? UIColor.KZ ?? KZ())!
        }
    }
    
    private convenience init(newKz: KZ) {
        let r = (newKz.kz_red ?? 0) / 255.0
        let g = (newKz.kz_green ?? 0) / 255.0
        let b = (newKz.kz_blue ?? 0) / 255.0
        let a = newKz.kz_alpha ?? 1
        if #available(iOS 10, *) {
            self.init(displayP3Red: r, green: g, blue: b, alpha: a)
        } else {
            self.init(red: r, green: g, blue: b, alpha: a)
        }
        self._kz = newKz
    }
    
    public class var kz: UIColor { return UIColor.white }
    
    /// Green
    ///
    /// - parameter green: 0 <= green <= 255
    ///
    /// - returns: KZ is UIColor
    public func green(_ green: CGFloat) -> UIColor {
        assert(green >= 0 && green <= 255)
        let newKz = self._kz
        newKz.kz_green = green
        self._kz = newKz
        return UIColor.init(newKz: self._kz)
    }
    
    /// Red
    ///
    /// - parameter green: 0 <= red <= 255
    ///
    /// - returns:UIColor
    public func red(_ red: CGFloat) -> UIColor {
        assert(red >= 0 && red <= 255)
        let newKz = self._kz
        newKz.kz_red = red
        self._kz = newKz
        return UIColor.init(newKz: self._kz)
    }
    
    /// Blue
    ///
    /// - parameter green: 0 <= blue <= 255
    ///
    /// - returns: KZ is UIColor
    public func blue(_ blue: CGFloat) -> UIColor {
        assert(blue >= 0 && blue <= 255)
        let newKz = self._kz
        newKz.kz_blue = blue
        self._kz = newKz
        return UIColor.init(newKz: self._kz)
    }
    
    /// Alpha
    ///
    /// - parameter green: 0 <= alpha <= 1
    ///
    /// - returns: KZ is UIColor
    public func alpha(_ alpha: CGFloat) -> UIColor {
        assert(alpha >= 0 && alpha <= 1)
        let newKz = self._kz
        newKz.kz_alpha = alpha
        self._kz = newKz
        return UIColor.init(newKz: self._kz)
    }
    
    
    /// HEX Color
    ///
    /// - parameter hex: hex number
    /// example: 0x000000 ... 0xffffff
    ///
    /// - returns: KZ is UIColor
    public func hex(_ hex: Int) -> UIColor?{
        assert(hex >= 0x000000 && hex <= 0xffffff)
        let newKz = self._kz
        newKz.kz_red = CGFloat((hex >> 16) & 0xff)
        newKz.kz_green = CGFloat((hex >> 8) & 0xff)
        newKz.kz_blue = CGFloat(hex & 0xff)
        self._kz = newKz
        return UIColor.init(newKz: self._kz)
    }
    
}

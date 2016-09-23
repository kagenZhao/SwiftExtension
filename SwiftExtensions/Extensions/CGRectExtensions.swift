//
//  CGRectExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

extension CGRect {
    var width: CGFloat {
        set {
            size.width = newValue
        }
        get {
            return size.width
        }
    }
    
    var height: CGFloat {
        set {
            size.height = newValue
        }
        get {
            return size.height
        }
    }
    
    var left: CGFloat {
        set {
            origin.x = newValue
        }
        get {
            return origin.x
        }
    }
    
    var top: CGFloat {
        set {
            origin.y = newValue
        }
        get {
            return origin.y
        }
    }
    var right: CGFloat {
        set {
            origin.x = newValue - width
        }
        get {
            return left + width
        }
    }
    
    var bottom: CGFloat {
        set {
            origin.y = newValue - height
        }
        get {
            return top + height
        }
    }
}

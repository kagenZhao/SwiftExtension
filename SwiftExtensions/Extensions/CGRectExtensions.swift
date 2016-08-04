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
            self.size.width = newValue
        }
        get {
            return self.size.width
        }
    }
    
    var height: CGFloat {
        set {
            self.size.height = newValue
        }
        get {
            return self.size.height
        }
    }
    
    var left: CGFloat {
        set {
            self.origin.x = newValue
        }
        get {
            return self.origin.x
        }
    }
    
    var top: CGFloat {
        set {
            self.origin.y = newValue
        }
        get {
            return self.origin.y
        }
    }
    var right: CGFloat {
        set {
            self.origin.x = newValue - self.width
        }
        get {
            return self.left + self.width
        }
    }
    
    var bottom: CGFloat {
        set {
            self.origin.y = newValue - self.height
        }
        get {
            return self.top + self.height
        }
    }
}

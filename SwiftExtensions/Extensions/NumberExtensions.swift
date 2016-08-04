//
//  NumberExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

extension Int {
    var cgfloat: CGFloat {
        get {
            return CGFloat(self)
        }
    }
    var float: Float {
        get {
            return Float(self)
        }
    }
    var double: Double {
        get {
            return Double(self)
        }
    }
    
    var Abs: Int {
        get {
            return abs(self)
        }
    }
   
}

extension Double {
    var int: Int {
        get {
            return Int(self)
        }
    }
    var float: Float {
        get {
            return Float(self)
        }
    }
    var cgfloat: CGFloat {
        get {
            return CGFloat(self)
        }
    }
    var Abs: Double {
        get {
            return abs(self)
        }
    }
    
}

extension Float {
    var cgfloat: CGFloat {
        get {
            return CGFloat(self)
        }
    }
    var int: Int {
        get {
            return Int(self)
        }
    }
    var double: Double {
        get {
            return Double(self)
        }
    }
    var Abs: Float {
        get {
            return abs(self)
        }
    }
}

extension CGFloat {
    var int: Int {
        get {
            return Int(self)
        }
    }
    var float: Float {
        get {
            return Float(self)
        }
    }
    var double: Double {
        get {
            return Double(self)
        }
    }
    var Abs: CGFloat {
        get {
            return abs(self)
        }
    }
}

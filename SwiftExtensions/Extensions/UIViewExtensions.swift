//
//  UIViewExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit
extension UIView {
    
    var left: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.x = newValue
            frame = newFrame
        }
        get {
            return frame.origin.x
        }
    }
    
    var top: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.y = newValue
            frame = newFrame
        }
        get {
            return frame.origin.y
        }
    }
    
    var width: CGFloat {
        set {
            var newFrame = frame
            newFrame.size.width = newValue
            frame = newFrame
        }
        get {
            return frame.size.width
        }
    }
    
    var height: CGFloat {
        set {
            var newFrame = frame
            newFrame.size.height = newValue
            frame = newFrame
        }
        get {
            return frame.size.height
        }
    }
    
    var right: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.x = newValue - width
            frame = newFrame
        }
        get {
            return left + width
        }
    }
    
    var bottom: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.y = newValue - height
            frame = newFrame
        }
        get {
            return top + height
        }
    }
}

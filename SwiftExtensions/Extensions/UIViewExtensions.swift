//
//  UIViewExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

extension UIView: KZRectProcotol {
    
    public var left: CGFloat {
        set {
            var newFrame = frame
            newFrame.left = newValue
            frame = newFrame
        }
        get {
            return frame.left
        }
    }
    
    public var top: CGFloat {
        set {
            var newFrame = frame
            newFrame.top = newValue
            frame = newFrame
        }
        get {
            return frame.top
        }
    }
    
    public var width: CGFloat {
        set {
            var newFrame = frame
            newFrame.width = newValue
            frame = newFrame
        }
        get {
            return frame.width
        }
    }
    
    public var height: CGFloat {
        set {
            var newFrame = frame
            newFrame.height = newValue
            frame = newFrame
        }
        get {
            return frame.height
        }
    }
    
    public var right: CGFloat {
        set {
            var newFrame = frame
            newFrame.right = newValue
            frame = newFrame
        }
        get {
            return frame.right
        }
    }
    
    public var bottom: CGFloat {
        set {
            var newFrame = frame
            newFrame.bottom = newValue
            frame = newFrame
        }
        get {
            return frame.bottom
        }
    }
}

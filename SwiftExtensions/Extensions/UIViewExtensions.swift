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
        
        set { frame.left = newValue }
        
        get { return frame.left }
    }
    
    public var top: CGFloat {
        
        set { frame.top = newValue }
        
        get { return frame.top }
    }
    
    public var width: CGFloat {
        
        set {frame.width = newValue }
        
        get { return frame.width }
    }
    
    public var height: CGFloat {
        
        set { frame.height = newValue }
        
        get { return frame.height }
    }
    
    public var right: CGFloat {
        
        set { frame.right = newValue }
        
        get { return frame.right }
    }
    
    public var bottom: CGFloat {
        
        set { frame.bottom = newValue }
        
        get { return frame.bottom }
    }
}

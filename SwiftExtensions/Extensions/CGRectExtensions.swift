//
//  CGRectExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public protocol KZRectProcotol {
    var left:   CGFloat { get set }
    var right:  CGFloat { get set }
    var top:    CGFloat { get set }
    var bottom: CGFloat { get set }
    var width:  CGFloat { get set }
    var height: CGFloat { get set }
}

extension CGRect: KZRectProcotol {
    
    public var width: CGFloat {
        
        set { size.width = newValue }
        
        get { return size.width }
    }
    
    public var height: CGFloat {
        
        set { size.height = newValue }
        
        get { return size.height }
    }
    
    public var left: CGFloat {
        
        set { origin.x = newValue }
        
        get { return origin.x }
    }
    
    public var top: CGFloat {
        
        set { origin.y = newValue }
        
        get { return origin.y }
    }
    public var right: CGFloat {
        
        set { origin.x = newValue - width }
        
        get { return left + width }
    }
    
    public var bottom: CGFloat {
        
        set { origin.y = newValue - height }
        
        get { return top + height }
    }
}

//
//  URL+KMRExtensions.swift
//  SwiftExtensions
//
//  Created by zhaoguoqing on 16/6/29.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation
import UIKit
extension URL: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(stringLiteral value: URL.StringLiteralType) {
        
        self = URL(string: value)!
    }
    
    public init(extendedGraphemeClusterLiteral value: URL.ExtendedGraphemeClusterLiteralType) {
        
        self = URL(string: value)!
    }
    
    public init(unicodeScalarLiteral value: URL.UnicodeScalarLiteralType) {
        
        self = URL(string: value)!
    }
    
}

extension TimeZone : ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: URL.StringLiteralType) {
        
        self = TimeZone.init(identifier: value) ?? TimeZone.init(abbreviation: value)!
    }
}

extension CGRect: ExpressibleByArrayLiteral {
    
    public typealias Element = CGFloat
    
    public init(arrayLiteral elements: Element...) {
        
        let x = elements.count > 0 ? elements[0] : 0
        
        let y = elements.count > 1 ? elements[1] : 0
        
        let w = elements.count > 2 ? elements[2] : 0
        
        let h = elements.count > 3 ? elements[3] : 0
        
        self = .init(x: x, y: y, width: w, height: h)
    }
}

extension CGPoint: ExpressibleByArrayLiteral {
    
    public typealias Element = CGFloat
    
    public init(arrayLiteral elements: Element...) {
        
        let x = elements.count > 0 ? elements[0] : 0
        
        let y = elements.count > 1 ? elements[1] : 0
        
        self = .init(x: x, y: y)
    }
}

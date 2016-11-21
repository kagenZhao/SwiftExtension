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
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(stringLiteral value: URL.StringLiteralType) {
        
        self = TimeZone.init(identifier: value) ?? TimeZone.init(abbreviation: value)!
    }
    
    public init(extendedGraphemeClusterLiteral value: URL.ExtendedGraphemeClusterLiteralType) {
        
        self = TimeZone.init(identifier: value) ?? TimeZone.init(abbreviation: value)!
    }
    
    public init(unicodeScalarLiteral value: URL.UnicodeScalarLiteralType) {
        
        self = TimeZone.init(identifier: value) ?? TimeZone.init(abbreviation: value)!
    }
    
}

extension CGRect: ExpressibleByArrayLiteral {
    
    public typealias Element = CGFloat
    
    public init(arrayLiteral elements: Element...) {
        
        guard elements.count == 4 else { self = .zero; return }
        
        self = .init(x: elements[0], y: elements[1], width: elements[2], height: elements[3])
    }
}



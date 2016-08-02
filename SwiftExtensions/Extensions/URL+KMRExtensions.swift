//
//  URL+KMRExtensions.swift
//  SwiftExtensions
//
//  Created by zhaoguoqing on 16/6/29.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation
extension URL: StringLiteralConvertible {
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



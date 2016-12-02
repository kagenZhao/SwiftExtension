//
//  StringExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public extension String {
    
    public func subString(to idx: Int) -> String {
        
        return substring(to: index(startIndex, offsetBy: idx))
    }
    
    public func subString(from idx: Int) -> String {
        
        return substring(from: index(startIndex, offsetBy: idx))
    }
    
    public func subString(withStart start: Int, end: Int) -> String {
        
        let range = Range<Index>(uncheckedBounds: (lower: index(startIndex, offsetBy: start), upper: index(startIndex, offsetBy: end)))
        
        return substring(with: range)
    }
    
    public func subString(range: NSRange) -> String {
        
        return subString(withStart: range.location, end: range.location + range.length)
    }
}

/// 生成一个随机的UUID
public extension String {
    
    public static func newUUID() -> String {
        
        let uuidRef = CFUUIDCreate(nil)
        
        let uuidStr = CFUUIDCreateString(nil, uuidRef)
        
        let uuid: String = uuidStr as! String
        
        return uuid
    }
}

public extension String {
    
    public var md5: String {
        
        let bytes = [UInt8](self.utf8)
        
        let digest = kz_md5(bytes: bytes)
        
        return encodeMD5Digest(digest: digest.digest)
    }
}

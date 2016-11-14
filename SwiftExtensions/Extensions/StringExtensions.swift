//
//  StringExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

extension String {
    func subString(to idx: Int) -> String {
        return substring(to: index(startIndex, offsetBy: idx))
    }
    
    func subString(from idx: Int) -> String {
        return substring(from: index(startIndex, offsetBy: idx))
    }
    
    func subString(withStart start: Int, end: Int) -> String {
        let range = Range<Index>(uncheckedBounds: (lower: index(startIndex, offsetBy: start), upper: index(startIndex, offsetBy: end)))
        return substring(with: range)
    }
}

extension String {
    static func uuid() -> String {
        let uuidRef = CFUUIDCreate(nil)
        let uuidStr = CFUUIDCreateString(nil, uuidRef)
        let uuid: String = uuidStr as! String
        return uuid
    }
}

extension String {
    public var md5: String {
        let bytes = [UInt8](self.utf8)
        let digest = kz_md5(bytes: bytes)
        return encodeMD5Digest(digest: digest.digest)
    }
}

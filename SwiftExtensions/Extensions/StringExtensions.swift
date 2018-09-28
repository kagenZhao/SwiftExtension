//
//  StringExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public extension String {
    
//    public func subString(to idx: Int) -> String {
//
//        return substring(to: index(startIndex, offsetBy: idx))
//    }
//
//    public func subString(from idx: Int) -> String {
//
//        return substring(from: index(startIndex, offsetBy: idx))
//    }
//
//    public func subString(withStart start: Int, end: Int) -> String {
//
//        let range = Range<Index>(uncheckedBounds: (lower: index(startIndex, offsetBy: start), upper: index(startIndex, offsetBy: end)))
//
//        return substring(with: range)
//    }
//
//    public func subString(range: NSRange) -> String {
//
//        return subString(withStart: range.location, end: range.location + range.length)
//    }
}

/// 计算size
public extension String {
    public func width(with height: CGFloat, font: UIFont) -> CGFloat {
        return size(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), font: font).width
    }
    
    public func height(with width: CGFloat, font: UIFont) -> CGFloat {
        return size(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), font: font).height
    }
    
    public func size(with size: CGSize, font: UIFont) -> CGSize {
        return rect(with: size, font: font).size
    }
    
    public func rect(with size: CGSize, font: UIFont) -> CGRect {
        return self.boundingRect(with: size,
                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], context: nil)
    }
}



/// 生成一个随机的UUID
public extension String {
    
    public static func newUUID() -> String {
        
        guard let uuidRef = CFUUIDCreate(nil) else { fatalError() }
        
        guard let uuidStr = CFUUIDCreateString(nil, uuidRef) else { fatalError() }
        
        return uuidStr as String
    }
}

public extension String {
    
    public var md5: String {
        
        let bytes = [UInt8](self.utf8)
        
        let digest = SwiftMD5_md5(bytes: bytes)
        
        return encodeMD5Digest(digest: digest.digest)
    }
}



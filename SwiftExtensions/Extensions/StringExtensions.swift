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
    func width(with height: CGFloat, font: UIFont) -> CGFloat {
        return size(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), font: font).width
    }
    
    func height(with width: CGFloat, font: UIFont) -> CGFloat {
        return size(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), font: font).height
    }
    
    func size(with size: CGSize, font: UIFont) -> CGSize {
        return rect(with: size, font: font).size
    }
    
    func rect(with size: CGSize, font: UIFont) -> CGRect {
        return self.boundingRect(with: size,
                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], context: nil)
    }
}



/// 生成一个随机的UUID
public extension String {
    
    static func newUUID() -> String {
        return UUID().uuidString
    }
}

public extension String {
    
    var md5: String {
        
        let bytes = [UInt8](self.utf8)
        
        let digest = SwiftMD5_md5(bytes: bytes)
        
        return encodeMD5Digest(digest: digest.digest)
    }
}

public extension String {
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? self
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? self
    }
}

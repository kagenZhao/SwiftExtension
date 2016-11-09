//
//  DataExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}

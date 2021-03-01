//
//  DataExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation

extension Data {
    
    /// data -> string
    var hexString: String {
        withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> String in
            ptr.map { String(format: "%02hhx", $0) }.reduce("", { $0 + $1 })
        }
    }
}

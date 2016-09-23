//
//  001.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/9/20.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation
// 允许在方法中使用关键字 in 等
func foo(in _: String, protocol: AnyObject) -> AnyObject? {
    return nil
}

// 但是  inout关键字 还是必须要添加 `` 关键字 才能编译通过
func foo1(`inout` _: String, in: AnyObject) {
    
}


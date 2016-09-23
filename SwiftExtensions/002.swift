//
//  002.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/9/20.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation
// 取消 currying (柯里化)


/// before

// func foo(x: Int)(y: Int) {}

// now
func foo(x: Int) -> (Int) -> Int {
    return { y in
        return x + y;
    }
}

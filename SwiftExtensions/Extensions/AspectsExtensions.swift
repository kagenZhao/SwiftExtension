//
//  AspectsExtensions.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2017/5/22.
//  Copyright © 2017年 kagenZhao. All rights reserved.
//

import Foundation
import Aspects

public func aspecBlock<R>(_ block: @escaping (AspectInfo)-> R) -> Any {
    if R.self == Void.self {
        let objc: @convention(block) (AspectInfo) -> Void = { info in _ = block(info) }
        return unsafeBitCast(objc, to: AnyObject.self)
    } else {
        let objc: @convention(block) (AspectInfo) -> Any! = { info in return block(info) }
        return unsafeBitCast(objc, to: AnyObject.self)
    }
}

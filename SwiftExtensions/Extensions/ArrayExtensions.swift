//
//  ArrayExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/18.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    mutating public func remove(_ objc: Element) {
        self = filter { $0 != objc }
    }
}

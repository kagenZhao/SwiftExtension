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

extension Array {
    
    ///  eachConsecutive
    ///
    /// - Parameter n: 需要截取的单位数组个数
    /// - Returns: 按照 n 的数字 从0开始拆分数组
    ///        如: var arr = [1,2,3,4,5,6,7,8,9,0]
    ///            arr.eachConsecutive()
    ///            结果为:  [ArraySlice([1, 2, 3, 4, 5]), ArraySlice([2, 3, 4, 5, 6]),
    ///                     ArraySlice([3, 4, 5, 6, 7]), ArraySlice([4, 5, 6, 7, 8]),
    ///                     ArraySlice([5, 6, 7, 8, 9]), ArraySlice([6, 7, 8, 9, 0])]
    public func eachConsecutive(_ n: Int) -> Array<ArraySlice<Iterator.Element>> {
        return (0..<(count-n+1)).map({ i in
            return self[i..<i+n]
        })
    }
}

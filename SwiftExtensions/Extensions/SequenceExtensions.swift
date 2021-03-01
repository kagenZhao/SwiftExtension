//
//  SequenceExtensions.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2017/5/16.
//  Copyright © 2017年 kagenZhao. All rights reserved.
//

import Foundation

extension Sequence where Element: Sequence, Element.Iterator.Element == Iterator.Element {
    public func eachPair() -> AnySequence<(Iterator.Element, Iterator.Element)> {
        return AnySequence(zip(self, self.dropFirst()))
    }
}

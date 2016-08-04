//
//  StringExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

extension String {
    func subString(to index: Int) -> String {
        return self.substring(to: self.index(self.startIndex, offsetBy: index))
    }
    
    func subString(from index: Int) -> String {
        return self.substring(from: self.index(self.startIndex, offsetBy: index))
    }
    
    func subString(withStart start: Int, end: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.startIndex, offsetBy: end)
        let range = Range<Index>.init(uncheckedBounds: (lower: startIndex, upper: endIndex))
        return self.substring(with: range)
    }
}

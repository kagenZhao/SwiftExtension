//
//  SwiftExtensionsTests.swift
//  SwiftExtensionsTests
//
//  Created by Kagen Zhao on 2016/11/25.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import XCTest

@testable import SwiftExtensions

var onceKey: Void?

class SwiftExtensionsTests: XCTestCase {
    
    var label = UILabel()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        var num = 0
        for _ in 0..<10 {
            DispatchQueue.once(&onceKey, execute: {
                num += 1
            })
        }
        XCTAssert(num == 1, "mast be once")
        
        let str = "salskb;labds"
        _ = str.md5
        
        
        
        
        
        
    }
    
}

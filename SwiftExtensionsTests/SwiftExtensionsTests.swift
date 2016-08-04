//
//  SwiftExtensionsTests.swift
//  SwiftExtensionsTests
//
//  Created by zhaoguoqing on 16/6/29.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import XCTest
@testable import SwiftExtensions

class SwiftExtensionsTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
       
    }
    
    override func tearDown() {
       
        super.tearDown()
    }
    
    func testExample() {
      
    }
    
    func testUIViewExtensions() {
        let view = UIView(frame: CGRect(x: 200, y: 88, width: 400, height: 94))
        check(view: view)
        
    }
    
    func check(view: UIView) {
        if view.width != view.frame.size.width {
            XCTFail("width error: \(view.width)")
        }
        
        if view.height != view.frame.size.height {
            XCTFail("width error: \(view.height)")
        }
        
        if view.top != view.frame.origin.y {
            XCTFail("width error: \(view.top)")
        }
        
        if view.left != view.frame.origin.x {
            XCTFail("width error: \(view.left)")
        }
        
        if view.right != view.frame.size.width + view.frame.origin.x {
            XCTFail("width error: \(view.right)")
        }
        
        if view.bottom != view.frame.size.height + view.frame.origin.y {
            XCTFail("width error: \(view.bottom)")
        }
        
        view.width = 20
        XCTAssertTrue(view.frame.size.width == 20)
        view.height = 30
         XCTAssertTrue(view.frame.size.height == 30)
        view.top = 40
        XCTAssertTrue(view.frame.origin.y == 40)
        view.left = 50
        XCTAssertTrue(view.frame.origin.x == 50)
        view.right = 60
        XCTAssertTrue(view.frame.origin.x + view.frame.size.width == 60)
        view.bottom = 70
        XCTAssertTrue(view.frame.origin.y + view.frame.size.height == 70)
    }
    
    func testStringExtension() {
        let str = "aksnd2lkj3b42k3j4b][/*--.LOJBLKJ˙√¬∆˚ß∑∫∂…¬åÍ Ï…Ø∑´ÓˆŒ"
        XCTAssertTrue(str.subString(to: 5) == "aksnd")
        XCTAssertTrue(str.subString(from: 5) == "2lkj3b42k3j4b][/*--.LOJBLKJ˙√¬∆˚ß∑∫∂…¬åÍ Ï…Ø∑´ÓˆŒ")
    }
    
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

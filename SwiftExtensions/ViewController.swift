//
//  ViewController.swift
//  SwiftExtensions
//
//  Created by zhaoguoqing on 16/6/29.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            let s = try test(b: false)
            print(s)
        } catch let error {
            print(error)
        }

    }
    
    func test(b: Bool) throws -> String {
        if b {
            return "true"
        } else {
            let error = NSError(domain: "error", code: 001, userInfo: nil)
            throw error
        }
    }
    
    
    
    
    
    
}





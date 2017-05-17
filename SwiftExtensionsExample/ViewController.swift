//
//  ViewController.swift
//  SwiftExtensionsExample
//
//  Created by 赵国庆 on 2017/5/15.
//  Copyright © 2017年 kagenZhao. All rights reserved.
//

import UIKit
import SwiftExtensions

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.setupForceTouchAction(begin: { (t, e) in
            print("begin")
        }, updating: { (t, e) in
            print("update\(t.force)")
        }, end: { (t, e) in
            print("end")
        }) { (e) in
            print("cancel")
        }        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


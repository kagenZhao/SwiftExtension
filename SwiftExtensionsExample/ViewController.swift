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
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.setupNumberKeyboard(min: 0, max: 100000)
        tf2.setupNumberKeyboard(min: 100, max: 999)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


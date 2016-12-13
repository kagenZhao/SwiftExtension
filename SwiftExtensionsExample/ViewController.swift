//
//  ViewController.swift
//  SwiftExtensionsExample
//
//  Created by Kagen Zhao on 2016/12/2.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import SwiftExtensions
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        v1.backgroundColor = UIColor(ciColor: CIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
        v2.backgroundColor = #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 1)

    }
}




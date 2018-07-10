//
//  ViewController.swift
//  SwiftExtensionsExample
//
//  Created by 赵国庆 on 2017/5/15.
//  Copyright © 2017年 kagenZhao. All rights reserved.
//

import UIKit
import SwiftExtensions
import RxCocoa
import RxSwift
import ReactiveCocoa
import MediaPlayer

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func action1(_ sender: Any) {
        print(AppInfo.Device.volume)
    }
    
    @IBAction func action2(_ sender: Any) {
        AppInfo.Device.volume = 1
    }
    

}


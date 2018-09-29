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
import WebKit
import DeviceKit


class NavigationController: UINavigationController {
    override func popViewController(animated: Bool) -> UIViewController? {
        print("调用了popViewController");
        print(self.viewControllers.last)
        return super.popViewController(animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        print("调用了popToRootViewController");
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        print("调用了popToViewController");
        return super.popToViewController(viewController, animated: animated)
    }
}

class ViewController: UIViewController {
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
//        UIDevice.current.setValue(NSNumber.init(value: UIDeviceOrientation.unknown.rawValue), forKey: "orientation")
//        UIDevice.current.setValue(NSNumber.init(value: UIDeviceOrientation.portrait.rawValue), forKey: "orientation")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        UIDevice.current.setValue(NSNumber.init(value: UIDeviceOrientation.unknown.rawValue), forKey: "orientation")
//        UIDevice.current.setValue(NSNumber.init(value: UIDeviceOrientation.portrait.rawValue), forKey: "orientation")
    }
    
    @IBAction func zhiwen(_ sender: Any) {
        self.navigationController?.pushViewController(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController"), animated: true)
    }
    
    @IBAction func shoushi(_ sender: Any) {
      
    }
}

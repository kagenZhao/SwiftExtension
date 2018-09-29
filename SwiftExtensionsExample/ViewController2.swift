//
//  ViewController2.swift
//  SwiftExtensionsExample
//
//  Created by 赵国庆 on 2018/9/28.
//  Copyright © 2018 kagenZhao. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIDevice.current.setValue(NSNumber.init(value: UIDeviceOrientation.unknown.rawValue), forKey: "orientation")
//        UIDevice.current.setValue(NSNumber.init(value: UIDeviceOrientation.landscapeRight.rawValue), forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        UIDevice.current.setValue(NSNumber.init(value: UIDeviceOrientation.unknown.rawValue), forKey: "orientation")
//        UIDevice.current.setValue(NSNumber.init(value: UIDeviceOrientation.portrait.rawValue), forKey: "orientation")
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var prefersStatusBarHidden: Bool  {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
//        self.navigationController?.pushViewController(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController1"), animated: true)
    }
}

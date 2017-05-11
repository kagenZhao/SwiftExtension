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

class MyClass: ViewController {
    
}

class ViewController: UIViewController {
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
        
        
        
        let button = UIButton(frame: CGRect.init(x: 100, y: 100, width: 40, height: 40))
        button.setTitle("button", for: .normal)
        button.addTarget(self, action: #selector(buttonAction1), for: .touchUpInside)
        view.addSubview(button)
        
        
        let button2 = UIButton(frame: CGRect.init(x: 100, y: 300, width: 40, height: 40))
        button2.setTitle("button", for: .normal)
        button2.addTarget(self, action: #selector(buttonAction2), for: .touchUpInside)
        view.addSubview(button2)
        
        

    }
    
    
    @objc func  buttonAction1(){
        
        let arr = ["ViewController", "MyClass"]
//        Router.shared.navigate(to: .url(["ViewController", "MyClass","ViewController", "MyClass"], args: nil, forceBackFirstPage: false))
        Router.shared.navigate(to: .controller(.name(arr[0]), args: nil), sameControllerType: .replace)
    }
    
    @objc func  buttonAction2(){
        
        
        let message = "1, aaaaaaaaaaaaaaaaaa\n2, bbbbbbbbbbbbbbbbbbbbbbbbb\n3, ss"
        let alert = UIAlertController(title: "Title", message: message, preferredStyle: .alert)
        
        alert.setAttributes([.message([.alignment(.left), .textColor(.red)]),
                             .title([.alignment(.right), .font(.systemFont(ofSize: 50)), .textColor(.blue)])])
        
        alert.addAction(UIAlertAction(title: "action1", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

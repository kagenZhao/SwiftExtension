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
        
//        let url: URL = "https://www.baidu.com"
        
        let url2 = URL(string: "https://www.baidu.com")!
        
        
        let webview = UIWebView(frame: view.bounds)
        view.addSubview(webview)
        webview.loadRequest(URLRequest(url: url2))
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


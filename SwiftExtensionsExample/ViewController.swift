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

class ViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    
    lazy var uiwebview: UIWebView = {
        let webView = UIWebView(frame: CGRect(x: 0, y: 70, width: view.bounds.size.width, height: 250))
        webView.delegate = self
        return webView
    }()
    lazy var wkwebview: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 400, width: view.bounds.size.width, height: 250), configuration: config)
        webView.navigationDelegate = self
        return webView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(uiwebview)
        view.addSubview(wkwebview)
        
        let url = URL(string: "https://www.kagenz.com")
        let request = URLRequest(url: url!)
        uiwebview.loadRequest(request)
        wkwebview.load(request)
    }
  
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        print("~UIWebView      \(request.allHTTPHeaderFields ?? [:])")
        return true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("~WKWebView      \(navigationAction.request.allHTTPHeaderFields ?? [:])")
        decisionHandler(.allow)
    }

}


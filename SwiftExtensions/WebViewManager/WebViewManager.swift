//
//  WebViewManager.swift
//  wmIOS
//
//  Created by 赵国庆 on 2018/7/19.
//  Copyright © 2018年 yy. All rights reserved.
//

import UIKit
import WebKit


public class WebViewManager {
    public static let shared = WebViewManager()
    public private(set) var headers: [String : String] = [:]
    public private(set) var secheme: [String] = []
    private var haveRegisted = false
    public func config(headers: [String: String], for secheme: [String]) {
        let oldSecheme = self.secheme
        
        self.headers = headers
        self.secheme = secheme
        // Plan A
        if !haveRegisted {
            UIWebView.exchangeLoad()
            WKWebView.exchangeLoad()
        }
        
        //Plan B
//        if !haveRegisted {
//            URLProtocol.registerClass(GlobleURLRequestProtocol.self) // 默认只对UIWebView有效
//            if oldSecheme.count > 0 { WKWebView.unregisterScheme(oldSecheme) }
//        }
//        WKWebView.registerScheme(schemes: secheme) // 为了使上式对WKWebView也有效 必须hook WebKit内部方法
        
        
        haveRegisted = true
    }
    private init() {}
}

private let _kPropertyKey = "cn.com.cicc.GlobleURLRequestProtocol"
private class GlobleURLRequestProtocol: URLProtocol, URLSessionDataDelegate {
    
    private var _task: URLSessionTask?
    override var task: URLSessionTask? { return _task }
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        var resultRequest = request
        resultRequest.setupGlobleConfig()
        super.init(request: resultRequest, cachedResponse: cachedResponse, client: client)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        if let scheme = request.url?.scheme?.lowercased(),
            WebViewManager.shared.secheme.contains(scheme),
            (URLProtocol.property(forKey: _kPropertyKey, in: request) == nil) {
            return true
        } else {
            return false
        }
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        var resultRequest = request
        resultRequest.setupGlobleConfig()
        return resultRequest
    }
    
    override func startLoading() {
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: _kPropertyKey, in: mutableRequest)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        _task = session.dataTask(with: mutableRequest as URLRequest)
        _task?.resume()
    }
    
    override func stopLoading() {
        if let task = _task {
            task.cancel()
            _task = nil
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        completionHandler(proposedResponse)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error {
            self.client?.urlProtocol(self, didFailWithError: err)
        } else {
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
}

public extension  URLRequest {
    mutating public func setupGlobleConfig() {
        WebViewManager.shared.headers.forEach({ (header) in
            setValue(header.value, forHTTPHeaderField: header.key)
        })
    }
}

extension UIWebView {
    fileprivate static func exchangeLoad() {
        exchangeMethod(cls: UIWebView.self, from: #selector(loadRequest(_:)), to: #selector(_hook_loadRequest(_:)))
        exchangeMethod(cls: UIWebView.self, from: NSSelectorFromString("setDelegate:"), to: #selector(_hook_setDelegate(_:)))
    }

    @objc dynamic private func _hook_loadRequest(_ request: URLRequest) {
        var resultRquest = request
        WebViewManager.shared.headers.forEach({ (header) in
            resultRquest.setValue(header.value, forHTTPHeaderField: header.key)
        })
        _hook_loadRequest(resultRquest)
    }
    @objc dynamic private func _hook_setDelegate(_ delegate: UIWebViewDelegate) {
        NSObject.exchangeMethod(fromCls: type(of: delegate), toCls: UIWebView.self, fromSel: #selector(webView(_:shouldStartLoadWith:navigationType:)), toSel: #selector(_hook_webView(_:shouldStartLoadWith:navigationType:)))
        _hook_setDelegate(delegate)
    }
    
    // 防止delegate 未实现代理方法
    @objc dynamic func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool{ return true }
    @objc dynamic private func _hook_webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        guard
            WebViewManager.shared.headers.count > 0,
            let scheme = request.url?.scheme?.lowercased(), WebViewManager.shared.secheme.contains(scheme)
            else { return _hook_webView(webView, shouldStartLoadWith: request, navigationType: navigationType) }
        
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in WebViewManager.shared.headers {
                guard let requestHeaderValue = headers[key], requestHeaderValue == value else {
                    var newRequest = request
                    newRequest.setupGlobleConfig()
                    webView.loadRequest(newRequest)
                    return false
                }
            }
            return _hook_webView(webView, shouldStartLoadWith: request, navigationType: navigationType)
        } else {
            var newRequest = request
            newRequest.setupGlobleConfig()
            webView.loadRequest(newRequest)
            return false
        }
    }
}


extension WKWebView {
    fileprivate static func exchangeLoad() {
        exchangeMethod(cls: WKWebView.self, from: #selector(load(_:)), to: #selector(_hook_load(_:)))
        exchangeMethod(cls: WKWebView.self, from: NSSelectorFromString("setNavigationDelegate:"), to: #selector(_hook_setNavigationDelegate(_:)))
    }
    
    fileprivate static func registerScheme(schemes: [String]) {
        guard let context = WKWebView().value(forKey: "browsingContextController"),
            let cls = (type(of: context) as AnyObject) as? NSObjectProtocol // 这里编译警告 但是实际运行是可以的
            else {
                return
        }
        let sel = NSSelectorFromString("registerSchemeForCustomProtocol:")
        if cls.responds(to: sel) {
            schemes.forEach { (scheme) in
                cls.perform(sel, with: scheme)
            }
        }
    }
    
    fileprivate static func unregisterScheme(_ schemes: [String]) {
        guard let context = WKWebView().value(forKey: "browsingContextController"),
            let cls = (type(of: context) as AnyObject) as? NSObjectProtocol // 这里编译警告 但是实际运行是可以的
            else {
                return
        }
        let sel = NSSelectorFromString("unregisterSchemeForCustomProtocol:")
        if cls.responds(to: sel) {
            schemes.forEach { (scheme) in
                cls.perform(sel, with: scheme)
            }
        }
    }
    
    @objc dynamic private func _hook_setNavigationDelegate(_ delegate: WKNavigationDelegate) {
//        NSObject.exchangeMethod(fromCls: type(of: delegate),
//                                toCls: WKWebView.self,
//                                fromSel: NSSelectorFromString("webView:decidePolicyForNavigationAction:decisionHandler:"),
//                                toSel: #selector(_hook_webView(_:decidePolicyFor:decisionHandler:)))
        _hook_setNavigationDelegate(delegate)
    }

    @objc dynamic private func _hook_load(_ request: URLRequest) -> WKNavigation? {
        var resultRquest = request
        WebViewManager.shared.headers.forEach({ (header) in
            resultRquest.setValue(header.value, forHTTPHeaderField: header.key)
        })
        return _hook_load(resultRquest)
    }
    
    @objc dynamic private func webView(_ webView: WKWebView, decidePolicyForNavigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) { decisionHandler(.allow) }
    @objc dynamic private func _hook_webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        guard
            WebViewManager.shared.headers.count > 0,
            let scheme = navigationAction.request.url?.scheme?.lowercased(),
            WebViewManager.shared.secheme.contains(scheme)
            else { return _hook_webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler) }
        
        if let headers = navigationAction.request.allHTTPHeaderFields {
            for (key, value) in WebViewManager.shared.headers {
                guard let requestHeaderValue = headers[key], requestHeaderValue == value else {
                    var newRequest = navigationAction.request
                    newRequest.setupGlobleConfig()
                    webView.load(newRequest)
                    decisionHandler(.cancel)
                    return
                }
            }
            return _hook_webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        } else {
            var newRequest = navigationAction.request
            newRequest.setupGlobleConfig()
            webView.load(newRequest)
            decisionHandler(.cancel)
        }
    }
    
}


extension NSObject {
    fileprivate static func exchangeMethod(cls: AnyClass, from: Selector, to: Selector) {
        let originalSelector = from
        let swizzledSelector = to
        guard let originalMethod = class_getInstanceMethod(cls, originalSelector),
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector) else {
                return
        }
        if (class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
            class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }

    fileprivate static func exchangeMethod(fromCls: AnyClass, toCls: AnyClass, fromSel: Selector, toSel: Selector) {
        let oldSelector = fromSel
        let newSelector = toSel
//        let newMethod_to = class_getInstanceMethod(toCls, newSelector)!
//        guard class_addMethod(fromCls, newSelector, method_getImplementation(newMethod_to), method_getTypeEncoding(newMethod_to)) else {
//            // 这么巧 源类 也实现了 新方法 ???  你咋不上天!
//            return
//        }
//        let newMethod_from = class_getInstanceMethod(fromCls, newSelector)!
//        if class_addMethod(fromCls, oldSelector, method_getImplementation(newMethod_from), method_getTypeEncoding(newMethod_from)) {
//            let oldMethod_from = class_getInstanceMethod(fromCls, oldSelector)!
//            class_replaceMethod(fromCls, newSelector, method_getImplementation(oldMethod_from), method_getTypeEncoding(oldMethod_from))
//        } else {
//            let oldMethod_from = class_getInstanceMethod(fromCls, oldSelector)!
//            method_exchangeImplementations(oldMethod_from, newMethod_from)
//        }
        
        let newMethod_to = class_getInstanceMethod(toCls, newSelector)!
        let oldMethod_to = class_getInstanceMethod(toCls, oldSelector)!
        let oldMethod_from = class_getInstanceMethod(fromCls, oldSelector)
        if oldMethod_from == nil { // 源类未实现原始方法
            class_addMethod(fromCls, oldSelector, method_getImplementation(newMethod_to), method_getTypeEncoding(newMethod_to))
            class_addMethod(fromCls, newSelector, method_getImplementation(oldMethod_to), method_getTypeEncoding(oldMethod_to))
        } else {
            if class_addMethod(fromCls, newSelector, method_getImplementation(newMethod_to), method_getTypeEncoding(newMethod_to)) {
                let newMethod_from = class_getInstanceMethod(fromCls, newSelector)!
                class_replaceMethod(fromCls, oldSelector, method_getImplementation(newMethod_from), method_getTypeEncoding(newMethod_from))
            } else {
                method_exchangeImplementations(oldMethod_from!, class_getInstanceMethod(fromCls, newSelector)!)
            }
        }
    }
}


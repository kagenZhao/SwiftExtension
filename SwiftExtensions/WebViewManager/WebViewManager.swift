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
    public private(set) var secheme: Set<String> = []
    private var haveRegisted = false
    public func config<T: Sequence>(headers: [String: String], for secheme: T) where T.Element == String {
        
        let oldSecheme = self.secheme
        
        self.headers = headers
        self.secheme = Set(secheme)
        /// Plan A
        /// 优点: 因为其作用时间在开始请求之前的代理方法中, 所以在UIWebView/WKWebView 可以看到对request的修改内容 方便调试
        /// 缺点: 1, 大量运用runtime 在将来的项目中有风险
        ///      2,
        if !haveRegisted {
            UIWebView.exchangeLoad()
            WKWebView.exchangeLoad()
        }
        
        /// Plan B
        /// 优点: runtime 用量少 用途广泛 除了可以用在webview上 还可以用在普通的网络请求中
        /// 缺点: 因为其作用时间在开始请求之时, 所以在UIWebView/WKWebView 的代理方法中无法看到对request的修改内容 不方便调试
        /// WKWebView 会存在问题 不建议用
        if !haveRegisted {
            URLProtocol.registerClass(GlobleURLRequestProtocol.self) // 默认只对UIWebView有效
            let diff = oldSecheme.subtracting(self.secheme)
            if diff.count > 0 { WKWebView.unregisterScheme(diff) }
        }
        WKWebView.registerScheme(schemes: self.secheme.subtracting(oldSecheme)) // 为了使上式对WKWebView也有效 必须hook WebKit内部方法
        
        haveRegisted = true
    }
    private init() {}
}

private let _kPropertyKey = "cn.com.kagenz.GlobleURLRequestProtocol"
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
    mutating func setupGlobleConfig() {
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
        NSObject.exchangeMethod(fromCls: type(of: delegate),
                                toCls: UIWebView.self,
                                fromSel: #selector(UIWebViewDelegate.webView(_:shouldStartLoadWith:navigationType:)),
                                toSel: #selector(_hook_webView(_:shouldStartLoadWith:navigationType:)))
        _hook_setDelegate(delegate)
    }
    
    // 防止delegate 未实现代理方法
    @objc dynamic private func webView(_ webView: UIWebView, shouldStartLoadWithRequest: URLRequest, navigationType: UIWebView.NavigationType) -> Bool{ return true }
    @objc dynamic private func _hook_webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        guard
            WebViewManager.shared.headers.count > 0,
            let scheme = request.url?.scheme?.lowercased(),
            WebViewManager.shared.secheme.contains(scheme)
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


extension NSObjectProtocol {
    fileprivate func safePerform<T: Sequence>(sel: Selector, with repeatArguments: T) {
        if self.responds(to: sel) {
            repeatArguments.forEach { (arg) in
                self.perform(sel, with: arg)
            }
        }
    }
}

extension WKWebView {
    fileprivate static func exchangeLoad() {
        exchangeMethod(cls: WKWebView.self, from: #selector(load(_:)), to: #selector(_hook_load(_:)))
        exchangeMethod(cls: WKWebView.self, from: NSSelectorFromString("setNavigationDelegate:"), to: #selector(_hook_setNavigationDelegate(_:)))
    }
    
    fileprivate static var registerSchemeSelector: Selector { return NSSelectorFromString("registerSchemeForCustomProtocol:") }
    
    fileprivate static var unregisterSchemeSelector: Selector { return NSSelectorFromString("unregisterSchemeForCustomProtocol:") }
    
    fileprivate static var browsingContext: NSObjectProtocol? { return (type(of: WKWebView().value(forKey: "browsingContextController")) as AnyObject) as? NSObjectProtocol }
    
    fileprivate static func registerScheme<T: Sequence>(schemes: T) where T.Element == String {
        guard let context = browsingContext else { return }
        context.safePerform(sel: registerSchemeSelector, with: schemes)
    }
    
    fileprivate static func unregisterScheme<T: Sequence>(_ schemes: T) where T.Element == String {
        guard let context = browsingContext else { return }
        context.safePerform(sel: unregisterSchemeSelector, with: schemes)
    }
    
    @objc dynamic private func _hook_setNavigationDelegate(_ delegate: WKNavigationDelegate) {
        NSObject.exchangeMethod(fromCls: type(of: delegate),
                                toCls: WKWebView.self,
                                fromSel: NSSelectorFromString("webView:decidePolicyForNavigationAction:decisionHandler:"),
                                toSel: #selector(_hook_webView(_:decidePolicyFor:decisionHandler:)))
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
        let newMethod_to = class_getInstanceMethod(toCls, newSelector)!
        let oldMethod_to = class_getInstanceMethod(toCls, oldSelector)!
        let oldMethod_from = class_getInstanceMethod(fromCls, oldSelector)
        if oldMethod_from == nil { // 源类未实现原始方法
            var success = class_addMethod(fromCls, oldSelector, method_getImplementation(newMethod_to), method_getTypeEncoding(newMethod_to))
            success = class_addMethod(fromCls, newSelector, method_getImplementation(oldMethod_to), method_getTypeEncoding(oldMethod_to))
            print(success)
        } else {
            if class_addMethod(fromCls, newSelector, method_getImplementation(newMethod_to), method_getTypeEncoding(newMethod_to)) { // 源类未添加新方法
                let newMethod_from = class_getInstanceMethod(fromCls, newSelector)!
                method_exchangeImplementations(newMethod_from, oldMethod_from!)
            } else {
                // 也就是说走到这里就无需 在进行其他操作 因为已经交换过了
                // 这里本不应该进来 除非调用两次 请检查代码逻辑
                // method_exchangeImplementations(oldMethod_from!, class_getInstanceMethod(fromCls, newSelector)!)
            }
        }
    }
}


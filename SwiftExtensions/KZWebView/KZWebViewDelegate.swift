//
//  KZWebViewDelegate.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/10/15.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import WebKit

/// 私有类, 这个类不应该公开, 其他人不能使用
/// 这是一个代理的中间件
internal class _KZWebViewDelegate: NSObject {
    internal weak var navigationDelegate: WKNavigationDelegate?
    internal weak var uiDelegate: WKUIDelegate?
    
    private func judgmentUIDelegate(_ selector: Selector) -> Bool {
        guard let delegate = uiDelegate else { return false }
        return delegate.responds(to: selector)
    }
}

// MARK: WKUIDelegate
extension _KZWebViewDelegate: WKUIDelegate {
    // 页面是弹出窗口 _blank 处理
    // 拦截 window.open()事件
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if judgmentUIDelegate(#selector(WKUIDelegate.webView(_:createWebViewWith:for:windowFeatures:))) {
            return uiDelegate?.webView?(webView, createWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures)
        } else {
            if navigationAction.targetFrame == nil || !navigationAction.targetFrame!.isMainFrame {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }

    // window.close() 事件通知
    // 应该删除当前的controller
    func webViewDidClose(_ webView: WKWebView) {
        uiDelegate?.webViewDidClose?(webView)
    }

    // 提示框
    //JavaScript调用alert方法后回调的方法 alert是js中的提示框，需要在block中把用户选择的情况传递进去
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if uiDelegate?.webView?(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler) == nil {
            if let controller = webView.viewController() {
                if controller.isBeingPresented || controller.isBeingDismissed || controller.isMovingToParent || controller.isMovingFromParent {
                    completionHandler()
                    return
                }
                
                guard controller.isViewLoaded, controller.view.window != nil else {
                    completionHandler()
                    return
                }
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                    completionHandler()
                }))
                controller.present(alert, animated: true, completion: nil)
            } else {
                completionHandler()
            }
        }
    }
    
    // 确认框
    //JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if uiDelegate?.webView?(webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler) == nil {
            if let controller = webView.viewController() {
                if controller.isBeingPresented || controller.isBeingDismissed || controller.isMovingToParent || controller.isMovingFromParent {
                    completionHandler(false)
                    return
                }
                
                guard controller.isViewLoaded, controller.view.window != nil else {
                    completionHandler(false)
                    return
                }
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                    completionHandler(true)
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                    completionHandler(false)
                }))
                controller.present(alert, animated: true, completion: nil)
            } else {
                completionHandler(false)
            }
        }
    }

    // 输入框
    //JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if uiDelegate?.webView?(webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText, initiatedByFrame: frame, completionHandler: completionHandler) == nil {
            if let controller = webView.viewController() {
                if controller.isBeingPresented || controller.isBeingDismissed || controller.isMovingToParent || controller.isMovingFromParent {
                    completionHandler(nil)
                    return
                }
                
                guard controller.isViewLoaded, controller.view.window != nil else {
                    completionHandler(nil)
                    return
                }
                let alert = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
                alert.addTextField { (textfield) in
                    textfield.text = defaultText
                }
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak alert] (action) in
                    completionHandler(alert?.textFields?[0].text)
                }))
                controller.present(alert, animated: true, completion: nil)
            } else {
                completionHandler(nil)
            }
        }
    }

    // 是否允许预览 (3D touch)
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return uiDelegate?.webView?(webView, shouldPreviewElement: elementInfo) ?? false
    }

    // 预览 (3D touch peek)
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        return uiDelegate?.webView?(webView, previewingViewControllerForElement: elementInfo, defaultActions: previewActions) ?? nil
    }

    // 预览 (3D touch pop)
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        uiDelegate?.webView?(webView, commitPreviewingViewController: previewingViewController)
    }

    // 菜单栏处理, 返回自定义菜单
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        if uiDelegate?.webView?(webView, contextMenuConfigurationForElement: elementInfo, completionHandler: completionHandler) == nil {
            completionHandler(nil)
        }
    }

    // 菜单栏处理, 菜单将要呈现
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
        uiDelegate?.webView?(webView, contextMenuWillPresentForElement: elementInfo)
    }

    // 菜单栏处理, 用户点击了菜单
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        uiDelegate?.webView?(webView, contextMenuForElement: elementInfo, willCommitWithAnimator: animator)
    }

    // 菜单栏处理, 菜单栏消失
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
        uiDelegate?.webView?(webView, contextMenuDidEndForElement: elementInfo)
    }
    
    /// 这几个方法在如果respond 为true的话 即使返回了nil, 仍然会显示 预览界面
    /// 暂时只能通过重写respond 为false 来解决
    static let handleResponseSelectors: [String] = {
        var selectors: [String] = []
        if #available(iOS 13.0, *) {
            selectors.append(#selector(WKUIDelegate.webView(_:contextMenuConfigurationForElement:completionHandler:)).description)
            selectors.append(#selector(WKUIDelegate.webView(_:contextMenuWillPresentForElement:)).description)
            selectors.append(#selector(WKUIDelegate.webView(_:contextMenuForElement:willCommitWithAnimator:)).description)
            selectors.append(#selector(WKUIDelegate.webView(_:contextMenuDidEndForElement:)).description)
        }
        return selectors
    }()
     
    override func responds(to aSelector: Selector!) -> Bool {
        if _KZWebViewDelegate.handleResponseSelectors.contains(aSelector.description) {
            return judgmentUIDelegate(aSelector)
        } else {
            return super.responds(to: aSelector)
        }
    }
}

// MARK: WKNavigationDelegate
extension _KZWebViewDelegate: WKNavigationDelegate {
    /// 额外处理一些原生没有处理的事件
    private func webViewAdditionalProcesses(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) -> Bool {
        func tryOpen(_ url: URL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        guard let url = navigationAction.request.url else { return false }
        
        /// 处理 跳转苹果商店
        if let host = url.host, host == "itunes.apple.com" {
            tryOpen(url)
            return true
        }
        
        switch url.scheme {
        case "tel"?, "sms"?, "mailto"?:
            /// 处理 电话 / 短信 / 邮件
            tryOpen(url)
            return true
        default:
            return false
        }
    }
    
    // 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("KZWebView - 当前连接: \((navigationAction.request.url?.absoluteString ?? "nil").urlDecoded())")
        if webViewAdditionalProcesses(webView, decidePolicyFor: navigationAction) {
            decisionHandler(.cancel)
            return
        }
        if navigationDelegate?.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler) == nil {
            decisionHandler(.allow)
        }
    }
    
    // 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
    // 此方法处理 WKWebpagePreferences 的改变
    // 实现了次方法则上方的代理方法不会执行
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if webViewAdditionalProcesses(webView, decidePolicyFor: navigationAction) {
            decisionHandler(.cancel, preferences)
            return
        }
        if navigationDelegate?.webView?(webView, decidePolicyFor: navigationAction, preferences: preferences, decisionHandler: decisionHandler) == nil {
            self.webView(webView, decidePolicyFor: navigationAction) { (p) in
                decisionHandler(p, preferences)
            }
        }
    }
    
    // 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationDelegate?.webView?(webView, decidePolicyFor: navigationResponse, decisionHandler: decisionHandler) == nil {
            decisionHandler(.allow)
        }
        /// 暂时项目中只存在  WebView使用本地Cookie
        /// 所以反向同步先不处理
        /// 而且 ajax 的请求也不会走这里
        /// 所以暂时注释掉这段代码
//        if #available(iOS 12.0, *) {
//            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
//                cookies.forEach { (cookie) in
//                    HTTPCookieStorage.shared.setCookie(cookie)
//                }
//            }
//        } else {
//            guard let response = navigationResponse.response as? HTTPURLResponse else { return }
//            guard let headerFields = response.allHeaderFields as? [String : String] else { return }
//            guard let url = response.url else { return }
//            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
//            cookies.forEach { (cookie) in
//                HTTPCookieStorage.shared.setCookie(cookie)
//            }
//        }
    }
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        navigationDelegate?.webView?(webView, didStartProvisionalNavigation: navigation)
    }

    // 接收到服务器跳转请求即服务重定向时之后调用
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        navigationDelegate?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }

    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        navigationDelegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }

    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        navigationDelegate?.webView?(webView, didCommit: navigation)
    }

    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if #available(iOS 11.0, *) {
            self.navigationDelegate?.webView?(webView, didFinish: navigation)
        } else {
            if let url = webView.url {
                let cookies = HTTPCookieStorage.shared.cookies(for: url)
                var jscript = ""
                cookies?.forEach({ (cookie) in
                    jscript.append("document.cookie = '\(cookie.getCookieString())';")
                })
                webView.evaluateJavaScript(jscript) { (value, err) in
                    DispatchQueue.main.async {
                        self.navigationDelegate?.webView?(webView, didFinish: navigation)
                    }
                }
            } else {
                self.navigationDelegate?.webView?(webView, didFinish: navigation)
            }
        }
    }

    //提交发生错误时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        navigationDelegate?.webView?(webView, didFail: navigation, withError: error)
    }

    //需要响应身份验证时调用 在block中需要传入用户身份凭证
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if navigationDelegate?.webView?(webView, didReceive: challenge, completionHandler: completionHandler) == nil {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    //进程被终止时调用
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        if navigationDelegate?.webViewWebContentProcessDidTerminate?(webView) == nil {
            webView.reload()
        }
    }
}

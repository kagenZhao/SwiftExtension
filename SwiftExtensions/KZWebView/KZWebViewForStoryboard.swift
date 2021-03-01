//
//  KZWebViewForStoryboard.swift
//  wmIOS
//
//  Created by Kagen Zhao on 2020/1/3.
//  Copyright © 2020 kagen. All rights reserved.
//

import UIKit
import SnapKit
import WebKit

/**
 此类用于解决 iOS11以下storyboard不能使用WKWebView的情况,
 如果项目最低支持iOS11以上, 请直接使用KZWebView
 */
final class KZWebViewForStoryboard: UIView {
    public private(set) lazy var innerWebView: KZWebView = KZWebView.init(frame: self.bounds)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public var scrollView: UIScrollView {
        return innerWebView.scrollView;
    }
    
    public var delegate: KZWebViewDelegate? {
        set {
            innerWebView.delegate = newValue
        }
        get {
            return innerWebView.delegate
        }
    }
    
    public var navigationDelegate: WKNavigationDelegate? {
        set {
            innerWebView.navigationDelegate = newValue
        }
        get {
            return innerWebView.navigationDelegate
        }
    }
    
    public var uiDelegate: WKUIDelegate? {
        set {
            innerWebView.uiDelegate = newValue
        }
        get {
            return innerWebView.uiDelegate
        }
    }
    
    public var allowsBackForwardNavigationGestures: Bool {
        set {
            innerWebView.allowsBackForwardNavigationGestures = newValue
        }
        get {
            return innerWebView.allowsBackForwardNavigationGestures
        }
    }
    
    @available(iOS 9.0, *)
    public var customUserAgent: String? {
        set {
            innerWebView.customUserAgent = newValue
        }
        get {
            return innerWebView.customUserAgent
        }
    }
    
    @available(iOS 9.0, *)
    public var allowsLinkPreview: Bool {
        set {
            innerWebView.allowsLinkPreview = newValue
        }
        get {
            return innerWebView.allowsLinkPreview
        }
    }
    
    public var currentUrlString: String? {
        return innerWebView.url?.absoluteString
    }
    
    public var title: String? {
        return innerWebView.title
    }
    
    public var url: URL? {
        return innerWebView.url
    }
    
    public var isLoading: Bool {
        return innerWebView.isLoading
    }
    
    
    public var estimatedProgress: Double {
        return innerWebView.estimatedProgress
    }
    
    
    public var hasOnlySecureContent: Bool {
        return innerWebView.hasOnlySecureContent
    }
    
    public var backForwardList: WKBackForwardList {
        return innerWebView.backForwardList
    }
    
    public var configuration: WKWebViewConfiguration {
         return  innerWebView.configuration
    }
    
    @available(iOS 10.0, *)
    public var serverTrust: SecTrust? {
        return innerWebView.serverTrust
    }
    
    public var canGoBack: Bool {
        return innerWebView.canGoBack
    }
    
    public var canGoForward: Bool {
        innerWebView.canGoForward
    }
    
    @available(iOS, introduced: 9.0, deprecated: 10.0)
    public var certificateChain: [Any] {
        return innerWebView.certificateChain
    }
    
    /// default: .zero
    /// bottom is never used
    public var progressBarInset: UIEdgeInsets {
        set {
            innerWebView.progressBarInset = newValue
        }
        get {
            return innerWebView.progressBarInset
        }
    }
    
    /// default: 2
    @IBInspectable public var progressBarHeight: CGFloat {
        get {
            return innerWebView.progressBarHeight
        }
        set {
            innerWebView.progressBarHeight = newValue
        }
    }
    
    /// default: 0x67AA3C
    @IBInspectable public var progressBarTintColor: UIColor {
        get {
            return innerWebView.progressBarTintColor
        }
        set {
            innerWebView.progressBarTintColor = newValue
        }
    }
    
    /// default: clear
    @IBInspectable public var progressBarTrackTintColor: UIColor {
        get {
            return innerWebView.progressBarTrackTintColor
        }
        set {
            innerWebView.progressBarTrackTintColor = newValue
        }
    }
    
    /// default: true
    @IBInspectable public final var progressBarHidden: Bool {
        get {
            return innerWebView.progressBarHidden
        }
        set {
            innerWebView.progressBarHidden = newValue
        }
    }
    
    /// default: true
    @IBInspectable public final var scalesPageToFit: Bool {
        get {
            return innerWebView.scalesPageToFit
        }
        set {
            innerWebView.scalesPageToFit = newValue;
        }
    }
    
    /// default: false
    @IBInspectable public final var userScaleEnable: Bool {
        get {
            return innerWebView.userScaleEnable
        }
        set {
            innerWebView.userScaleEnable = newValue;
        }
    }
    
    /// default: false
    @IBInspectable public final var webkitTouchCallout: Bool {
        get {
            return innerWebView.webkitTouchCallout
        }
        set {
            innerWebView.webkitTouchCallout = newValue
        }
    }
    
    /// default: false
    @IBInspectable public final var webkitUserSelect: Bool {
        get {
            return innerWebView.webkitUserSelect
        }
        set {
            innerWebView.webkitUserSelect = newValue
        }
    }
    
    /// 加载文件: word excel pdf 等
    public func loadFileWithPath(_ path: String) {
        let url = URL(fileURLWithPath: path)
        innerWebView.load(URLRequest.init(url: url))
    }
    
    
    public func loadUrlString(_ urlString: String, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 60.0) {
        innerWebView.loadUrlString(urlString)
    }
    
    @available(iOS 9.0, *)
    @discardableResult
    public func load(_ data: Data, mimeType: String, characterEncodingName: String, baseURL: URL) -> WKNavigation? {
        return innerWebView.load(data, mimeType: mimeType, characterEncodingName: characterEncodingName, baseURL: baseURL)
    }
    
    @discardableResult
    public func reload() -> WKNavigation? {
        innerWebView.reload()
    }
    
    public func evaluateJavaScript(_ javaScriptString: String, completeionHandler: ((Any?, Error?) -> Void)? = nil) {
        innerWebView.evaluateJavaScript(javaScriptString, completionHandler: completeionHandler)
    }
    
    @discardableResult
    public func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        innerWebView.loadHTMLString(string, baseURL: baseURL)
    }

    @available(iOS 9.0, *)
    public func loadFileURL(_ URL: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
        return innerWebView.loadFileURL(URL, allowingReadAccessTo: readAccessURL)
    }
    
    @discardableResult
    public func go(to item: WKBackForwardListItem) -> WKNavigation? {
        return innerWebView.go(to: item)
    }
    
    @discardableResult
    public func goBack() -> WKNavigation? { return innerWebView.goBack() }
    
    @discardableResult
    public func goForward() -> WKNavigation? {
        return innerWebView.goForward()
    }
    
    public func reloadFromOrigin() -> WKNavigation? {
        return innerWebView.reloadFromOrigin()
    }
    
    public func stopLoading() {
        return innerWebView.stopLoading()
    }
}

extension KZWebViewForStoryboard {
    private func setupView() {
        backgroundColor = .white
        innerWebView.backgroundColor = .clear
        addSubview(innerWebView)
        innerWebView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0);
        }
    }
}

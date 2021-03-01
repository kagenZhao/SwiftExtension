//
//  KZWebView.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/10/22.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import RxCocoa
import SwifterSwift

public typealias KZWebViewDelegate = (WKNavigationDelegate & WKUIDelegate)

open class KZWebView: WKWebView {
    public weak var delegate: KZWebViewDelegate? {
        didSet {
            _delegate.navigationDelegate = delegate
            _delegate.uiDelegate = delegate
            super.navigationDelegate = _delegate
            super.uiDelegate = _delegate
        }
    }
    
    override open var navigationDelegate: WKNavigationDelegate? {
        set {
            _delegate.navigationDelegate = newValue
            super.navigationDelegate = _delegate
        }
        get {
            return _delegate.navigationDelegate
        }
    }
    
    open override var uiDelegate: WKUIDelegate? {
        set {
            _delegate.uiDelegate = newValue
            super.uiDelegate = _delegate
        }
        get {
            return _delegate.uiDelegate
        }
    }
    
    private var _scalesPageToFit: Bool = true
    private var _userScaleEnable: Bool = false
    private var _webkitTouchCallout: Bool = false
    private var _webkitUserSelect: Bool = false
    private var _progressBarHidden: Bool = true
    private var _progressBarInset: UIEdgeInsets = .zero
    private var _progressBarHeight: CGFloat = 2
    private var _progressBarTintColor: UIColor = UIColor.init(hex: 0x67AA3C)!
    private var _progressBarTrackTintColor: UIColor = .clear
    
    private lazy var _delegate: _KZWebViewDelegate = _KZWebViewDelegate()
    
    private lazy var progressBar: UIProgressView = {
        let progressView = UIProgressView.init(progressViewStyle: UIProgressView.Style.bar)
        progressView.progressTintColor = _progressBarTintColor
        progressView.trackTintColor = _progressBarTrackTintColor
        progressView.setProgress(0, animated: false)
        return progressView
    }()
    
    
    public convenience init(frame: CGRect) {
        self.init(frame: frame, configuration: Self.defaultConfig)
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        allowsBackForwardNavigationGestures = false
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        configuration.processPool = KZWebKitSupport.shared.processPool
        configuration.websiteDataStore = KZWebKitSupport.shared.websiteDataStore
        super.init(frame: frame, configuration: configuration)
        setupUI()
        setupNotify()
        setupAttribute()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupNotify()
        setupAttribute()
    }
    
    private func setupUI() {
        addSubview(progressBar)
        layoutProgressBar()
    }
    
    private func layoutProgressBar() {
        progressBar.snp.remakeConstraints { (make) in
            make.left.equalTo(_progressBarInset.left)
            make.right.equalTo(-_progressBarInset.right)
            make.top.equalTo(_progressBarInset.top)
            make.height.equalTo(_progressBarHeight)
        }
    }
    
    private func setupNotify() {
        _ = rx.observeWeakly(Double.self, "estimatedProgress").subscribe(onNext: {[weak self] (value) in
            if let newValue = value {
                self?.setProgress(newValue)
            }
        })
    }
    
    private func setupAttribute() {
        _resetUserScript()
        progressBarHidden = _progressBarHidden
    }
    
    private func setProgress(_ value: Double) {
        if value.isLessThanOrEqualTo(0.0) {
            progressBar.setProgress(0.0, animated: false)
        } else if 1.0.isLessThanOrEqualTo(value) {
            CATransaction.begin()
            CATransaction.setCompletionBlock {[weak self] in
                UIView.animate(withDuration: 0.3, animations: {
                    self?.progressBar.alpha = 0
                }) { (finish) in
                    self?.progressBar.setProgress(0.0, animated: false)
                    self?.progressBar.alpha = 1
                }
            }
            progressBar.setProgress(1.0, animated: true)
            CATransaction.commit()
        } else {
            progressBar.setProgress(Float(value), animated: true)
        }
    }
}

// MARK: Public Functions
extension KZWebView {
    public static var defaultConfig: WKWebViewConfiguration  {
        let config = WKWebViewConfiguration()
        let preferences = WKPreferences()
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preferences.minimumFontSize = 0;
        //设置是否支持javaScript 默认是支持的
        preferences.javaScriptEnabled = true
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preferences.javaScriptCanOpenWindowsAutomatically = false
        
        let webViewConfigPreference: WKPreferences = preferences
        
        let userContentController = WKUserContentController()
        
        let defaultScript = KZWebView._getScaleScript(true, userScaleEnable: false, webkitTouchCallout: false, webkitUserSelect: false)
        userContentController.addUserScript(WKUserScript(source: defaultScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        
        config.userContentController = userContentController
        
        config.preferences = webViewConfigPreference
        // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            // 是否允许用户缩放, false 表示允许, true 表示不允许
            config.ignoresViewportScaleLimits = false
            
            // 设置检测电话连接可点击
            config.dataDetectorTypes = [.phoneNumber]
        }
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
//        config.requiresUserActionForMediaPlayback = true
        //设置是否允许画中画技术 在特定设备上有效
        config.allowsPictureInPictureMediaPlayback = true
        return config
    }
    
    
    /// default: .zero
    /// bottom is never used
    public final var progressBarInset: UIEdgeInsets {
        get {
            return _progressBarInset
        }
        set {
            _progressBarInset = newValue
            layoutProgressBar()
        }
    }
    
    /// default: 2
    @IBInspectable public final var progressBarHeight: CGFloat {
        get {
            return _progressBarHeight
        }
        set {
            _progressBarHeight = newValue
            layoutProgressBar()
        }
    }
    
    /// default: 0x67AA3C
    @IBInspectable public final var progressBarTintColor: UIColor {
        get {
            return _progressBarTintColor
        }
        set {
            _progressBarTintColor = newValue
            progressBar.progressTintColor = _progressBarTintColor
        }
    }
    
    /// default: clear
    @IBInspectable public final var progressBarTrackTintColor: UIColor {
        get {
            return _progressBarTrackTintColor
        }
        set {
            _progressBarTrackTintColor = newValue
            progressBar.trackTintColor = _progressBarTrackTintColor
        }
    }
    
    /// default: true
    @IBInspectable public final var progressBarHidden: Bool {
        get {
            return _progressBarHidden
        }
        set {
            _progressBarHidden = newValue
            progressBar.isHidden = newValue
        }
    }
    
    /// default: true
    /// 加载某些文件时(比如docx, 其他种类待测试), true 会导致 缩放不正常, 请手动设置为false
    @IBInspectable public final var scalesPageToFit: Bool {
        get {
            return _scalesPageToFit
        }
        set {
            _scalesPageToFit = newValue;
            _resetUserScript()
        }
    }
    
    /// default: false
    @IBInspectable public final var userScaleEnable: Bool {
        get {
            return _userScaleEnable
        }
        set {
            _userScaleEnable = newValue;
            _resetUserScript()
        }
    }
    
    /// default: false
    @IBInspectable public final var webkitTouchCallout: Bool {
        get {
            return _webkitTouchCallout
        }
        set {
            _webkitTouchCallout = newValue
            _resetUserScript()
        }
    }
    
    /// default: false
    @IBInspectable public final var webkitUserSelect: Bool {
        get {
            return _webkitUserSelect
        }
        set {
            _webkitUserSelect = newValue
            _resetUserScript()
        }
    }
    
    /// 加载文件: word excel pdf 等
    public func loadFileWithPath(_ path: String) {
        let url = URL(fileURLWithPath: path)
        _load(URLRequest.init(url: url))
    }
    
    /// 为了确保cookie同步准确 请尽量不要使用 load(_ request: URLRequest)
    /// 使用此方法
    public func loadUrlString(_ urlString: String, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 60.0) {
        guard let url = URL.init(string: urlString) else { return }
        let request = URLRequest.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        if #available(iOS 11.0, *) {
            KZWebKitSupport.shared.syncCookie {[weak self] in
                self?._load(request)
            }
        } else {
            var request = request
            if let url = request.url, let cookies = HTTPCookieStorage.shared.cookies(for: url) {
                var cookieString = ""
                var jscript = ""
                cookies.forEach({ (cookie) in
                    cookieString.append("\(cookie.name)=\(cookie.value);")
                    jscript.append("document.cookie = '\(cookie.getCookieString())';")
                })
                request.setValue(cookieString, forHTTPHeaderField: "Cookie")
                _replaceUserSript("document.cookie =", script: WKUserScript(source: jscript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
            }
            _load(request)
        }
    }

    @discardableResult
    public override func load(_ request: URLRequest) -> WKNavigation? {
        print("请调用loadUrlString方法, 手动调用load方法cookie还没同步")
//        assert(false, "请调用上边的方法, 手动调用这个方法cookie还没同步")
        return super.load(request)
    }
    
    private func _load(_ request: URLRequest) {
        super.load(request)
    }
}

extension KZWebView {
    
    private func _resetUserScript() {
        let script = _getScalesScript()
        _replaceUserSript("__KZWebViewController__", script: WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        evaluateJavaScript(script)
    }
    
    private func _replaceUserSript(_ searchKey: String, script: WKUserScript) {
        let userScripts = [WKUserScript].init(configuration.userContentController.userScripts)
        configuration.userContentController.removeAllUserScripts()
        for script in userScripts {
            if !script.source.contains(searchKey) {
                configuration.userContentController.addUserScript(script)
            }
        }
        configuration.userContentController.addUserScript(script)
    }
  
    private func _getScalesScript() -> String {
        return KZWebView._getScaleScript(_scalesPageToFit, userScaleEnable: _userScaleEnable, webkitTouchCallout: _webkitTouchCallout, webkitUserSelect: _webkitUserSelect)
    }
    
    fileprivate static func _getScaleScript(_ scalesPageToFit: Bool, userScaleEnable: Bool, webkitTouchCallout: Bool, webkitUserSelect: Bool) -> String {
        var jscript = """
        var meta = document.getElementById('__KZWebViewController__');
        if (meta == null) {
            meta = document.createElement('meta');
            meta.id = '__KZWebViewController__';
            meta.setAttribute('name', 'viewport');
            document.getElementsByTagName('head')[0].appendChild(meta);
        }
        """
        switch (scalesPageToFit, userScaleEnable) {
        case (true, true):
            jscript.append("meta.setAttribute('content', 'width=device-width,height=device-height,initial-scale=1.0,minimum-scale=1.0,maximum-scale=5.0,user-scalable=YES');")
        case (true, false):
            jscript.append("meta.setAttribute('content', 'width=device-width,height=device-height,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=NO');")
        case (false, true):
            jscript.append("meta.setAttribute('content', 'user-scalable=YES');")
        case (false, false):
            jscript.append("meta.remove();")
        }
        
        if webkitTouchCallout {
            jscript.append("document.documentElement.style.webkitTouchCallout='default';")
        } else {
            jscript.append("document.documentElement.style.webkitTouchCallout='none';")
        }
        
        if webkitUserSelect {
            jscript.append("document.documentElement.style.webkitUserSelect='text';")
        } else {
            jscript.append("document.documentElement.style.webkitUserSelect='none';")
        }
        return jscript
    }
}

extension WKWebView {
    public final var currentUrlString: String? {
        return url?.absoluteString
    }
}

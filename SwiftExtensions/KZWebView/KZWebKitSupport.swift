//
//  KZWebKitSupport.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/10/15.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

public final class KZWebKitSupport: NSObject, WKHTTPCookieStoreObserver {
    public static let shared: KZWebKitSupport = KZWebKitSupport()
    public let processPool = WKProcessPool()
    public let websiteDataStore = WKWebsiteDataStore.default()
    
    public func syncCookie(_ complete: @escaping (() -> ())) {
        if #available(iOS 11.0, *) {
            guard let cookies = HTTPCookieStorage.shared.cookies else {
                return
            }
            let cookieStore = self.websiteDataStore.httpCookieStore
            
            let group = DispatchGroup()
            cookies.forEach { (cookie) in
                group.enter()
                cookieStore.setCookie(cookie) {
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                complete()
            }
        }
    }
}

internal extension HTTPCookie {
    func getCookieString() -> String {
        var string = "\(name)=\(value);domain=\(domain);"
        if let expiresDate = expiresDate {
            string = string + "expiresDate=\(expiresDate);"
        }
        string = string + "path=\(path);sessionOnly=\(isSessionOnly ? "TRUE" : "FALSE");isSecure=\(isSecure ? "TRUE":"FALSE")"
        return string
    }
}

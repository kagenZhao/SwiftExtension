//
//  ApplicationServices.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/18.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation
import UIKit

private let _share = ApplicationServices()

public protocol ServicesLoaderProtocol {
    
    static func singleInstence() -> Any
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?)
    
    func applicationDidEnterBackground(_ application: UIApplication)
    
    func applicationWillEnterForeground(_ application: UIApplication)
    
    func applicationDidBecomeActive(_ application: UIApplication)
    
    func applicationWillResignActive(_ application: UIApplication)
    
    func applicationWillTerminate(_ application: UIApplication)
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication)
}

extension ServicesLoaderProtocol {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {}
    
    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationWillTerminate(_ application: UIApplication) {}
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {}
}


open class ApplicationServices {
    
    open class var share: ApplicationServices { return _share }
    
    open class func registe<T: ServicesLoaderProtocol>(_ services: T.Type) {
        ApplicationServices.share.services.append(services)
    }
    
    private var services: [ServicesLoaderProtocol.Type] = []
    
    fileprivate init() {
        NotificationCenter.default.addObserver(self, selector: #selector(application(didFinishLaunching:)), name: .UIApplicationDidFinishLaunching, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(application(didEnterBackground:)), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(application(willEnterForeground:)), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(application(didBecomeActive:)), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(application(willResignActive:)), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(application(willTerminate:)), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(application(didReceiveMemoryWarning:)), name: .UIApplicationWillTerminate, object: nil)
    }
    
    @objc private func application(didFinishLaunching notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence() as? ServicesLoaderProtocol
            debugPrint("Service Loaded - \(NSStringFromClass(loaderClass as! AnyClass))")
            loader?.application(notification.object as! UIApplication, didFinishLaunchingWithOptions: notification.userInfo as? [UIApplicationLaunchOptionsKey : Any])
        }
    }
    
    @objc private func application(didEnterBackground notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence() as? ServicesLoaderProtocol
            loader?.applicationDidEnterBackground(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(willEnterForeground notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence() as? ServicesLoaderProtocol
            loader?.applicationWillEnterForeground(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(didBecomeActive notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence() as? ServicesLoaderProtocol
            loader?.applicationDidBecomeActive(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(willResignActive notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence() as? ServicesLoaderProtocol
            loader?.applicationWillResignActive(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(willTerminate notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence() as? ServicesLoaderProtocol
            loader?.applicationWillTerminate(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(didReceiveMemoryWarning notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence() as? ServicesLoaderProtocol
            loader?.applicationDidReceiveMemoryWarning(notification.object as! UIApplication)
        }
    }
}

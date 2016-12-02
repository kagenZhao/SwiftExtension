//
//  ApplicationServices.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/18.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation
import UIKit


precedencegroup RegistNotificationPrecendence {
    associativity: left
}
infix operator -->: RegistNotificationPrecendence

private func -->(observer: Any, name: NSNotification.Name) -> (observer: Any, name: NSNotification.Name) {
    return (observer, name)
}

func -->(atts: (observer: Any, name: NSNotification.Name), selector: Selector) {
    NotificationCenter.default.addObserver(atts.observer, selector: selector, name: atts.name, object: nil)
}

private let _share = ApplicationServices()

/// 默认在 <UIApplicationDelegate> 中有一些方法并没有通知
/// 所以手动添加一些通知类型
@available(iOS 8.0, *)
extension Notification.Name {
    
    @available(iOS, deprecated: 10.0)
    fileprivate static let UIApplicationDidReceiveRemote: NSNotification.Name = .init("Services_UIApplicationDidReceiveRemote")
    
    @available(iOS, deprecated: 10.0)
    fileprivate static let UIApplicationDidReceiveLocal: NSNotification.Name = .init("Services_UIApplicationDidReceiveLocal")
    
    fileprivate static let UIApplicationDidRegisterForRemoteWithDeviceToken: NSNotification.Name = .init("Services_UIApplicationDidRegisterForRemoteWithDeviceToken")
    
    @available(iOS 9.0, *)
    fileprivate static let UIApplicationOpenUrlWithOptions: Notification.Name = .init("Services_UIApplicationOpenUrlWithOptions")
    
    @available(iOS, deprecated: 9.0)
    fileprivate static let UIApplicationOpenUrlWithSourceApplicationAndAnnotation: Notification.Name = .init("Services_UIApplicationOpenUrlWithSourceApplicationAndAnnotation")
    
    @available(iOS, deprecated: 9.0)
    fileprivate static let UIApplicationHandleOpenUrl: Notification.Name = .init("Services_UIApplicationHandleOpenUrl")
}

private let key1 = "_key1"
private let key2 = "_key2"
private let key3 = "_key3"
private let `nil` = "Nil"

/// 给几个没有通知的方法 添加默认实现 使其能够发送通知
/// 使用者如果是用了<ServicesLoaderProtocol>对应着三个方法的代理方法 那么请不要在AppDelegate中重写这几个方法 否则无法调用
/// 如果在必须要重写下面方法的情况下, 请务必调用方法对应的静态方法, 以确保能够发送对应的通知
///
/// example:
///     如果你在AppDelegate中重写了 application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
///
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///
///     ......
///     使用者重写了下边方法
///     func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
///         请务必调用下边方法
///         type(of: self).application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
///         ......
///         ......
///     }
/// }
@available(iOS 8.0, *)
public extension UIApplicationDelegate {
    
    public static func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: .UIApplicationDidRegisterForRemoteWithDeviceToken, object: application, userInfo: [key1: deviceToken])
    }
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        type(of: self).application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    @available(iOS, deprecated: 10.0)
    public static func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NotificationCenter.default.post(name: .UIApplicationDidReceiveRemote, object: application, userInfo: userInfo)
    }
    @available(iOS, deprecated: 10.0)
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        type(of: self).application(application, didReceiveRemoteNotification: userInfo)
    }
    
    @available(iOS, deprecated: 10.0)
    public static func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NotificationCenter.default.post(name: .UIApplicationDidReceiveLocal, object: application, userInfo: [key1: notification])
    }
    @available(iOS, deprecated: 10.0)
    public func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        type(of: self).application(application, didReceive: notification)
    }
    
    @available(iOS, deprecated: 9.0)
    public static func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        NotificationCenter.default.post(name: .UIApplicationHandleOpenUrl, object: application, userInfo: [key1: url])
        return true
    }
    @available(iOS, deprecated: 9.0)
    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return type(of: self).application(application, handleOpen: url)
    }
    
    @available(iOS, deprecated: 9.0)
    public static func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        NotificationCenter.default.post(name: .UIApplicationOpenUrlWithSourceApplicationAndAnnotation, object: application, userInfo: [key1: url, key2: sourceApplication ?? "Nil", key3: annotation])
        return true
    }
    @available(iOS, deprecated: 9.0)
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return type(of: self).application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    public static func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        NotificationCenter.default.post(name: .UIApplicationOpenUrlWithOptions, object: app, userInfo: [key1:url, key2:options])
        return true
    }
    @available(iOS 9.0, *)
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return type(of: self).application(app, open: url, options: options)
    }
}

/// 用户需要在<UIApplicationDelegate>的方法中调用的类可以继承 <ServicesLoaderProtocol>
/// 并按需求实现这些代理方法
@available(iOS 8.0, *)
@objc public protocol ServicesLoaderProtocol: NSObjectProtocol {
    
    static func singleInstence() -> ServicesLoaderProtocol
    
    @objc optional func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?)
    
    @objc optional func applicationDidEnterBackground(_ application: UIApplication)
    
    @objc optional func applicationWillEnterForeground(_ application: UIApplication)
    
    @objc optional func applicationDidBecomeActive(_ application: UIApplication)
    
    @objc optional func applicationWillResignActive(_ application: UIApplication)
    
    /// 只有应用程序正在运行时调用(即, 用户在app中双击home杀死当前进程才会调用)。如果应用程序在后台(双击home杀死app)此方法不调用
    @objc optional func applicationWillTerminate(_ application: UIApplication)
    
    @objc optional func applicationDidReceiveMemoryWarning(_ application: UIApplication)
    
    @objc optional func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    
    @available(iOS, deprecated: 10.0)
    @objc optional func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    
    @available(iOS, deprecated: 10.0)
    @objc optional func application(_ application: UIApplication, didReceive notification: UILocalNotification)
    
    @available(iOS, deprecated: 9.0)
    @objc optional func application(_ application: UIApplication, handleOpen url: URL)
    
    @available(iOS, deprecated: 9.0)
    @objc optional func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any)
    
    @available(iOS 9.0, *)
    @objc optional func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
}

/// 这个类是对应<ServicesLoaderProtocol>的管理类
/// 使用者可以在AppDelegate 中的FinishLaunch中调用对应方法来注册需要通知的类
/// example:
///
/// let service = Service()
///
/// class Service: NSObject {}
///
/// extension Service: ServicesLoaderProtocol {
///     static func singleInstence() -> ServicesLoaderProtocol {
///         return service
///     }
///
///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
///     ......
///     }
///
/// }
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///
///     ......
///
///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
///
///         ApplicationServices.registe(Service.self)
///
///         ......
///         return true
///     }
/// }
@available(iOS 8.0, *)
open class ApplicationServices {
    
    open class var share: ApplicationServices { return _share }
    
    open class func registe<T: ServicesLoaderProtocol>(_ services: T.Type) {
        ApplicationServices.share.services.append(services)
    }
    
    private var services: [ServicesLoaderProtocol.Type] = []
    
    fileprivate init() {
        
        self --> .UIApplicationDidFinishLaunching                        --> #selector(application(didFinishLaunching:))
        self --> .UIApplicationDidEnterBackground                        --> #selector(application(didEnterBackground:))
        self --> .UIApplicationWillEnterForeground                       --> #selector(application(willEnterForeground:))
        self --> .UIApplicationDidBecomeActive                           --> #selector(application(didBecomeActive:))
        self --> .UIApplicationWillResignActive                          --> #selector(application(willResignActive:))
        self --> .UIApplicationDidReceiveMemoryWarning                   --> #selector(application(didReceiveMemoryWarning:))
        self --> .UIApplicationWillTerminate                             --> #selector(application(willTerminate:))
        self --> .UIApplicationDidRegisterForRemoteWithDeviceToken       --> #selector(application(didRegisterForRemoteWithDeviceToken:))
        self --> .UIApplicationDidReceiveRemote                          --> #selector(application(didReceiveRemote:))
        self --> .UIApplicationDidReceiveLocal                           --> #selector(application(didReceiveLocal:))
        self --> .UIApplicationHandleOpenUrl                             --> #selector(application(handleOpenUrl:))
        self --> .UIApplicationOpenUrlWithSourceApplicationAndAnnotation --> #selector(application(openUrlWithSourceAppAndAnnotation:))

        if #available(iOS 9.0, *) {
            self --> .UIApplicationOpenUrlWithOptions --> #selector(application(openUrlWithOptions:))
        }
        
    }
    
    @objc private func application(didFinishLaunching notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            print("Service Loaded Class: <\(NSStringFromClass(loaderClass))>")
            loader.application?(notification.object as! UIApplication, didFinishLaunchingWithOptions: notification.userInfo as? [UIApplicationLaunchOptionsKey : Any])
        }
    }
    
    @objc private func application(didEnterBackground notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.applicationDidEnterBackground?(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(willEnterForeground notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.applicationWillEnterForeground?(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(didBecomeActive notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.applicationDidBecomeActive?(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(willResignActive notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.applicationWillResignActive?(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(willTerminate notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.applicationWillTerminate?(notification.object as! UIApplication)
        }
    }
    
    @objc private func application(didReceiveMemoryWarning notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.applicationDidReceiveMemoryWarning?(notification.object as! UIApplication)
        }
    }
    
    @available(iOS, deprecated: 10.0)
    @objc private func application(didReceiveRemote notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.application?(notification.object as! UIApplication, didReceiveRemoteNotification: notification.userInfo!)
        }
    }
    
    @available(iOS, deprecated: 10.0)
    @objc private func application(didReceiveLocal notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.application?(notification.object as! UIApplication, didReceive: notification.userInfo![key1] as! UILocalNotification)
        }
    }
    
    @objc private func application(didRegisterForRemoteWithDeviceToken notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.application?(notification.object as! UIApplication, didRegisterForRemoteNotificationsWithDeviceToken: notification.userInfo![key1] as! Data)
        }
    }
    
    @available(iOS, deprecated: 9.0)
    @objc private func application(handleOpenUrl notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.application?(notification.object as! UIApplication, handleOpen: notification.userInfo![key1] as! URL)
        }
    }
    
    @available(iOS, deprecated: 9.0)
    @objc private func application(openUrlWithSourceAppAndAnnotation notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            let url = notification.userInfo![key1] as! URL
            let source = notification.userInfo![key2] as! String
            let annotation = notification.userInfo![key3] as Any
            loader.application?(notification.object as! UIApplication, open: url, sourceApplication: source == `nil` ? nil : source, annotation: annotation)
        }
    }
    
    @available(iOS 9.0, *)
    @objc private func application(openUrlWithOptions notification: Notification) {
        services.forEach { loaderClass in
            let loader = loaderClass.singleInstence()
            loader.application?(notification.object as! UIApplication, open: notification.userInfo![key1] as! URL, options: notification.userInfo![key2] as! [UIApplicationOpenURLOptionsKey : Any])
        }
    }
    
}

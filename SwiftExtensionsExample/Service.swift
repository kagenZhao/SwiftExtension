//
//  Service.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/12/2.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import SwiftExtensions

let service = Service()

class Service: NSObject {
    
}

extension Service: ServicesLoaderProtocol {
    
    static func singleInstence() -> ServicesLoaderProtocol {
        return service
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
        print("success lanch function: <\(#function)>")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("success lanch function: <\(#function)>")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("success lanch function: <\(#function)>")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("success lanch function: <\(#function)>")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("success lanch function: <\(#function)>")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("success lanch function: <\(#function)>")
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("success lanch function: <\(#function)>")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("success lanch function: <\(#function)>")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("success lanch function: <\(#function)>")
    }
    
    @available(iOS, deprecated: 10.0)
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("success lanch function: <\(#function)>")
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) {
        print("success lanch function: <\(#function)>")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) {
        print("success lanch function: <\(#function)>")
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) {
        print("success lanch function: <\(#function)>")
    }
    
    
    
}

//
//  AppDelegate.swift
//  SwiftExtensions
//
//  Created by zhaoguoqing on 16/6/29.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var timer: DispatchSourceTimer!
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
//        AppInfo.Memory.log()
//        print("totle: \(AppInfo.Disk.appUsage(NSHomeDirectory(), .decimal(.gb))))")
        print("available: \(AppInfo.Disk.deviceAvailable())")
        return true
    }
}


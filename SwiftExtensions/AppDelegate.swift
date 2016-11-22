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
        timer = DispatchQueue.global().timer(interval: .seconds(1), handler: {
           _ = AppMemoryInfo.usage
        })
        timer.start()
        return true
    }
}


//
//  AppDelegate.swift
//  SwiftExtensionsExample
//
//  Created by Kagen Zhao on 2016/12/2.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import SwiftExtensions



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        ApplicationServices.registe(Service.self)
        Router.shared.setup(rootController: .name("ViewController"))
        return true
    }
}


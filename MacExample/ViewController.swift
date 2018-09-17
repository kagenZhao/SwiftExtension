//
//  ViewController.swift
//  MacExample
//
//  Created by 赵国庆 on 2018/8/31.
//  Copyright © 2018年 kagenZhao. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        print(identifier)
        print(ProcessInfo().environment)
        ["SQLITE_ENABLE_THREAD_ASSERTIONS": "1",
         "__XPC_DYLD_FRAMEWORK_PATH": "/Users/zhaoguoqing/Library/Developer/Xcode/DerivedData/SwiftExtensions-cirqivtuxuscikbkjmkgjnqxjyld/Build/Products/Debug",
         "Apple_PubSub_Socket_Render": "/private/tmp/com.apple.launchd.dWoXtxIANW/Render",
         "SHELL": "/bin/zsh",
         "MallocNanoZone": "1",
         "XPC_SERVICE_NAME": "com.apple.dt.Xcode.19044",
         "CA_DEBUG_TRANSACTIONS": "0",
         "APP_SANDBOX_CONTAINER_ID": "com.kagen.MacExample",
         "USER": "zhaoguoqing",
         "__XPC_DYLD_LIBRARY_PATH": "/Users/zhaoguoqing/Library/Developer/Xcode/DerivedData/SwiftExtensions-cirqivtuxuscikbkjmkgjnqxjyld/Build/Products/Debug",
         "NSUnbufferedIO": "YES",
         "OS_ACTIVITY_DT_MODE": "YES",
         "__XCODE_BUILT_PRODUCTS_DIR_PATHS": "/Users/zhaoguoqing/Library/Developer/Xcode/DerivedData/SwiftExtensions-cirqivtuxuscikbkjmkgjnqxjyld/Build/Products/Debug",
         "__CF_USER_TEXT_ENCODING": "0x1F5:0x19:0x34",
         "SSH_AUTH_SOCK": "/private/tmp/com.apple.launchd.Lv0lSBNmuD/Listeners",
         "TMPDIR": "/var/folders/sz/dc6y5wb14zx9q9n9sgr5nx_h0000gn/T/com.kagen.MacExample/",
         "DYLD_LIBRARY_PATH": "/Users/zhaoguoqing/Library/Developer/Xcode/DerivedData/SwiftExtensions-cirqivtuxuscikbkjmkgjnqxjyld/Build/Products/Debug:/usr/lib/system/introspection",
         "DYLD_FRAMEWORK_PATH": "/Users/zhaoguoqing/Library/Developer/Xcode/DerivedData/SwiftExtensions-cirqivtuxuscikbkjmkgjnqxjyld/Build/Products/Debug",
         "XPC_FLAGS": "0x0",
         "CA_ASSERT_MAIN_THREAD_TRANSACTIONS": "0",
         "HOME": "/Users/zhaoguoqing/Library/Containers/com.kagen.MacExample/Data",
         "LOGNAME": "zhaoguoqing",
         "PATH": "/Applications/Xcode-beta.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin",
         "CFFIXED_USER_HOME": "/Users/zhaoguoqing/Library/Containers/com.kagen.MacExample/Data",
         "PWD": "/Users/zhaoguoqing/Library/Developer/Xcode/DerivedData/SwiftExtensions-cirqivtuxuscikbkjmkgjnqxjyld/Build/Products/Debug"]
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


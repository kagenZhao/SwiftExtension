//
//  SecurityManager+ErrorProcesser.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/7/31.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit

public class SecurityManagerErrorProcesser {
    public static func processError(_ err: SecurityManager.AuthenticateError, complete: ((Bool) -> ())? = nil) {
        switch err {
        case .appCancel:
            complete?(true)
            break
        case .systemCancel:
            complete?(true)
            break
        case .userCancel:
            complete?(true)
            break
        case .authenticationFailed:
            complete?(true)
//            alert(message: "验证失败")
            break
        case .passcodeNotSet:
            complete?(true)
//            alert(message: "您的设备未设置密码")
            break
        case .biometryNotAvailable:
            complete?(true)
            if SecurityManager.shared.biometryType == .faceID {
//                alert(message: "请在设置中允许使用面容 ID")
            } else {
//                alert(message: "您的设备不支持指纹识别")
            }
            break
        case .biometryNotEnrolled:
            complete?(true)
//            alert(message: "您的设备未录入\(SecurityManager.shared.biometryType == .faceID ? "面容 ID" : "指纹")")
            break
        case .biometryLockout:
            complete?(true)
//            alert(message: "您的设备已被锁定")
            return
        case .userFallback:
            SecurityManager.shared.hiddenWindow()
            forceRelogin(.biometry) { s in
                complete?(s)
            }
            break
        case .invalidContext:
            complete?(true)
            break
        case .notInteractive:
            complete?(true)
            break
        case .forgetGesturePwd:
            SecurityManager.shared.hiddenWindow()
            forceRelogin(.gesture) { s in
                complete?(s)
            }
            break
        case .unknown:
            complete?(true)
            break
        }
    }
    
    private static func alert(message: String) {
//        alertInfo(title: "提示", message: message)
    }
    
    
    private static func forceRelogin(_ type: SecurityManager.LockType, complete: ((Bool) -> ())? = nil) {
        // 重新登录
    }
    
    private static func logout() {
        // 退出登录
    }
    
}

extension UIViewController {
    fileprivate func findTopViewController() -> UIViewController {
        if self is UINavigationController {
            return (self as! UINavigationController).topViewController?.findTopViewController() ?? self
        } else if self is UITabBarController {
            return (self as! UITabBarController).selectedViewController?.findTopViewController() ?? self
        } else {
            return self
        }
    }
}

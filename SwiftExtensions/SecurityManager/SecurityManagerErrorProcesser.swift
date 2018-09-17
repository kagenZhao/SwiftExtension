//
//  SecurityManagerErrorProcesser.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/7/31.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit

public class SecurityManagerErrorProcesser {
    public static func processError(_ err: SecurityManager.AuthenticateError, complete: ((Bool) -> ())? = nil) {
        print(err)
        switch err {
        case .appCancel:
            break
        case .systemCancel:
            break
        case .userCancel:
            break
        case .authenticationFailed:
            // 弹框提示
            alert(message: "验证失败")
            break
        case .passcodeNotSet:
            // 弹框提示
            alert(message: "设备未设置密码")
            break
        case .biometryNotAvailable:
            // 弹框提示
            alert(message: "设备不支持")
            break
        case .biometryNotEnrolled:
            alert(message: "设备未录入指纹")
            // 弹框提示
            break
        case .biometryLockout:
             alert(message: "设备已锁定")
            // 弹框提示
            return
        case .userFallback:
            // 其他方式登录验证????
            let vc = PasswordController()
            vc.successAction = {
                SecurityManager.shared.setupBiometryLock(setting: false)
                SecurityManager.shared.resetGestureAttemptNumber()
                SecurityManager.shared.window.rootViewController = nil
                SecurityManager.shared.window.isHidden = true
                complete?(true)
            }
            vc.errorAction = { err in
                complete?(false)
            }
            SecurityManager.shared.window.rootViewController = vc
            break
        case .invalidContext:
            break
        case .notInteractive:
            break
        case .forgetGesturePwd:
            // 忘记密码 也是其他方式登录???
            let vc = PasswordController()
            vc.successAction = {
                SecurityManager.shared.setupGestureLock(pwd: nil)
                SecurityManager.shared.resetGestureAttemptNumber()
                SecurityManager.shared.window.rootViewController = nil
                SecurityManager.shared.window.isHidden = true
                complete?(true)
            }
            vc.errorAction = { err in
                complete?(false)
            }
            SecurityManager.shared.window.rootViewController = vc
            break
        case .changeBiometry:
            // 其他方式登录验证????
            break
        }
    }
    
    private static func alert(message: String) {
        let a = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(a, animated: true, completion: nil)
    }
}

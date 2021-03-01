//
//  SecurityManager.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/7/27.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit
import LocalAuthentication

public final class SecurityManager {
    public static let shared = SecurityManager()
    /// 没啥用
    public var fallbackTitle: String = "验证密码"
    /// 手势最大尝试次数
    public var maxGestureAttemptNumber = 5
    lazy private var _currentGestureAttemptNumber: Int = {
        var saved = UserDefaults.standard.integer(forKey: "com.kagenz.SecurityManager.currentGestureAttemptNumber.\(userIdentifier)")
        if saved > maxGestureAttemptNumber {
            saved = maxGestureAttemptNumber
            UserDefaults.standard.set(saved, forKey: "com.kagenz.SecurityManager.currentGestureAttemptNumber.\(userIdentifier)")
            UserDefaults.standard.synchronize()
        }
        return saved
    }()
    
    /// 当前手势已经尝试次数
    public private(set) var currentGestureAttemptNumber: Int {
        set {
            _currentGestureAttemptNumber = min(maxGestureAttemptNumber, max(newValue, 0))
            UserDefaults.standard.set(_currentGestureAttemptNumber, forKey: "com.kagenz.SecurityManager.currentGestureAttemptNumber.\(userIdentifier)")
            UserDefaults.standard.synchronize()
        }
        get {
            return _currentGestureAttemptNumber
        }
    }
    /// 是否设置了手势密码
    public private(set) var gestureLock: Bool = false
    /// 是否设置了指纹/faceid
    public private(set) var biometryLock: Bool = false
    /// 设备支持类型 -- 指纹/faceid/无
    public let biometryType: BiometryType = {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            let type: LABiometryType = authContext.biometryType
            switch(type) {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                return .none
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }()
    
    /// 用于根据不同用户设置不同状态
    public private(set) var userIdentifier: String = ""
    
    private var biometry = Biometry()

    
    /// 重置手势尝试次数
    public func resetGestureAttemptNumber() {
        self.currentGestureAttemptNumber = self.maxGestureAttemptNumber
    }
    
    /// 修改用户唯一ID
    public func changeUser(_ identifier: String) {
        userIdentifier = identifier
        reload()
    }
    
    /// 保存手势密码
    func setupGestureLock(pwd: String?) {
        saveGesturePwd(pwd)
        gestureLock = pwd != nil
    }
    
    /// 保存指纹/faceid状态
    func setupBiometryLock(setting: Bool) {
        saveBiometrySetting(setting)
        biometryLock = setting
    }
    
    /// 生物识别检测
    public func localAuthenticationForBiometry(successClosure:@escaping (() -> ()) = {}, failedClosure:@escaping ((SecurityManager.AuthenticateError) -> ())) {
        biometry.authenticate(fallbackTitle: fallbackTitle, successClosure: successClosure, failedClosure: failedClosure)
    }
    
    /// 手势密码检测
    public func localAuthenticationForGesture(_ pwd: String) -> Bool {
        if let savedPwd = getGestrurePwd() {
            if pwd == savedPwd {
                return true
            }
            currentGestureAttemptNumber = max(currentGestureAttemptNumber - 1, 0)
            return false
        }
        currentGestureAttemptNumber = max(currentGestureAttemptNumber - 1, 0)
        return false
    }
    
    private func saveGesturePwd(_ pwd: String?) {
        UserDefaults.standard.set(pwd, forKey: "com.kagenz.SecurityManager.Gesture.\(userIdentifier)")
        UserDefaults.standard.synchronize()
    }
    
    private func getGestrurePwd() -> String? {
        return UserDefaults.standard.string(forKey: "com.kagenz.SecurityManager.Gesture.\(userIdentifier)")
    }
    
    private func saveBiometrySetting(_ setting: Bool) {
        UserDefaults.standard.set(setting, forKey: "com.kagenz.SecurityManager.Biometry.\(userIdentifier)")
        UserDefaults.standard.synchronize()
    }
    
    private func getBiometrySetting() -> Bool {
        return UserDefaults.standard.bool(forKey: "com.kagenz.SecurityManager.Biometry.\(userIdentifier)")
    }
    
    private init() {
        reload()
    }
    
    private func reload() {
        if getGestrurePwd() != nil {
            gestureLock = true
        }
        if getBiometrySetting() {
            biometryLock = true
        }
    }
}


extension SecurityManager {
    public enum BiometryType {
        case none
        case faceID
        case touchID
    }
}

extension SecurityManager {
    public enum LockType {
        case gesture
        case biometry
    }
}

extension SecurityManager {
    public enum AuthenticateError: Error, CustomDebugStringConvertible, CustomStringConvertible {
        case appCancel
        case systemCancel
        case userCancel
        case authenticationFailed
        case passcodeNotSet
        case biometryNotAvailable
        case biometryNotEnrolled
        case biometryLockout
        case userFallback
        case invalidContext
        case notInteractive
        case forgetGesturePwd
//        case beyondAttempts
        case unknown
        
        public var description: String {
            return message()
        }
        
        public var debugDescription: String {
            return message()
        }
        
        private func message() -> String {
            switch self {
            case .appCancel:              return "appCancel: app退出, 不用处理"
            case .systemCancel:           return "systemCancel: 系统强制取消, 比如来电话了, 不用处理"
            case .userCancel:             return "userCancel: 用户点击了取消按钮, 不用处理"
            case .authenticationFailed:   return "authenticationFailed: 验证失败, 弹框提示"
            case .passcodeNotSet:         return "passcodeNotSet: 用户没有设置密码, 不能设置指纹, 弹框提示"
            case .biometryNotAvailable:   return "biometryNotAvailable: 设备没有touchID, 除了机型不可用, 还有可能是指纹模块损坏, faceid被禁用时也显示, 弹框提示"
            case .biometryNotEnrolled:    return "biometryNotEnrolled: 用户没有录入指纹, 弹框提示"
            case .biometryLockout:        return "biometryLockout: 设备解锁太多次,锁定了,需要密码去解锁 , 密码错误多次锁定也走这里 只不过进去之后用户只能点取消"
            case .userFallback:           return "userFallback: 点击了使用密码按钮, 处理使用密码逻辑"
            case .invalidContext:         return "invalidContext: LAContext已经失效, 这里基本上不会走, 因为上边每次调用context 都是新创建的, 不用处理"
            case .notInteractive:         return "notInteractive: UI无法交互, 不用处理"
            case .forgetGesturePwd:       return "forgetGesturePwd: 忘记了手势密码"
            case .unknown:                return "unknown: 未知错误, 系统返回了不在枚举范围内的code"
            }
        }
    }
}

extension LAError {
    fileprivate func transformToAuthenticateError() -> SecurityManager.AuthenticateError {
        if #available(iOS 11.0, *) {
            if self.code == .biometryNotAvailable {
                return .biometryNotAvailable
            } else if self.code == .biometryNotEnrolled {
                return .biometryNotEnrolled
            } else if self.code == .biometryLockout {
                return .biometryLockout
            }
        }
        
        switch self.code {
        case .appCancel: return .appCancel
        case .systemCancel: return .systemCancel
        case .userCancel:  return .userCancel
        case .authenticationFailed: return .authenticationFailed
        case .passcodeNotSet: return .passcodeNotSet
        case .touchIDNotAvailable: return .biometryNotAvailable
        case .touchIDNotEnrolled: return .biometryNotEnrolled
        case .touchIDLockout: return .biometryLockout
        case .userFallback: return .userFallback
        case .invalidContext: return .invalidContext
        case .notInteractive: return .notInteractive
        @unknown default: return .unknown
        }
    }
}

extension SecurityManager {
    private final class Biometry {
        fileprivate func canUseDeviceID() -> (LAContext, Bool, NSError?) {
            let context = LAContext()
            var error: NSError? = nil
            let result = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            return (context, result, error)
        }
        
        fileprivate func authenticate(fallbackTitle: String? = nil, second: Bool = false, successClosure:@escaping (() -> ()) = {}, failedClosure:@escaping ((SecurityManager.AuthenticateError) -> ()) = {_ in}) {
            let (context, isCanEvaluatePolicy, error) = canUseDeviceID()
            
            if isCanEvaluatePolicy || LAError.init(_nsError: error!).code == .touchIDLockout {
                var message = "通过Home键验证已有手机指纹"
                if SecurityManager.shared.biometryType == .faceID {
                    message = "请利用面容 ID 解锁"
                }
                context.localizedFallbackTitle = fallbackTitle
                context.evaluatePolicy(second ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics, localizedReason: message) {[weak self](success, err) in
                    DispatchQueue.main.async {
                        if success {
                            if error != nil {
                                self?.processError(error!, fallbackTitle: fallbackTitle, successClosure: successClosure, failedClosure: failedClosure)
                            } else {
                                successClosure()
                            }
                        } else {
                            self?.processError(err! as NSError, fallbackTitle: fallbackTitle, successClosure: successClosure, failedClosure: failedClosure)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.processError(error!, fallbackTitle: fallbackTitle, successClosure: successClosure, failedClosure: failedClosure)
                }
            }
        }
        
        private func processError(_ err: NSError, fallbackTitle: String? = nil, successClosure:@escaping (() -> ()) = {}, failedClosure:@escaping ((SecurityManager.AuthenticateError) -> ()) = {_ in}) {
            let error = LAError.init(_nsError: err)
            if #available(iOS 11.0, *), error.code == .biometryLockout {
                /// 生物识别失败, 进行手机系统密码验证
                self.authenticate(fallbackTitle: fallbackTitle, second: true, successClosure: successClosure, failedClosure: failedClosure)
                return
            } else if error.code == .touchIDLockout {
                /// 生物识别失败, 进行手机系统密码验证
                self.authenticate(fallbackTitle: fallbackTitle, second: true, successClosure: successClosure, failedClosure: failedClosure)
                return
            } else {
                failedClosure(error.transformToAuthenticateError())
            }
        }
    }
}

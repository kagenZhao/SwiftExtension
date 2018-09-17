//
//  SecurityManager.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/7/27.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit
import DeviceKit
import LocalAuthentication

public final class SecurityManager {
    public static let shared = SecurityManager()
    public var fallbackTitle: String = "验证密码"
    public var maxGestureAttemptNumber = 5
    lazy private var _currentGestureAttemptNumber: Int = {
        var saved = UserDefaults.standard.integer(forKey: "com.kagenz.SecurityManager.currentGestureAttemptNumber")
        if saved > maxGestureAttemptNumber {
            saved = maxGestureAttemptNumber
            UserDefaults.standard.set(saved, forKey: "com.kagenz.SecurityManager.currentGestureAttemptNumber")
            UserDefaults.standard.synchronize()
        }
        return saved
    }()
    
    public private(set) var currentGestureAttemptNumber: Int {
        set {
            _currentGestureAttemptNumber = min(maxGestureAttemptNumber, max(newValue, 0))
            UserDefaults.standard.set(_currentGestureAttemptNumber, forKey: "com.kagenz.SecurityManager.currentGestureAttemptNumber")
            UserDefaults.standard.synchronize()
        }
        get {
            return _currentGestureAttemptNumber
        }
    }
    public private(set) var gestureLock: Bool = false // 是否设置了手势密码
    public private(set) var biometryLock: Bool = false // 是否设置了指纹/faceid
    public private(set) var biometryType: BiometryType
    public lazy var window: UIWindow = {
        let w = UIWindow.init(frame: UIScreen.main.bounds)
        w.backgroundColor = .white
        w.windowLevel = .alert
        return w
    }()
    private var notificationObservers: [Any] = []
    private var becomeActiveAction: ((Bool, SecurityManager.AuthenticateError?) -> ())?
    private var biometry = Biometry()
    private var device = Device()
    
    public func showCreateAuthenticateController(_ type: LockType, fromController: UIViewController, completed: ((Bool, SecurityManager.AuthenticateError?) -> ())? = nil) {
        let newComplteted: ((Bool, SecurityManager.AuthenticateError?) -> ()) = {[weak self] (success, err) in
            if success {
                self?.resetGestureAttemptNumber()
            }
            completed?(success, err)
        }
        switch type {
        case .gesture:
            if !self.biometryLock {
                let vc = GestureLockViewController(withCreatedCompleted: { (createSuccess, err) in
                    newComplteted(createSuccess, err)
                })
                fromController.show(vc, sender: fromController)
            } else {
                biometry.authenticate(fallbackTitle: fallbackTitle, successClosure: {
                    let vc = GestureLockViewController(withCreatedCompleted: { (createSuccess, err) in
                        newComplteted(createSuccess, err)
                    })
                    fromController.show(vc, sender: fromController)                        
                }) { (err) in
                    newComplteted(false, err)
                }
            }
        case .biometry:
            if !self.gestureLock {
                biometry.authenticate(fallbackTitle: fallbackTitle, successClosure: {[weak self] in
                    self?.setupBiometryLock(setting: true)
                    newComplteted(true, nil)
                }) { (err) in
                    newComplteted(false, err)
                }
            } else {
                var vc: GestureLockViewController?
                vc = GestureLockViewController(withValidateComplete: {[weak self] (validateSuccess, err) in
                    guard let sself = self else {
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(false, .userCancel)
                        return
                    }
                    if validateSuccess {
                        sself.biometry.authenticate(fallbackTitle: sself.fallbackTitle, successClosure: {[weak self] in
                            self?.setupBiometryLock(setting: true)
                            vc?.dismiss(animated: true, completion: nil)
                            newComplteted(true, nil)
                        }) { (err) in
                            vc?.dismiss(animated: true, completion: nil)
                            newComplteted(false, err)
                        }
                    } else {
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(false, err)
                    }
                })
                fromController.present(vc!, animated: true, completion: nil)
            }
            
            
        }
    }
    
    public func closeAuthenticate(_ type: LockType, fromController: UIViewController, completed: ((Bool, SecurityManager.AuthenticateError?) -> ())? = nil) {
        let newComplteted: ((Bool, SecurityManager.AuthenticateError?) -> ()) = {[weak self] (success, err) in
            if success {
                self?.resetGestureAttemptNumber()
            }
            completed?(success, err)
        }
        switch type {
        case .gesture:
            if !self.biometryLock {
                var vc: GestureLockViewController?
                vc = GestureLockViewController(withValidateComplete: {[weak self] (validateSuccess, err) in
                    guard let sself = self else {
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(false, .userCancel)
                        return
                    }
                    if validateSuccess {
                        sself.setupGestureLock(pwd: nil)
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(true, nil)
                    } else {
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(false, err)
                    }
                })
                fromController.present(vc!, animated: true, completion: nil)
            } else {
                biometry.authenticate(fallbackTitle: fallbackTitle, successClosure: {[weak self] in
                    self?.setupGestureLock(pwd: nil)
                    newComplteted(true, nil)
                }) { (err) in
                    newComplteted(false, err)
                }
            }
        case .biometry:
            biometry.authenticate(fallbackTitle: fallbackTitle, successClosure: {[weak self] in
                self?.setupBiometryLock(setting: false)
                newComplteted(true, nil)
            }) { (err) in
                newComplteted(false, err)
            }
        }
    }
    
    private static var _onceToken: Void?
    public func authenticateInApplicationBecomeActive(timeInterval: TimeInterval, validateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())? = nil) {
        self.becomeActiveAction = validateComplete
    }
    
    public func authenticateInApplicationLaunch(_ type: LockType? = nil, validateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())? = nil) {
        authenticate(type, validateComplete: validateComplete)
    }
    
    public func authenticate(_ type: LockType? = nil, validateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())? = nil) {
        let newComplteted: ((Bool, SecurityManager.AuthenticateError?) -> ()) = {[weak self] (success, err) in
            if success {
                self?.resetGestureAttemptNumber()
            }
            validateComplete?(success, err)
        }
        if let t = type {
            switch t {
            case .biometry:
                if biometryLock {
                    if window.rootViewController is BiometryLockViewController { return }
                    BiometryLockViewController(with: newComplteted).showInWindow(window)
                } else {
                    newComplteted(true, nil)
                }
            case .gesture:
                if gestureLock {
                    if window.rootViewController is GestureLockViewController { return }
                    GestureLockViewController(withValidateComplete: newComplteted).showInWindow(window)
                } else {
                    newComplteted(true, nil)
                }
            }
        } else {
            if biometryLock {
                if window.rootViewController is BiometryLockViewController { return }
                BiometryLockViewController(with: newComplteted).showInWindow(window)
            } else if gestureLock {
                if window.rootViewController is GestureLockViewController { return }
                GestureLockViewController(withValidateComplete: newComplteted).showInWindow(window)
            } else {
                newComplteted(true, nil)
            }
        }
    }
    
    public func resetGestureAttemptNumber() {
        self.currentGestureAttemptNumber = self.maxGestureAttemptNumber
    }
    
    func setupGestureLock(pwd: String?) {
        saveGesturePwd(pwd)
        gestureLock = pwd != nil
    }
    
    func setupBiometryLock(setting: Bool) {
        saveBiometrySetting(setting)
        biometryLock = setting
    }
    
    
    func localAuthenticationForBiometry(successClosure:@escaping (() -> ()) = {}, failedClosure:@escaping ((SecurityManager.AuthenticateError) -> ())) {
        biometry.authenticate(fallbackTitle: fallbackTitle, successClosure: successClosure, failedClosure: failedClosure)
    }
    
    func localAuthenticationForGesture(_ pwd: String) -> Bool {
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
        UserDefaults.standard.set(pwd, forKey: "com.kagenz.SecurityManager.Gesture")
        UserDefaults.standard.synchronize()
    }
    
    private func getGestrurePwd() -> String? {
        return UserDefaults.standard.string(forKey: "com.kagenz.SecurityManager.Gesture")
    }
    
    private func saveBiometrySetting(_ setting: Bool) {
        UserDefaults.standard.set(setting, forKey: "com.kagenz.SecurityManager.Biometry")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(biometry.canUseDeviceID().0.evaluatedPolicyDomainState, forKey: "com.kagenz.SecurityManager.Biometry.oldState")
        UserDefaults.standard.synchronize()
    }
    
    private func getBiometrySetting() -> Bool {
        return UserDefaults.standard.bool(forKey: "com.kagenz.SecurityManager.Biometry")
    }
    
    private init() {
        
        if Device.allNoneBiometry.contains(device) {
            biometryType = .none
        } else if Device.allTouchId.contains(device) {
            biometryType = .touchID
        } else { // 未知类型的手机 一般为新手机 这里默认认为他是 FaceID
            biometryType = .faceID
        }
        
        if getGestrurePwd() != nil {
            gestureLock = true
        }
        if getBiometrySetting() {
            biometryLock = true
        }
        
        let key = "com.kagenz.SecurityManager.backgroundTime"
        let obs1 = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { (notification) in
            UserDefaults.standard.set(Date(), forKey: key)
            UserDefaults.standard.synchronize()
        }
        
        let obs2 = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) {[unowned self] (notification) in
            guard let oldDate = UserDefaults.standard.value(forKey: key) as? Date else { return }
            let date = Date()
            let times = abs(date.timeIntervalSince(oldDate))
            if times > 5 {
                self.authenticate(validateComplete: self.becomeActiveAction)
            }
        }
        notificationObservers.append(obs1)
        notificationObservers.append(obs2)
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
        case changeBiometry
//        case beyondAttempts
        
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
            case .biometryNotAvailable:   return "biometryNotAvailable: 设备没有touchID, 除了机型不可用, 还有可能是指纹模块损坏, 弹框提示"
            case .biometryNotEnrolled:    return "biometryNotEnrolled: 用户没有录入指纹, 弹框提示"
            case .biometryLockout:        return "biometryLockout: 设备解锁太多次,锁定了,需要密码去解锁 , 密码错误多次锁定也走这里 只不过进去之后用户只能点取消"
            case .userFallback:           return "userFallback: 点击了使用密码按钮, 处理使用密码逻辑"
            case .invalidContext:         return "invalidContext: LAContext已经失效, 这里基本上不会走, 因为上边每次调用context 都是新创建的, 不用处理"
            case .notInteractive:         return "notInteractive: UI无法交互, 不用处理"
            case .forgetGesturePwd:       return "forgetGesturePwd: 忘记了手势密码"
            case .changeBiometry:         return "changeBiometry: 用户修改了指纹"
//            case .beyondAttempts:         return "beyondAttempts: 手势密码超过尝试次数"
            }
        }
    }
}

extension LAError {
    fileprivate func transformToAuthenticateError() -> SecurityManager.AuthenticateError {
        if #available(iOS 11, *) {
            if code == .biometryNotAvailable {
                return .biometryNotAvailable
            } else if code == .biometryLockout {
                return .biometryLockout
            } else if code == .biometryNotEnrolled {
                return .biometryNotEnrolled
            }
        }
        switch code {
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
        }
    }
}

extension SecurityManager {
    private final class Biometry {
        fileprivate func canUseDeviceID() -> (LAContext, Bool, SecurityManager.AuthenticateError?) {
            let context = LAContext()
            var error: NSError?
            var err: SecurityManager.AuthenticateError?
            var result = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            err = error == nil ? nil : LAError.init(_nsError: error!).transformToAuthenticateError()
            if result, let status = context.evaluatedPolicyDomainState{
                if let oldStatus = UserDefaults.standard.data(forKey: "com.kagenz.SecurityManager.Biometry.oldState") {
                    if status != oldStatus { // 用户修改了指纹(包括增加或删除)
                        result = false
                        err = .changeBiometry
                    }
                } else {
                    UserDefaults.standard.set(status, forKey: "com.kagenz.SecurityManager.Biometry.oldState")
                    UserDefaults.standard.synchronize()
                }
            }
            return (context, result, err)
        }
        
        fileprivate func authenticate(fallbackTitle: String? = nil, second: Bool = false, successClosure:@escaping (() -> ()) = {}, failedClosure:@escaping ((SecurityManager.AuthenticateError) -> ()) = {_ in}) {
            let (context, isCanEvaluatePolicy, error) = canUseDeviceID()
            
            if isCanEvaluatePolicy || error == .biometryLockout {
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
                            self?.processError((err! as! LAError).transformToAuthenticateError(), fallbackTitle: fallbackTitle, successClosure: successClosure, failedClosure: failedClosure)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.processError(error!, fallbackTitle: fallbackTitle, successClosure: successClosure, failedClosure: failedClosure)
                }
            }
        }
        
        private func processError(_ err: SecurityManager.AuthenticateError, fallbackTitle: String? = nil, successClosure:@escaping (() -> ()) = {}, failedClosure:@escaping ((SecurityManager.AuthenticateError) -> ()) = {_ in}) {
            switch err {
            case .appCancel:
                break
            case .systemCancel:
                break
            case .userCancel:
                break
            case .authenticationFailed:
                break
            case .passcodeNotSet:
                break
            case .biometryNotAvailable:
                break
            case .biometryNotEnrolled:
                break
            case .biometryLockout:
                self.authenticate(fallbackTitle: fallbackTitle, second: true, successClosure: successClosure, failedClosure: failedClosure)
                return
            case .userFallback:
                break
            case .invalidContext:
                break
            case .notInteractive:
                break
            case .forgetGesturePwd:
                break
            case .changeBiometry:
                break
            }
            failedClosure(err)
        }
        
    }
}

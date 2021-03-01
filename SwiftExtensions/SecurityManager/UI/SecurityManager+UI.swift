//
//  SecurityManager+UI.swift
//  wmIOS
//
//  Created by Kagen Zhao on 2021/2/19.
//  Copyright © 2021 kagen. All rights reserved.
//

import UIKit

extension SecurityManager {
    private static var window: UIWindow = {
        let w = UIWindow.init(frame: UIScreen.main.bounds)
        w.backgroundColor = .white
        w.windowLevel = UIWindow.Level.alert
        return w
    }()
    
    public func hiddenWindow() {
        SecurityManager.window.resignKey()
        SecurityManager.window.rootViewController = nil
        SecurityManager.window.isHidden = true
    }
    
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
                vc.modalPresentationStyle = .fullScreen
                fromController.show(vc, sender: fromController)
            } else {
                localAuthenticationForBiometry(successClosure: {
                    let vc = GestureLockViewController(withCreatedCompleted: { (createSuccess, err) in
                        newComplteted(createSuccess, err)
                    })
                    vc.modalPresentationStyle = .fullScreen
                    fromController.show(vc, sender: fromController)
                }, failedClosure: {(err) in
                    newComplteted(false, err)
                })
            }
        case .biometry:
            if !self.gestureLock {
                localAuthenticationForBiometry(successClosure: {[weak self] in
                    self?.setupBiometryLock(setting: true)
                    newComplteted(true, nil)
                }) { (err) in
                    newComplteted(false, err)
                }
            } else {
                var vc: GestureLockViewController?
                vc = GestureLockViewController(withValidateComplete: {[weak self] (validateSuccess, err) in
                    guard let self = self else {
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(false, .userCancel)
                        return
                    }
                    if validateSuccess {
                        self.localAuthenticationForBiometry(successClosure: {[weak self] in
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
                vc?.modalPresentationStyle = .fullScreen
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
                    guard let self = self else {
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(false, .userCancel)
                        return
                    }
                    if validateSuccess {
                        self.setupGestureLock(pwd: nil)
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(true, nil)
                    } else {
                        vc?.dismiss(animated: true, completion: nil)
                        newComplteted(false, err)
                    }
                })
                vc?.modalPresentationStyle = .fullScreen
                fromController.present(vc!, animated: true, completion: nil)
            } else {
                localAuthenticationForBiometry(successClosure: {[weak self] in
                    self?.setupGestureLock(pwd: nil)
                    newComplteted(true, nil)
                }) { (err) in
                    newComplteted(false, err)
                }
            }
        case .biometry:
            localAuthenticationForBiometry(successClosure: {[weak self] in
                self?.setupBiometryLock(setting: false)
                newComplteted(true, nil)
            }) { (err) in
                newComplteted(false, err)
            }

        }
    }
    
    public func resetGestureLock(fromController: UIViewController, completed: ((Bool, SecurityManager.AuthenticateError?) -> ())? = nil) {
        let newComplteted: ((Bool, SecurityManager.AuthenticateError?) -> ()) = {[weak self] (success, err) in
            if success {
                self?.resetGestureAttemptNumber()
            }
            completed?(success, err)
        }
        
        if !self.biometryLock {
            let vc = GestureLockViewController(withValidateComplete: { (createSuccess, err) in
                newComplteted(createSuccess, err)
            })
            vc.isReset = true
            fromController.show(vc, sender: fromController)
        } else {
            localAuthenticationForBiometry(successClosure: {
                let vc = GestureLockViewController(withCreatedCompleted: { (createSuccess, err) in
                    newComplteted(createSuccess, err)
                })
                fromController.show(vc, sender: fromController)
            }) { (err) in
                newComplteted(false, err)
            }
        }
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
                    if SecurityManager.window.rootViewController is BiometryLockViewController { return }
                    BiometryLockViewController(with: newComplteted).showInWindow(SecurityManager.window)
                } else {
                    newComplteted(true, nil)
                }
            case .gesture:
                if gestureLock {
                    if SecurityManager.window.rootViewController is GestureLockViewController { return }
                    GestureLockViewController(withValidateComplete: newComplteted).showInWindow(SecurityManager.window)
                } else {
                    newComplteted(true, nil)
                }
            }
        } else {
            if biometryLock {
                if SecurityManager.window.rootViewController is BiometryLockViewController { return }
                BiometryLockViewController(with: newComplteted).showInWindow(SecurityManager.window)
            } else if gestureLock {
                if SecurityManager.window.rootViewController is GestureLockViewController { return }
                GestureLockViewController(withValidateComplete: newComplteted).showInWindow(SecurityManager.window)
            } else {
                newComplteted(true, nil)
            }
        }
    }
}

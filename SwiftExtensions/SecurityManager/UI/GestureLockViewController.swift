//
//  GestureLockViewController.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/7/27.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit
import SnapKit
import LocalAuthentication
class GestureLockViewController: UIViewController {

    enum GestureLockType {
        case create
        case validate
    }
    
    var isReset: Bool = false
    private var validateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())?
    private var createSuccess: Bool = false
    private var createdCompleted: ((Bool, SecurityManager.AuthenticateError?) -> ())?
    private var type: GestureLockType = .create
    private var gestureLockView: GestureLockView = GestureLockView()
    private var gestureLockIndicator: GestureLockIndicator = GestureLockIndicator()
    private var infoLabel: UILabel = UILabel()
    private var resetPwdButton: UIButton = UIButton(type: .system)
    private var forgetPwdButton: UIButton = UIButton(type: .system)
    private var otherFuncButton: UIButton = UIButton(type: .system)
    private var backButton: UIButton = UIButton(type: .custom)
    private var pwd: String?
    private var window: UIWindow?
    
    init(type: GestureLockType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    convenience init(withCreatedCompleted: ((Bool, SecurityManager.AuthenticateError?) -> ())?) {
        self.init(type: .create)
        self.createdCompleted = withCreatedCompleted
    }
    
    convenience init(withValidateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())?) {
        self.init(type: .validate)
        self.validateComplete = withValidateComplete
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = (type == .create) ? "设置手势密码" : "验证手势密码"
        
        let color = UIColor(red: 0.0706, green: 0.588, blue: 0.859, alpha: 1)
        
        view.addSubview(gestureLockView)
        gestureLockView.snp.makeConstraints({ (maker) in
            maker.left.equalTo(view).offset(45)
            maker.right.equalTo(view).offset(-45)
            maker.width.equalTo(gestureLockView.snp.height)
            maker.centerY.equalTo(view)
        })
        
        infoLabel.textColor = UIColor.lightGray
        infoLabel.text = "绘制解锁图案"
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(view)
            maker.bottom.equalTo(gestureLockView.snp.top).offset(-15)
        }
        
        view.addSubview(gestureLockIndicator)
        gestureLockIndicator.snp.makeConstraints({ (maker) in
            maker.centerX.equalTo(view)
            maker.bottom.equalTo(infoLabel.snp.top).offset(-10)
            maker.width.height.equalTo(45)
        })
        
        otherFuncButton.setTitle("其他方式", for: .normal)
        otherFuncButton.setTitleColor(color, for: .normal)
        otherFuncButton.addTarget(self, action: #selector(otherFunction(_:)), for: .touchUpInside)
        view.addSubview(otherFuncButton)
        otherFuncButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(view).offset(25)
            maker.bottom.equalTo(view).offset(-30)
            maker.width.equalTo(100)
            maker.height.equalTo(35)
        }
        
        resetPwdButton.isHidden = true
        resetPwdButton.setTitle("重新绘制", for: .normal)
        resetPwdButton.setTitleColor(color, for: .normal)
        resetPwdButton.addTarget(self, action: #selector(resetPwd(_:)), for: .touchUpInside)
        view.addSubview(resetPwdButton)
        resetPwdButton.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(view)
            maker.bottom.equalTo(view).offset(-30)
            maker.width.equalTo(100)
            maker.height.equalTo(35)
        }
        
        forgetPwdButton.setTitle("忘记手势?", for: .normal)
        forgetPwdButton.setTitleColor(color, for: .normal)
        forgetPwdButton.addTarget(self, action: #selector(forgetPwd(_:)), for: .touchUpInside)
        view.addSubview(forgetPwdButton)
        forgetPwdButton.snp.makeConstraints { (maker) in
            maker.right.equalTo(view).offset(-25)
            maker.bottom.equalTo(view).offset(-30)
            maker.width.equalTo(100)
            maker.height.equalTo(35)
        }
        
        backButton.setTitle("取消", for: .normal)
        backButton.setTitleColor(color, for: .normal)
        backButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(view).offset(30)
            maker.top.equalTo(view).offset(40)
            maker.width.height.equalTo(40)
        }
        
        
        gestureLockView.drawRectFinished = {[weak self] pwd in
            self?.drawRectFinished(pwd)
        }
        
        reload()
    }
    
    private func reload() {
        if type != .create {
            gestureLockIndicator.isHidden = true
            infoLabel.snp.updateConstraints { (maker) in
                maker.bottom.equalTo(gestureLockView.snp.top).offset(-30)
            }
            otherFuncButton.isHidden = false
            forgetPwdButton.isHidden = false
        } else {
            gestureLockIndicator.isHidden = false
            infoLabel.snp.updateConstraints { (maker) in
                maker.bottom.equalTo(gestureLockView.snp.top).offset(-15)
            }
            otherFuncButton.isHidden = true
            forgetPwdButton.isHidden = true
        }
        
        if !SecurityManager.shared.biometryLock {
            otherFuncButton.isHidden = true
            forgetPwdButton.snp.remakeConstraints { (maker) in
                maker.centerX.equalTo(view)
                maker.bottom.equalTo(view).offset(-30)
                maker.width.equalTo(100)
                maker.height.equalTo(35)
            }
        }
        infoLabel.text = "绘制解锁图案"
        infoLabel.textColor = .lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.isHidden = !(self.navigationController == nil && self.presentingViewController != nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTryNumbers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if type == .create {
            createdCompleted?(createSuccess, createSuccess ? nil : .userCancel)
        }
    }
    
    private func drawRectFinished(_ pwd: String) {
        if pwd.count < 4 {
            infoLabel.text = "至少连接4个点，请重新输入"
            infoLabel.textColor = .red
            shakeAnimation(for: infoLabel)
            return
        }
        switch type {
        case .create:
            if self.pwd == nil {
                self.gestureLockIndicator.setPwd(pwd)
                infoLabel.text = "再次绘制解锁图案"
                infoLabel.textColor = UIColor.lightGray
                self.resetPwdButton.isHidden = false
                self.pwd = pwd
            } else if pwd != self.pwd {
                infoLabel.text = "与上一次绘制不一致，请重新绘制"
                infoLabel.textColor = .red
                shakeAnimation(for: infoLabel)
            } else {
                // 创建成功
                SecurityManager.shared.setupGestureLock(pwd: pwd)
                createSuccess = true
                self.back()
            }
        case .validate:
            if !SecurityManager.shared.localAuthenticationForGesture(pwd) {
                if SecurityManager.shared.currentGestureAttemptNumber == 0 {
                    checkTryNumbers()
                } else {
                    infoLabel.text = "手势错误，还可以再输入\(SecurityManager.shared.currentGestureAttemptNumber)次"
                    infoLabel.textColor = .red
                    shakeAnimation(for: infoLabel)
                }
            } else {
                if isReset {
                    type = .create
                    reload()
                    createdCompleted = validateComplete
                    validateComplete = nil
                    self.navigationItem.title = "设置手势密码"
                } else {
                    validateComplete?(true, nil)
                    removeFromWindow()
                }
            }            
        }
    }
    
    private func shakeAnimation(for view: UIView) {
        let viewLayer = view.layer
        let position = viewLayer.position
        let left = CGPoint(x: position.x - 10, y: position.y)
        let right = CGPoint(x: position.x + 10, y: position.y)
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fromValue = left
        animation.toValue = right
        animation.autoreverses = true
        animation.duration = 0.08
        animation.repeatCount = 3
        viewLayer.add(animation, forKey: nil)
    }
    
    @objc private func otherFunction(_ sender: UIButton) {
        let text = getBiometryString()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: text, style: .default, handler: {[weak self] _ in
            SecurityManager.shared.authenticate(.biometry, validateComplete: self?.validateComplete)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self?.removeFromWindow()
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func resetPwd(_ sender: UIButton) {
        infoLabel.textColor = UIColor.lightGray
        infoLabel.text = "绘制解锁图案"
        resetPwdButton.isHidden = true
        pwd = nil
        gestureLockIndicator.setPwd("")
    }
    
    @objc private func forgetPwd(_ sender: UIButton) {
        forgetPwdWithCancelAction(nil)
    }
    
    private func forgetPwdWithCancelAction(_ action: (() -> ())? = nil) {
        if SecurityManager.shared.biometryLock {
            let text = getBiometryString()
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: text, style: .default, handler: {[weak self] _ in
                SecurityManager.shared.authenticate(.biometry, validateComplete: self?.validateComplete)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self?.removeFromWindow()
                })
            }))
            actionSheet.addAction(UIAlertAction(title: "忘记手势", style: .default, handler: {[weak self] _ in
                self?.validateComplete?(false, .forgetGesturePwd)
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
                action?()
            }))
            self.present(actionSheet, animated: true, completion: nil)
        } else {
            self.validateComplete?(false, .forgetGesturePwd)
        }
    }
    
    private func checkTryNumbers() {
        if SecurityManager.shared.currentGestureAttemptNumber == 0 && type == .validate {
            infoLabel.text = "手势错误已达上限"
            infoLabel.textColor = .red
            gestureLockView.isUserInteractionEnabled = false
            let alert = UIAlertController(title: nil, message: "手势错误已达上限, 请尝试其他方式解锁", preferredStyle: .actionSheet)
            if let biometryStr = getBiometryString() {
                alert.addAction(UIAlertAction(title: biometryStr, style: .default, handler: {[weak self] _ in
                    SecurityManager.shared.authenticate(.biometry, validateComplete: self?.validateComplete)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self?.removeFromWindow()
                    })
                }))
            }
            alert.addAction(UIAlertAction(title: "忘记手势", style: .default, handler: {[weak self] (_) in
                self?.forgetPwdWithCancelAction({
                    self?.dismissAction()
                })
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: {[weak self] (_) in
                self?.dismissAction()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getBiometryString() -> String? {
        if SecurityManager.shared.biometryLock {
            var text: String!
            switch SecurityManager.shared.biometryType {
            case .none: return nil
            case .faceID:
                text = "面容 ID 解锁"
            case .touchID:
                text = "指纹解锁"
            }
            return text
        }
        return nil
    }
    
    
    @objc private func dismissAction() {
        if self.validateComplete != nil {
            self.validateComplete?(false, .userCancel)
        }
        if self.createdCompleted != nil {
            self.createdCompleted?(false, .userCancel)
        }
        back()
    }
    
    private func back() {
        if self.navigationController != nil, self.navigationController?.viewControllers[0] != self {
            var toViewController: UIViewController!
            for vc in self.navigationController!.viewControllers {
                if vc.isKind(of: GestureLockViewController.self) {
                    break
                } else {
                    toViewController = vc
                }
            }
            if toViewController != nil {
                self.navigationController?.popToViewController(toViewController, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } else if self.navigationController != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showInWindow(_ window: UIWindow?) {
        DispatchQueue.main.async {
            self.window = window ?? self.createWindow()
            self.window?.rootViewController = self
            self.window?.makeKeyAndVisible()
            self.window?.isHidden = false
        }
    }
    
    func removeFromWindow() {
        DispatchQueue.main.async {
            self.window?.resignKey()
            self.window?.rootViewController = nil
            self.window?.isHidden = true
            self.window = nil
        }
    }

    private func createWindow() -> UIWindow {
        let w = UIWindow.init(frame: UIScreen.main.bounds)
        w.backgroundColor = .white
        w.windowLevel = UIWindow.Level.alert
        return w
    }
}

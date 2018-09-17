//
//  BiometryLockViewController.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/7/27.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit
import SnapKit
import LocalAuthentication

class BiometryLockViewController: UIViewController {
    
    private var validateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())?
    private var window: UIWindow?
    private var tapGesture: UITapGestureRecognizer?
    private var didEnderBackground = false
    init(with validateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())?) {
        super.init(nibName: nil, bundle: nil)
        self.validateComplete = validateComplete
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showInWindow(_ window: UIWindow?) {
        DispatchQueue.main.async {
            self.window = window ?? self.createWindow()
            self.window?.rootViewController = self
            self.window?.makeKeyAndVisible()
        }
    }
    
    func removeFromWindow() {
        DispatchQueue.main.async {
            self.window?.rootViewController = nil
            self.window?.isHidden = true
        }
    }
    
    private func createWindow() -> UIWindow {
        let w = UIWindow.init(frame: UIScreen.main.bounds)
        w.backgroundColor = .white
        w.windowLevel = .alert
        return w
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let color = UIColor(red: 0.0706, green: 0.588, blue: 0.859, alpha: 1)
        var text: String?
        var image: UIImage?
        switch SecurityManager.shared.biometryType {
        case .none:
            text = "点击进行指纹解锁"
            image = UIImage.currentBundleImage(with: "touchid")
            return
        case .faceID:
            text = "点击进行面容 ID 解锁"
            image = UIImage.currentBundleImage(with: "faceid")
        case .touchID:
            text = "点击进行指纹解锁"
            image = UIImage.currentBundleImage(with: "touchid")
        }
        
        let centerView = UIView()
        view.addSubview(centerView)
        centerView.snp.makeConstraints { (maker) in
            maker.center.equalTo(view)
        }
        
        
        let imageView = UIImageView(image: image)
        centerView.addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.top.centerX.equalTo(centerView)
            maker.width.height.equalTo(70)
        }
        
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: 14)
        centerView.addSubview(label)
        label.snp.makeConstraints { (maker) in
            maker.top.equalTo(imageView.snp.bottom).offset(15)
            maker.left.bottom.right.equalTo(centerView)
        }
        
        let button = UIButton(type: .system)
        button.setTitle("其他解锁方式", for: .normal)
        button.setTitleColor(color, for: .normal)
        button.addTarget(self, action: #selector(otherFunction(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(view)
            maker.bottom.equalTo(view).offset(-30)
            maker.width.equalTo(100)
            maker.height.equalTo(35)
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        centerView.addGestureRecognizer(tapGesture!)
        
        if !SecurityManager.shared.gestureLock {
            button.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnderBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func applicationDidEnderBackground(_ notification: Notification) {
        self.didEnderBackground = true
        print("sssssss")
    }
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        print("aaaaaa")
        if self.didEnderBackground {
            self.tapAction(self.tapGesture!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tapAction(tapGesture!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        SecurityManager.shared.localAuthenticationForBiometry(successClosure: {[weak self] in
            self?.removeFromWindow()
            self?.validateComplete?(true, nil)
        }) {[weak self] (err) in
            self?.validateComplete?(false, err)
        }
    }
    
    @objc private func otherFunction(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "手势解锁", style: .default, handler: {[weak self] _ in
            SecurityManager.shared.authenticate(.gesture, validateComplete: self?.validateComplete)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self?.removeFromWindow()
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func back() {
        if self.navigationController != nil, self.navigationController?.viewControllers[0] != self {
            self.navigationController?.popViewController(animated: true)
        } else if self.navigationController != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

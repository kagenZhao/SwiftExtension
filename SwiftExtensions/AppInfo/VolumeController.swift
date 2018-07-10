//
//  VolumeController.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2018/7/9.
//  Copyright © 2018年 kagenZhao. All rights reserved.
//

import UIKit
import MediaPlayer

public class VolumeController {
    
    public static let shared = VolumeController()
    public var showSystemPrompt = true {
        didSet {
            volumeView.isHidden = showSystemPrompt
        }
    }
    
    public var volume: Float {
        set {
            volumeSlider?.setValue(newValue, animated: false);
            volumeSlider?.sendActions(for: .touchUpInside)
        }
        get {
            return volumeSlider?.value ?? 0
        }
    }
    
    public func addObserverble(_ closure: @escaping (Float) -> ()) {
        observers.append(closure)
    }
    
    private var observers = [(Float) -> ()]()
    
    private var _volumeView = MPVolumeView()
    private var volumeView: MPVolumeView {
        if _volumeView.superview == nil { window?.addSubview(_volumeView) }
        return _volumeView
    }
    private var volumeSlider: UISlider?
    private var window: UIWindow? {
        guard let delegate = UIApplication.shared.delegate else { return nil }
        guard let window = delegate.window else { return nil }
        return window
    }
    
    private init() {
        volumeView.frame = CGRect(x: -100, y: -100, width: 100, height: 100)
        volumeView.isHidden = showSystemPrompt
        volumeView.showsVolumeSlider = true;
        volumeView.subviews.forEach({ (subView) in
            if subView.isKind(of: NSClassFromString("MPVolumeSlider")!) {
                volumeSlider = subView as? UISlider
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChange(notification:)), name: .init("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    @objc private func volumeChange(notification: Notification) {
        if let value = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            observers.forEach {
                $0(value)
            }
        }
    }
}

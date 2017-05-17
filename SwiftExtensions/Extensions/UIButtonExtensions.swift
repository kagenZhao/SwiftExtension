//
//  UIButtonExtensions.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2017/5/17.
//  Copyright © 2017年 kagenZhao. All rights reserved.
//

import UIKit

private var _onceToken: Void?
private var _beginForceTouchClosureKey: Void?
private var _updatingForceTouchClosureKey: Void?
private var _endForceTouchClosureKey: Void?
private var _cancelForceTouchClosureKey: Void?


extension UIControl {
    
    public typealias ForceTouchClosure = (UITouch, UIEvent?) -> ()
    public typealias ForceTouchClosureEnd = (UITouch?, UIEvent?) -> ()
    public typealias ForceTouchClosureCancel = (UIEvent?) -> ()

    /// 用于设置UIControl的3dtouch(随便写写 多用于重写)
    ///
    /// - Parameters:
    ///   - begin: 开始按压
    ///   - updating: 按压力度变化
    ///   - end: 结束按压
    ///   - cancel: 外力中断操作
    public func setupForceTouchAction(begin: ForceTouchClosure? = nil,
                                      updating: ForceTouchClosure? = nil,
                                      end: ForceTouchClosureEnd? = nil,
                                      cancel: ForceTouchClosureCancel? = nil) {
        DispatchQueue.once(&_onceToken) {
            Runtime.Swizzing.exchange(class: type(of: self), fromSEL: #selector(beginTracking(_:with:)), toSEL: #selector(_swizz_beginTracking(_:with:)))
            Runtime.Swizzing.exchange(class: type(of: self), fromSEL: #selector(continueTracking(_:with:)), toSEL: #selector(_swizz_continueTracking(_:with:)))
            Runtime.Swizzing.exchange(class: type(of: self), fromSEL: #selector(endTracking(_:with:)), toSEL: #selector(_swizz_endTracking(_:with:)))
            Runtime.Swizzing.exchange(class: type(of: self), fromSEL: #selector(cancelTracking(with:)), toSEL: #selector(_swizz_cancelTracking(with:)))
        }
        _beginForceTouchClosure = begin
        _updatingForceTouchClosure = updating
        _endForceTouchClosure = end
        _cancelForceTouchClosure = cancel
    }
    
    private var _beginForceTouchClosure: ForceTouchClosure? {
        set {
            if newValue != nil {
                Runtime.Association.set(value: newValue!, for: &_beginForceTouchClosureKey, type: .copy(.nonatomic), to: self)
            }
        }
        get {
            return Runtime.Association.value(for: &_beginForceTouchClosureKey, from: self)
        }
    }
    
    private var _updatingForceTouchClosure: ForceTouchClosure? {
        set {
            if newValue != nil {
                Runtime.Association.set(value: newValue!, for: &_updatingForceTouchClosureKey, type: .copy(.nonatomic), to: self)
            }
        }
        get {
            return Runtime.Association.value(for: &_updatingForceTouchClosureKey, from: self)
        }
    }
    
    private var _endForceTouchClosure: ForceTouchClosureEnd? {
        set {
            if newValue != nil {
                Runtime.Association.set(value: newValue!, for: &_endForceTouchClosureKey, type: .copy(.nonatomic), to: self)
            }
        }
        get {
            return Runtime.Association.value(for: &_endForceTouchClosureKey, from: self)
        }
    }
    
    private var _cancelForceTouchClosure: ForceTouchClosureCancel? {
        set {
            if newValue != nil {
                Runtime.Association.set(value: newValue!, for: &_cancelForceTouchClosureKey, type: .copy(.nonatomic), to: self)
            }
        }
        get {
            return Runtime.Association.value(for: &_cancelForceTouchClosureKey, from: self)
        }
    }
    
    @objc private func _swizz_beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        _ = _swizz_beginTracking(touch, with: event)
        _beginForceTouchClosure?(touch, event)
        return true
    }
    
    @objc private func _swizz_continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        _ = _swizz_continueTracking(touch, with: event)
        _updatingForceTouchClosure?(touch, event)
        return true
    }
    
    @objc private func _swizz_endTracking(_ touch: UITouch?, with event: UIEvent?) {
        _swizz_endTracking(touch, with: event)
        _endForceTouchClosure?(touch, event)
    }
    
    @objc private func _swizz_cancelTracking(with event: UIEvent?) {
        _swizz_cancelTracking(with: event)
        _cancelForceTouchClosure?(event)
    }
}


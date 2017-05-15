//
//  UITextFieldExtensions.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2017/5/15.
//  Copyright © 2017年 kagenZhao. All rights reserved.
//

import UIKit


private var _kNumberTextFieldMaxAndMinAssociatedKey: Void?
extension UITextField {
    /// 设置数字键盘, 并且限制输入的最大最小值 
    ///    目前有些问题: 
    ///      发现个问题 如果最小num和最大num位数相同的话  就完蛋了
    ///      比如 min = 100 max = 999
    ///      你会发现 你输入的一瞬间 就变成了 100 然后你再输入就变成999  然后你删也删不了 输入也输入不了 就等于死了...
    ///
    /// - Parameters:
    ///   - min: 最小值
    ///   - max: 最大值
    public func setupNumberKeyboard(min: Int, max: Int) {
        self.keyboardType = .numberPad
        _numberTextFieldMaxAndMin = [min, max]
        self.addTarget(self, action: #selector(_numberTextDidChange(_:)), for: .editingChanged)
    }

    private var _numberTextFieldMaxAndMin: [Int]? {
        set {
            objc_setAssociatedObject(self, &_kNumberTextFieldMaxAndMinAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &_kNumberTextFieldMaxAndMinAssociatedKey) as? [Int]
        }
    }

    @objc private func _numberTextDidChange(_ sender: UITextField) {
        guard let number = _numberTextFieldMaxAndMin else { return }
        if let text = self.text, let textNumber = Int(text) {
            self.text = "\(min(max(number[0], textNumber), number[1]))"
        }
    }
}

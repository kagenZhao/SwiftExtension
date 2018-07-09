//
//  UIAlertControllerExtensions.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2017/5/11.
//  Copyright © 2017年 Kagen Zhao. All rights reserved.
//

import UIKit


private var kUIAlertControllerTitleAlignmentAssociatedKey: Void?
private var kUIAlertControllerMessageAlignmentAssociatedKey: Void?
private var kUIAlertControllerSwizzingonceToken: Void?
private let kNotfoundTextIdentifier = "_NotFundNSMutableAttributedStringText_"
private let kMessageAttributeProperty = "attributedMessage"
private let kTitleAttributeProperty = "attributedTitle"


public enum UIAlertControllerAttributes {
    case title([AttributesTypes])
    case message([AttributesTypes])
}

public enum AttributesTypes {
    /// 不可与其他公用, 如果公用只取all
    case all(NSAttributedString)
    case font(UIFont)
    case textColor(UIColor)
    case alignment(NSTextAlignment)
}

extension UIAlertController {
    
    public func setAttributes(_ attr: [UIAlertControllerAttributes]) {
        _notificationForPresented()
        Runtime.Association.set(value: attr,
                                for: &kUIAlertControllerTitleAlignmentAssociatedKey,
                                type: .retain(.nonatomic),
                                to: self)
    }
    
    private func attributes() -> [UIAlertControllerAttributes]? {
        let value: [UIAlertControllerAttributes]? = Runtime.Association.value(for: &kUIAlertControllerTitleAlignmentAssociatedKey, from: self)
        return value
    }
    
    private func _notificationForPresented() {
        DispatchQueue.once(&kUIAlertControllerSwizzingonceToken) {
            Runtime.Swizzing.exchange(class: type(of: self), fromSEL: #selector(viewWillAppear(_:)), toSEL: #selector(_swizzingViewWillAppear(_:)))
        }
    }
    
    @objc func _swizzingViewWillAppear(_ animation: Bool) {
        _swizzingViewWillAppear(animation)
        if let attributes = attributes() {
            attributes.forEach({ attrs in
                switch attrs {
                case .message(let messageAttrs):
                    let attrValue = _createAttribute(messageAttrs, text: message)
                    if (attrValue.string == message || attrValue.string != kNotfoundTextIdentifier) || message != nil {
                        setValue(attrValue, forKey: kMessageAttributeProperty)
                    }
                case .title(let titleAttrs):
                    let attrValue = _createAttribute(titleAttrs, text: title)
                    if (attrValue.string == title || attrValue.string != kNotfoundTextIdentifier) || title != nil {
                        setValue(attrValue, forKey: kTitleAttributeProperty)
                    }
                }
            })
        }
    }
    
    private func _createAttribute(_ attrs: [AttributesTypes], text: String?) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        var attrDic: [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        var attrString: NSMutableAttributedString?
        attrs.forEach({ attr in
            switch attr {
            case .all(let attributedString):
                attrString = NSMutableAttributedString(attributedString: attributedString)
            case .alignment(let alignment):
                paragraphStyle.alignment = alignment
            case .font(let font):
                attrDic[NSAttributedString.Key.font] = font
            case .textColor(let color):
                attrDic[NSAttributedString.Key.foregroundColor] = color
            }
        })
        return attrString ?? NSMutableAttributedString(string: text ?? kNotfoundTextIdentifier, attributes: attrDic)
    }
    
}

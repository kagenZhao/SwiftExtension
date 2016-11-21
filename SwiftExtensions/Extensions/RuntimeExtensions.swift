//
//  RuntimeExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/15.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public func runtimeExchange(class: AnyClass, from: Selector, to: Selector) {
    
        let m1 = class_getInstanceMethod(`class`, from)
        
        let m2 = class_getInstanceMethod(`class`, to)
        
        method_exchangeImplementations(m1, m2)
}

public func runtimeExchange(class: AnyClass, selectors: [(from: Selector, to: Selector)]) {
    
    for (from, to) in selectors {
        
        let m1 = class_getInstanceMethod(`class`, from)
        
        let m2 = class_getInstanceMethod(`class`, to)
        
        method_exchangeImplementations(m1, m2)
    }
}

public func runtimeSetAssociated(_ object: Any!, _ key: UnsafeRawPointer!, _ value: Any!, _ policy: objc_AssociationPolicy) {
    objc_setAssociatedObject(object, key, value, policy)
}

public func runtimeGetAssociated(_ object: Any!, _ key: UnsafeRawPointer!) -> Any! {
    return objc_getAssociatedObject(object, key)
}

public func runtimeRemoveAssociated(_ object: Any!, _ key: UnsafeRawPointer!) {
    objc_setAssociatedObject(object, key, nil, .OBJC_ASSOCIATION_ASSIGN)
}

public func runtimeRemoveAllAssociated(_ object: Any!) {
    objc_removeAssociatedObjects(object)
}


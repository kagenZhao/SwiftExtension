//
//  RuntimeExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/15.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public struct Runtime {
    private init() {}
}

// MARK: - Association
extension Runtime {
    public struct Association {
        private init() {}
        
        public enum Policy {
            
            case assign
            
            case retain(AtomicType)
            
            case copy(AtomicType)
            
            var value: objc_AssociationPolicy {
                
                switch self {
                    
                case .assign:
                    
                    return .OBJC_ASSOCIATION_ASSIGN
                    
                case .copy(let atomicType):
                    
                    if atomicType == .atomic {
                        
                        return .OBJC_ASSOCIATION_COPY
                        
                    } else {
                        
                        return .OBJC_ASSOCIATION_COPY_NONATOMIC
                    }
                    
                case .retain(let atomicType):
                    
                    if atomicType == .atomic {
                        
                        return .OBJC_ASSOCIATION_RETAIN
                        
                    } else {
                        
                        return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    }
                }
            }
        }
        
        public enum AtomicType {
            
            case nonatomic
            
            case atomic
        }
        
        public static func set(value: Any, for key: UnsafeRawPointer, type: Policy, to objc: Any)  {
            
            objc_setAssociatedObject(objc, key, value, type.value)
        }
        
        public static func value<Value>(for key: UnsafeRawPointer, from objc: Any) -> Value? {
            
            return objc_getAssociatedObject(objc, key) as? Value
        }
    }
}


// MARK: - Swizzing
extension Runtime {
    
    public struct Swizzing {
        private init() {}
        
        public enum ExchangeMethodType {
            case instance
            case `class`
            
            fileprivate func description() -> String {
                if self == .instance { return "Instance" }
                else { return "Class" }
            }
        }
        
        public static func exchange(class: AnyClass, fromSEL: Selector, toSEL: Selector, type: ExchangeMethodType = .instance) {
            var oMethod: Method!
            var sMethod: Method!
            
            switch type {
            case .instance:
                oMethod = class_getInstanceMethod(`class`, fromSEL)
                sMethod = class_getInstanceMethod(`class`, toSEL)
            case .class:
                oMethod = class_getClassMethod(`class`, fromSEL)
                sMethod = class_getClassMethod(`class`, toSEL)
            }
            
            guard let originMethod = oMethod else {
                fatalError("Notfound the \(type.description()) selector: \(NSStringFromSelector(fromSEL)) in class: \(`class`)")
            }
            
            guard let swizzingMethod = sMethod else {
                fatalError("Notfound the \(type.description()) selector: \(NSStringFromSelector(toSEL)) in class: \(`class`)")
            }
            
            let didAddMethod = class_addMethod(`class`, fromSEL, method_getImplementation(swizzingMethod), method_getTypeEncoding(swizzingMethod))
            
            if didAddMethod {
                
                class_replaceMethod(`class`, toSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
                
            } else {
                
                method_exchangeImplementations(originMethod, swizzingMethod)
            }
        }
    }
}

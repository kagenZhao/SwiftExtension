//
//  RuntimeExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/15.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public struct Runtime {
    
    public struct Association {
        
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
    
    public struct Swizzing {
        
        public static func exchange(class: AnyClass, fromSEL: Selector, toSEL: Selector) {
            
            var oMethod: Method?
            
            var sMethod: Method?
            
            if let originInstanceMethod = class_getInstanceMethod(`class`, fromSEL), let swizzingInstanceMethod = class_getInstanceMethod(`class`, toSEL) {
                
                oMethod = originInstanceMethod
                
                sMethod = swizzingInstanceMethod
                
            } else if let originClassMethod = class_getClassMethod(`class`, fromSEL), let swizzingClassMethod = class_getClassMethod(`class`, toSEL) {
                
                oMethod = originClassMethod
                
                sMethod = swizzingClassMethod
                
            } else {
                
                oMethod = nil
                
                sMethod = nil
            }
            
            guard let originMethod = oMethod, let swizzingMethod = sMethod else { return }
            
            let didAddMethod = class_addMethod(`class`, fromSEL, method_getImplementation(swizzingMethod), method_getTypeEncoding(swizzingMethod))
            
            if didAddMethod {
                
                class_replaceMethod(`class`, toSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
                
            } else {
                
                method_exchangeImplementations(originMethod, swizzingMethod)
            }
        }
    }
}


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
        
        public enum MethodType {
            case instance
            case `class`
            
            fileprivate func description() -> String {
                if self == .instance { return "Instance" }
                else { return "Class" }
            }
        }
        
        public static func exchange(class: AnyClass, fromSEL: Selector, toSEL: Selector, type: MethodType = .instance) {
            let oMethod: Method! = method(from: `class`, sel: fromSEL, type: type)
            let sMethod: Method! = method(from: `class`, sel: toSEL, type: type)
            
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
        
        
        public static func resetMethod<ReturnType>(_ class: AnyClass, selector: Selector, type: MethodType = .instance, in block: @escaping ([Any]) -> ReturnType) {
            let oldMethod: Method! = method(from: `class`, sel: selector, type: type)
            let argCount = method_getNumberOfArguments(oldMethod!) - 2 // 减去 obj  和  selector
            var imp: IMP?
            switch argCount {
            case 0:
                let newFunc:@convention(block) (AnyClass) -> Any = {
                    (sself) in
                    return block([])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 1:
                let newFunc:@convention(block) (AnyClass, Any) -> Any = {
                    (sself, arg) in
                    return block([arg])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 2:
                let newFunc:@convention(block) (AnyClass, Any, Any) -> Any = {
                    (sself, arg1, arg2) in
                    return block([arg1, arg2])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 3:
                let newFunc:@convention(block) (AnyClass, Any, Any, Any) -> Any = {
                    (sself, arg1, arg2, arg3) in
                    return block([arg1, arg2, arg3])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 4:
                let newFunc:@convention(block) (AnyClass, Any, Any, Any, Any) -> Any = {
                    (sself, arg1, arg2, arg3, arg4) in
                    return block([arg1, arg2, arg3, arg4])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 5:
                let newFunc:@convention(block) (AnyClass, Any, Any, Any, Any, Any) -> Any = {
                    (sself, arg1, arg2, arg3, arg4, arg5) in
                    return block([arg1, arg2, arg3, arg4, arg5])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 6:
                let newFunc:@convention(block) (AnyClass, Any, Any, Any, Any, Any, Any) -> Any = {
                    (sself, arg1, arg2, arg3, arg4, arg5, arg6) in
                    return block([arg1, arg2, arg3, arg4, arg5, arg6])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 7:
                let newFunc:@convention(block) (AnyClass, Any, Any, Any, Any, Any, Any, Any) -> Any = {
                    (sself, arg1, arg2, arg3, arg4, arg5, arg6, arg7) in
                    return block([arg1, arg2, arg3, arg4, arg5, arg6, arg7])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 8:
                let newFunc:@convention(block) (AnyClass, Any, Any, Any, Any, Any, Any, Any, Any) -> Any = {
                    (sself, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) in
                    return block([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            case 9:
                let newFunc:@convention(block) (AnyClass, Any, Any, Any, Any, Any, Any, Any, Any, Any) -> Any = {
                    (sself, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) in
                    return block([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9])
                }
                imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
            default:
                fatalError("暂时不支持这么多参数")
            }
            method_setImplementation(oldMethod!, imp!)
        }
        
        
        private static func method(from class: AnyClass, sel: Selector, type: MethodType = .instance) -> Method! {
            switch type {
            case .instance:
                return class_getInstanceMethod(`class`, sel)
            case .class:
                return class_getClassMethod(`class`, sel)
            }
        }
    }
}


//extension UITextField {
//    public func setupNumberKeyboard(min: Int, max: Int) {
//
//        let method = class_getInstanceMethod(UITextField.self, #selector(_numberTextDidChange(_:)))
//        let oldImp = method_getImplementation(method!)
//        //由于IMP是函数指针，所以接收时需要指定@convention(c)
//        typealias Imp  = @convention(c) (UITextField,Selector,UITextField)->Void
//        //将函数指针强转为兼容函数指针的闭包
//        let oldImpBlock = unsafeBitCast(oldImp!, to: Imp.self)
//
//        //imp_implementationWithBlock的参数需要的是一个oc的block，所以需要指定convention(block)
//        let newFunc:@convention(block) (UITextField, UITextField) -> Void = {
//            (sself,  arg) in
//            print("数之前， 祝大家新年快乐")
//            //            oldImpBlock(sself, #selector(Person.countNumber(toValue:)), toValue)
//            print("数之后， 祝大家新年快乐")
//        }
//        let imp = imp_implementationWithBlock(unsafeBitCast(newFunc, to: AnyObject.self))
//        method_setImplementation(method!, imp)
//        self.addTarget(self, action: #selector(_numberTextDidChange(_:)), for: .editingChanged)
//    }
//
//    @objc dynamic private func _numberTextDidChange(_ sender: UITextField) {}
//}




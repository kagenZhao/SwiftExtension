//
//  UIViewControllerExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/21.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit


extension UIViewController {
    
    public static var root: UIViewController {
        
        guard let root = UIApplication.shared.windows[0].rootViewController else {
            
            fatalError("app has no root view controller")
        }
        return root
    }
    
    public static var top: UIViewController {
        
        return root.topPersent
    }
    
    public var topPersent: UIViewController {
        
        var vc = self
        
        if vc.isKind(of: UINavigationController.self) {
            
            if let top = (vc as! UINavigationController).topViewController {
                
                vc = top
            }
        }
        
        while vc.presentedViewController != nil {
            
            vc = vc.presentedViewController!
        }
        
        if vc.presentedViewController == nil && !type(of: vc).isSubclass(of: UINavigationController.self) {
            
           return vc
            
        } else {
            
            return vc.topPersent
        }
    }
}

extension UIView {
    
    public var parentVC: UIViewController? {
        
        var view = self
        
        var responder: UIResponder?
        
        while view.superview != nil {
            
            view = view.superview!
            
            responder = view.next
            
            if responder != nil, responder!.isKind(of: UIViewController.self) {
                
                break
            }
        }
        return responder as? UIViewController
    }
}

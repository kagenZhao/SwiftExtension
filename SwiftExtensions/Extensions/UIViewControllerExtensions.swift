
//  UIViewControllerExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/21.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit
import SwiftTryCatch

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
        
        if NSObject.isKind(of: UINavigationController.self) {
            
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
            
            if responder != nil, NSObject.isKind(of: UIViewController.self) {
                
                break
            }
        }
        return responder as? UIViewController
    }
}


private  var _viewControllersStoryboardCache: NSCache<NSString, NSString> = { return  NSCache<NSString, NSString>() }()
private  var _viewControllersStoryboardList: [String] = {
    let tempArr = Bundle.main.paths(forResourcesOfType: "storyboardc", inDirectory: nil)
    return tempArr.map({ (($0 as NSString).lastPathComponent as NSString).deletingPathExtension }).filter({ $0.range(of: "~") == nil })
}()

// MARK: - 查找storyboard中的对应类的实例
extension UIViewController {
    
    private static var cache: NSCache<NSString, NSString> { return _viewControllersStoryboardCache }
    private static var storyboardList: [String] { return _viewControllersStoryboardList }
    
    /// 在项目文件中寻找对应当前类的 controller 实例并返回
    ///     对查找过的storyboard做了缓存处理, 二次查找不消耗性能
    ///
    /// - Returns: 返回实例
    public static func instanceFromStoryboard() -> Self? {
        let controllerName = NSStringFromClass(self).components(separatedBy: ".").last!
        if let storyboardName = cache.object(forKey: controllerName as NSString) {
            guard storyboardName.length > 0 else { return nil }
            return _instanceFromStoryboard(storyboardName: storyboardName as String, identifier: controllerName)
        } else {
            return _instanceFormCacheStoryBoardList(identifier: controllerName)
        }
    }
    
    private static func _instanceFormCacheStoryBoardList<T: UIViewController>(identifier: String) -> T? {
        for name in storyboardList {
            if let vc = _instanceFromStoryboard(storyboardName: name, identifier: identifier) {
                cache.setObject(name as NSString, forKey: identifier as NSString)
                return vc as? T
            }
        }
        cache.setObject("", forKey: identifier as NSString)
        return nil
    }
    
    private static func _instanceFromStoryboard<T: UIViewController>(storyboardName: String, identifier: String) -> T? {
        var vc: T? = nil
        SwiftTryCatch.try({ 
            let storyBoard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
            vc = storyBoard.instantiateViewController(withIdentifier: identifier) as? T
        }, catch: { _ in
            vc = nil
        }) {}
        return vc
    }
}

extension UIViewController {
    /// 寻找第一个不是navigation / tabbar的controller
    /// 用于展示一些自定义View 弹窗, 能覆盖除了Navigation 和 Tabbar 的其他所有部分
    func findContentViewController() -> UIViewController {
        if parent == nil {
            return self
        } else if parent! is UINavigationController {
            return self
        } else if parent! is UITabBarController {
            return self
        } else {
            return parent!.findContentViewController()
        }
    }
}


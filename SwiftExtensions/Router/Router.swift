//
//  Router.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2017/4/30.
//  Copyright © 2017年 Kagen Zhao. All rights reserved.
//

import UIKit

public enum ControllerType {
    case instance(UIViewController)
    case instanceClass(RouterViewControllerInstantiation.Type)
    case name(String)
}

extension ControllerType: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .name(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .name(value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .name(value)
    }
}

public enum Navigated {
    case controller(ControllerType, args: [String: Any]?)
    
    /// 全路由
    /// args 中如果某个页面不需要传参数 则传空字典
    /// 如: [[:], [key1:value1, key2:value2], [:]]
    case url([ControllerType], args: [[String: Any]]?, forceBackFirstPage: Bool)
}

public enum SameControllerType {
    case allowRpeat
    case notRepeat(needSetArgs: Bool)
    case replace
}


public protocol RouterViewControllerInstantiation {
    
    /// 使用着在特殊情况下要自行实现这个协议, 默认实现方法只是单纯的创建一个vc
    ///
    /// - Returns: 返回实例
    static func instantiateViewController() -> UIViewController
}

extension UIViewController: RouterViewControllerInstantiation {
    
    /// RouterViewControllerInstantiation默认实现方法
    ///     这个方法会先去寻找这个vc是不是storyboard里的, 如果是就从storyboard里实例化一个vc, 否则直接创建一个vc
    ///
    /// - Returns: 返回一个新创建的vc
    public static func instantiateViewController() -> UIViewController {
        return self.instanceFromStoryboard() ?? self.init(nibName: nil, bundle: nil)
    }
}

extension Router {
    
    public static let shared: Router = Router(controller: NotExistViewController(pageName:"RootViewController"))
    
    /// 初始化方法
    /// 必须在app启动时调用的方法
    ///
    /// - Parameter rootController: 作为首页的controller
    public func setup(rootController: ControllerType) {
        let delegate = UIApplication.shared.delegate! as AnyObject
        let controller = instantiateViewController(from: rootController, args: nil)
        var window = UIWindow(frame: UIScreen.main.bounds)
        if let oldWindow = delegate.value(forKey: "window") as? UIWindow {
            window = oldWindow
        } else {
            delegate.setValue(window, forKey: "window")
        }
        self.rootController = UINavigationController(rootViewController: controller)
        window.rootViewController = self.rootController
        window.makeKeyAndVisible()
    }
}

public class Router {
    fileprivate(set) var rootController: UINavigationController
    fileprivate init(controller: UIViewController) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        rootController = UINavigationController(rootViewController: controller)
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
}

public extension Router {
    /// Navigate
    ///
    /// - Parameters:
    ///   - to: push的controller
    ///             可以是单个控制器, 也可以是多个控制器的数组
    ///             如果为多个控制器的数组, 要求控制器个数必须等于nil或者等于参数的个数; 若某个界面不需要参数则穿空字典  如: [[:], [key1:value1, key2:value2], [:]]; 若某个参数需要置空 则用NSNull()代替
    ///             多个控制器时 参数 forceBackFirstPage 的意义是: 是否退回到与数组第一个控制器相同的控制器后 再push接下来的页面, 如果栈内没有与其相同的控制器, 则直接按顺序向后push
    ///             多个控制器时 只保留最后一次跳转动画,  前边的跳转动画关闭
    ///   - animated: 是否有动画
    ///   - sameControllerType: 是否允许第一个界面的重复
    ///            notRepeat: 第一个界面与当前页面class相同 不操作
    ///            canRepeat: 第一个界面与当前页面class相同 继续push相同的class,
    ///            replace: 第一个界面与当前页面class相同 先pop 再push, 如果不能pop, 则直接替换(没有动画)
    func navigate(to: Navigated, animated: Bool = true, sameControllerType: SameControllerType = .notRepeat(needSetArgs: false)) {
        if case let .controller(type, args: args) = to {
            return navigate(to: type, args: args, animated: animated, sameControllerType: sameControllerType)
        }
        /// TODO  还需要url方式
        if case let .url(controllers, args, needdForceFirstPage) = to {
            guard controllers.count >= 0 else { return };
            
            var newControllers = [UIViewController]()
            
            /// 初始化controller并设置参数
            if args != nil && !args!.isEmpty {
                if args!.count != controllers.count {
                    newControllers = zip(controllers, args!).map({ self.instantiateViewController(from: $0.0, args: $0.1) })
                } else {
                    fatalError("参数的个数与控制器个数不相等")
                }
            } else {
                newControllers = controllers.map({ self.instantiateViewController(from: $0, args: nil) })
            }
            
            /// 根据 needdForceFirstPage 做处理, 退回相应界面
            if needdForceFirstPage {
                let firstController = newControllers.first!
                if let idx = rootController.viewControllers.reversed().firstIndex(where: { (c) -> Bool in
                    type(of: c) == type(of: firstController)
                }) {
                    let backToController = rootController.viewControllers.reversed()[idx]
                    rootController.popToViewController(backToController, animated: false)
                    if case let .notRepeat(needSetArgs) = sameControllerType {
                        if needSetArgs {
                            setup(controller: backToController, with: args != nil ? (args!.isEmpty ? nil : args![0]) : nil)
                        }
                        newControllers.removeFirst()
                        newControllers.insert(backToController, at: 0)
                    } else if case .replace = sameControllerType {
                        if rootController.viewControllers.count > 1 {
                            newControllers.insert(contentsOf: rootController.viewControllers.dropLast(), at: 0)
                            rootController.popViewController(animated: false)
                        }
                    }
                }
            } else {
                newControllers.insert(contentsOf: rootController.viewControllers, at: 0)
            }
            rootController.setViewControllers(newControllers, animated: animated)
        }
    }
    
    // 单个控制器
    func navigate(to: ControllerType, args: [String: Any]?, animated: Bool = true, sameControllerType: SameControllerType = .notRepeat(needSetArgs: false)) {
        let controller = instantiateViewController(from: to, args: args)
        var emptyFlag = false
        if let topController = rootController.topViewController {
            if NSStringFromClass(type(of:topController)) ==  NSStringFromClass(type(of:controller)) {
                if case let .notRepeat(needSetArgs) = sameControllerType {
                    if needSetArgs {
                        setup(controller: topController, with: args)
                    }
                    return
                } else if case .replace = sameControllerType {
                    if rootController.viewControllers.count == 1 {
                        controller.navigationItem.hidesBackButton = true
                        rootController.setViewControllers([controller], animated: animated)
                        emptyFlag = true
                    } else {
                        rootController.popViewController(animated: false)
                    }
                }
            }
        }
        if !emptyFlag {
            rootController.pushViewController(controller, animated: animated)
        }
    }
    
    func instantiateViewController(from: ControllerType, args: [String: Any]?) -> UIViewController {
        var controller: UIViewController!
        switch from {
        case .instance(let viewController):
            controller = viewController
        case .instanceClass(let classType):
            controller = classType.instantiateViewController()
        case .name(let name):
            controller = instantiateViewController(from: name)
        }
        setup(controller: controller, with: args)
        return controller
    }
    
    fileprivate func instantiateViewController(from: String) -> UIViewController {
        if let cls = NSClassFromString(from) as? RouterViewControllerInstantiation.Type {
            return cls.instantiateViewController()
        } else if let cls = NSClassFromString(appName() + "." + from) as? RouterViewControllerInstantiation.Type {
            return cls.instantiateViewController()
        } else {
            return NotExistViewController(pageName:from)
        }
    }
    
    
    fileprivate func setup(controller: UIViewController?, with args: [String: Any]?) {
        guard let controller = controller else { return }
        guard args != nil && args!.count > 0 else { return }
        var count: UInt32 = 0;
        let properList = class_copyPropertyList(controller.classForCoder, &count)
        for i in 0..<count {
            let property = properList!.advanced(by: Int(i)).pointee
            let propertyName = property_getName(property)
            if let fixName = String.init(utf8String: propertyName), let arg = args?[fixName] {
                if type(of: arg) == NSNull.self {
                    controller.setValue(nil, forKey: fixName)
                } else {
                    controller.setValue(arg, forKey: fixName)
                }
            }
        }
    }
    
    fileprivate func match(_ type1: ControllerType, _ type2: ControllerType) -> Bool {
        
        func classString(from type: ControllerType) -> String? {
            switch type {
            case .instance(let vc):
                return NSStringFromClass(Swift.type(of: vc))
            case .instanceClass(let classType):
                return NSStringFromClass(Swift.type(of: classType.instantiateViewController()))
            case .name(let name):
                let c1 = NSClassFromString(name) != nil
                let c2 = NSClassFromString(appName() + "." + name) != nil
                return  c1 ? name : (c2 ? (appName() + "." + name) : nil)
            }
        }
        
        let vc1 = classString(from: type1)
        let vc2 = classString(from: type2)
        return vc1 != nil && vc2 != nil && vc1! == vc2!
    }
    
    
    fileprivate func appName() -> String {
        return Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
    }
}

extension Router {
    public func goBack(tolast controller:ControllerType? = nil, with args: [String: Any]? = nil, animated: Bool = true) {
        _goback(controller: controller, with: args, animated: animated, reversed: true)
    }
    
    public func goBack(tofirst controller:ControllerType?, with args: [String: Any]? = nil, animated: Bool = true) {
        _goback(controller: controller, with: args, animated: animated, reversed: false)
    }
    
    private func _goback(controller:ControllerType?, with args: [String: Any]?, animated: Bool, reversed: Bool) {
        if let controllerType = controller{
            let viewControllers = reversed ? rootController.viewControllers.reversed() : rootController.viewControllers
            if let idx = viewControllers.firstIndex(where: { match( .instance($0), controllerType) }) {
                rootController.popToViewController(viewControllers[idx], animated: animated)
            } else {
                return
            }
        } else {
            rootController.popViewController(animated: animated)
        }
        setup(controller: rootController.topViewController, with: args)
    }
}









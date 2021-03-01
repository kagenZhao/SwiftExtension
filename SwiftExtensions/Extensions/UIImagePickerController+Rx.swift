//
//  UIImagePickerController+Rx.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/7/30.
//  Copyright © 2019 kagen. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

public typealias UIImagePickerAndNavigationDelegate = (UIImagePickerControllerDelegate & UINavigationControllerDelegate)

//图片选择控制器（UIImagePickerController）代理委托
public class RxImagePickerDelegateProxy :
    DelegateProxy<UIImagePickerController, UIImagePickerAndNavigationDelegate>,
    DelegateProxyType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public init(imagePicker: UIImagePickerController) {
        super.init(parentObject: imagePicker,
                   delegateProxy: RxImagePickerDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxImagePickerDelegateProxy(imagePicker: $0) }
    }
    
    public static func currentDelegate(for object: UIImagePickerController) -> UIImagePickerAndNavigationDelegate? {
            return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: UIImagePickerAndNavigationDelegate?, to object: UIImagePickerController) {
        object.delegate = delegate
    }
}

extension Reactive where Base: UIImagePickerController {
    //代理委托
    public var pickerDelegate: DelegateProxy<UIImagePickerController, UIImagePickerAndNavigationDelegate> {
        return RxImagePickerDelegateProxy.proxy(for: base)
    }
    
    //图片选择完毕代理方法的封装
    public var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey : Any]> {
        
        return pickerDelegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map({ (a) in
                return try castOrThrow(Dictionary<UIImagePickerController.InfoKey, Any>.self, a[1])
            })
    }
    
    //图片取消选择代理方法的封装
    public var didCancel: Observable<()> {
        return pickerDelegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map {_ in () }
    }
    
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}


// 取消指定视图控制器函数
private func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        return
    }
    
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

//对UIImagePickerController进行Rx扩展
extension Reactive where Base: UIImagePickerController {
    //用于创建并自动显示图片选择控制器的静态方法
    static func createWithParent(_ parent: UIViewController?,
                                 animated: Bool = true,
                                 configureImagePicker: @escaping (UIImagePickerController) throws -> () = { x in })
        -> Observable<UIImagePickerController> {
            
            //返回可观察序列
            return Observable.create { [weak parent] observer in
                
                //初始化一个图片选择控制器
                let imagePicker = UIImagePickerController()
                imagePicker.modalPresentationStyle = .fullScreen
                //不管图片选择完毕还是取消选择，都会发出.completed事件
                let dismissDisposable = Observable.merge(
                    imagePicker.rx.didFinishPickingMediaWithInfo.map{_ in ()},
                    imagePicker.rx.didCancel
                    )
                    .subscribe(onNext: {  _ in
                        observer.on(.completed)
                    })
                
                //设置图片选择控制器初始参数，参数不正确则发出.error事件
                do {
                    try configureImagePicker(imagePicker)
                }
                catch let error {
                    observer.on(.error(error))
                    return Disposables.create()
                }
                
                //判断parent是否存在，不存在则发出.completed事件
                guard let parent = parent else {
                    observer.on(.completed)
                    return Disposables.create()
                }
                
                //弹出控制器，显示界面
                parent.present(imagePicker, animated: animated, completion: nil)
                //发出.next事件（携带的是控制器对象）
                observer.on(.next(imagePicker))
                
                //销毁时自动退出图片控制器
                return Disposables.create(dismissDisposable, Disposables.create {
                    dismissViewController(imagePicker, animated: animated)
                })
            }
    }
}

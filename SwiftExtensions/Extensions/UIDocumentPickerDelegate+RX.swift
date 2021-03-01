//
//  UIDocumentPickerDelegate+RX.swift
//  wmIOS
//
//  Created by Kagen Zhao on 2020/10/26.
//  Copyright © 2020 kagen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa



public class RxDocumentPickerDelegateProxy:
    DelegateProxy<UIDocumentPickerViewController, UIDocumentPickerDelegate>,
    DelegateProxyType, UIDocumentPickerDelegate {
    public init(documentPicker: UIDocumentPickerViewController) {
        super.init(parentObject: documentPicker, delegateProxy: RxDocumentPickerDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxDocumentPickerDelegateProxy(documentPicker: $0) }
    }
    
    public static func currentDelegate(for object: UIDocumentPickerViewController) -> UIDocumentPickerDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: UIDocumentPickerDelegate?, to object: UIDocumentPickerViewController) {
        object.delegate = delegate
    }
}


extension Reactive where Base: UIDocumentPickerViewController {
    public var pickerDelegate: DelegateProxy<UIDocumentPickerViewController, UIDocumentPickerDelegate> {
        return RxDocumentPickerDelegateProxy.proxy(for: base)
    }
    
    public var didPickDocumentsAtURLs: Observable<[URL]> {
        if #available(iOS 11.0, *) {
            return pickerDelegate
                .methodInvoked(#selector(UIDocumentPickerDelegate.documentPicker(_:didPickDocumentsAt:)))
                .map({ a in
                    return try castOrThrow([URL].self, a[1])
                })
        } else {
            return pickerDelegate
                .methodInvoked(#selector(UIDocumentPickerDelegate.documentPicker(_:didPickDocumentAt:)))
                .map({ a in
                    let value = try castOrThrow(URL.self, a[1])
                    return [value]
                })
        }
    }
    
    public var didCancel: Observable<()> {
        return pickerDelegate
            .methodInvoked(#selector(UIDocumentPickerDelegate.documentPickerWasCancelled(_:)))
            .map({ _ in () })
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


extension Reactive where Base: UIDocumentPickerViewController {
    static func createWithParent(_ parent: UIViewController?,
                                 animated: Bool = true,
                                 configureDocumentPicker: @escaping () throws -> (UIDocumentPickerViewController)) -> Observable<UIDocumentPickerViewController> {
        
        return .create { (observer) -> Disposable in
            do {
                let documentPicker = try configureDocumentPicker()
                
                let dismissDisposable = Observable.merge(
                    documentPicker.rx.didPickDocumentsAtURLs.map({ _ in () }),
                    documentPicker.rx.didCancel
                )
                .subscribe(onNext: { _ in
                    observer.on(.completed)
                })
                
                guard let parent = parent else {
                    observer.on(.completed)
                    return Disposables.create()
                }
                
                parent.present(documentPicker, animated: animated, completion: nil)
                observer.on(.next(documentPicker))
                return Disposables.create(dismissDisposable, Disposables.create {
                    dismissViewController(documentPicker, animated: animated)
                })
            } catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }
        }
    }
}

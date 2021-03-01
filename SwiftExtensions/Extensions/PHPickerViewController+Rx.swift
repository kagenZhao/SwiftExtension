//
//  PHPickerViewController+Rx.swift
//  wmIOS
//
//  Created by Kagen Zhao on 2020/10/30.
//  Copyright © 2020 kagen. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import RxSwift
import RxCocoa

@available(iOS 14, *)
public class RxPhotoPickerViewDelegateProxy:
    DelegateProxy<PHPickerViewController, PHPickerViewControllerDelegate>,
    DelegateProxyType, PHPickerViewControllerDelegate {
    
    fileprivate let observer = PublishSubject<[PHPickerResult]>.init()
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        observer.onNext(results)
    }
    
    public init(photoPicker: PHPickerViewController) {
        super.init(parentObject: photoPicker, delegateProxy: RxPhotoPickerViewDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxPhotoPickerViewDelegateProxy(photoPicker: $0) }
    }
    
    public static func currentDelegate(for object: PHPickerViewController) -> PHPickerViewControllerDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: PHPickerViewControllerDelegate?, to object: PHPickerViewController) {
        object.delegate = delegate
    }
    
}

@available(iOS 14, *)
extension Reactive where Base: PHPickerViewController {
    public var pickerDelegate: RxPhotoPickerViewDelegateProxy {
        return RxPhotoPickerViewDelegateProxy.proxy(for: base)
    }
    
    public var didFinishPicking: Observable<[PHPickerResult]> {
        return pickerDelegate.observer
    }
}
private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}

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

@available(iOS 14, *)
extension Reactive where Base: PHPickerViewController {
    static func createWithParent(_ parent: UIViewController?,
                                 animated: Bool = true,
                                 configure: PHPickerConfiguration)
        -> Observable<PHPickerViewController> {
            
            return Observable.create { [weak parent] observer in
                let imagePicker = PHPickerViewController(configuration: configure)
                imagePicker.modalPresentationStyle = .fullScreen
                let dismissDisposable = imagePicker.rx.didFinishPicking
                    .subscribe(onNext: {  _ in
                        observer.on(.completed)
                    })
                
                guard let parent = parent else {
                    observer.on(.completed)
                    return Disposables.create()
                }
                parent.present(imagePicker, animated: animated, completion: nil)
                observer.on(.next(imagePicker))
                return Disposables.create(dismissDisposable, Disposables.create {
                    dismissViewController(imagePicker, animated: animated)
                })
            }
    }
}


//
//  ReactiveCocoa+DXRx.swift
//  esanalyst
//
//  Created by 赵国庆 on 2017/6/7.
//  Copyright © 2017年 kagen. All rights reserved.
//
import UIKit
import ReactiveCocoa
import RxSwift
import RxCocoa

public extension RACSignal {
    func bind<T, O: ObserverType>(to observer: O) -> O where O.E == T {
        subscribeNext({ (x) in
            guard let value = transfor(from: x, to: T.self) else { return }
            observer.onNext(value)
        }, error: { (e) in
            observer.onError(e ?? NSError(domain: "RACSignal send error with no message", code: -1, userInfo: nil))
        }) {
            observer.onCompleted()
        }
        return observer
    }
    
    func bind<T, O: ObserverType>(to observer: O) -> O where O.E == T? {
        subscribeNext({ (x) in
            observer.onNext(transfor(from: x, to: T.self))
        }, error: { (e) in
            observer.onError(e ?? NSError(domain: "RACSignal send error with no message", code: -1, userInfo: nil))
        }) {
            observer.onCompleted()
        }
        return observer
    }
    
    func bind<T>(to variable: Variable<T>) -> Disposable {
        let dp = subscribeNext({ (x) in
                guard let value = transfor(from: x, to: T.self) else { return }
                variable.value = (value)
            }, error: { (e) in
                print("RACSignal send error to RxSwift_Variable:" + "\(e.debugDescription)")
            }) {}
        let dispose = Disposables.create {
            dp?.dispose()
        }
        return dispose
    }
    
    func bind<T>(to variable: Variable<T?>) -> Disposable {
        let dp = subscribeNext({ (x) in
                variable.value = (transfor(from: x, to: T.self))
            }, error: { (e) in
                print("RACSignal send error to RxSwift_Variable:" + "\(e.debugDescription)")
            }) {}
        let dispose = Disposables.create {
            dp?.dispose()
        }
        return dispose
    }
}

public extension RACSignal {
    func brige<T>() -> Observable<T> {
        return Observable<T>.create {[unowned self] (observer) -> Disposable in
            self.subscribeNext({ (x) in
                guard let value = transfor(from: x, to: T.self) else { return }
                observer.onNext(value)
            }, error: { (e) in
                observer.onError(e ?? NSError(domain: "RACSignal send error with no message", code: -1, userInfo: nil))
            }) {
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func brige<T>() -> Observable<T?> {
        return Observable<T?>.create {[unowned self] (observer) -> Disposable in
            self.subscribeNext({ (x) in
                observer.onNext(transfor(from: x, to: T.self))
            }, error: { (e) in
                observer.onError(e ?? NSError(domain: "RACSignal send error with no message", code: -1, userInfo: nil))
            }) {
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

private func transfor<T>(from: Any?, to: T.Type) -> T? {
    guard let from = from else { return nil }
    if from is T { return from as? T }
    if from is NSValue {
        let value = from as! NSValue
        print("Transfor <NSValue: \(from)> -> <\(to)>")
        var type: T? = nil
        value.getValue(&type)
        return type
    } else {
        print("can not find class: \(from) to matching class: \(to)")
        return nil
    }
}


//
//  CADisplayLink+Rx.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/7/8.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension CADisplayLink {
    public static let maximumFps = 60
}

extension Reactive where Base: CADisplayLink {
    public static func link(to runloop: RunLoop = .main, forMode mode: RunLoop.Mode = .common, fps: Int = Base.maximumFps) -> Observable<CADisplayLink> {
        return RxDisplayLink(to: runloop, forMode: mode, fps: fps).asObservable()
    }
}

public final class RxDisplayLink: ObservableType {
    public typealias Element = CADisplayLink
    private let runloop: RunLoop
    private let mode: RunLoop.Mode
    private let fps: Int
    private var observer: AnyObserver<CADisplayLink>?
    
    @objc dynamic private func displayLinkHandler(link: CADisplayLink) {
        observer?.onNext(link)
    }
    
    public init(to runloop: RunLoop, forMode mode: RunLoop.Mode, fps: Int) {
        self.runloop = runloop
        self.mode = mode
        self.fps = fps
    }
    
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == CADisplayLink {
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(displayLinkHandler))
        displayLink?.add(to: runloop, forMode: mode)
        if #available(iOS 10.0, tvOS 10.0, *) {
            displayLink?.preferredFramesPerSecond = fps
        } else {
            displayLink?.frameInterval = max(CADisplayLink.maximumFps / fps, 1)
        }
        
        self.observer = AnyObserver<CADisplayLink>(observer)
        
        return Disposables.create {
            self.observer = nil
            displayLink?.invalidate()
            displayLink = nil
        }
    }
}

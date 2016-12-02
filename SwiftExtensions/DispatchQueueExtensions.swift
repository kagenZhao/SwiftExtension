//
//  DispatchQueueExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/9/7.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation

// MARK: - Div
public extension DispatchQueue {
    
    public static var userInteractive: DispatchQueue { return DispatchQueue.global(qos: .userInteractive) }
    
    public static var userInitiated: DispatchQueue { return DispatchQueue.global(qos: .userInitiated) }
    
    public static var utility: DispatchQueue { return DispatchQueue.global(qos: .utility) }
    
    public static var background: DispatchQueue { return DispatchQueue.global(qos: .background) }
    
    private static var _tokens: Set<UnsafeRawPointer> = []
    
    
    /// 替代 OC-DispatchOnce
    /// 之所以不用String作为identifier, 个人认为也许在多人开发中 会无意间用到同一个字符串, 用 pointer 比较保险
    /// - Parameters:
    ///   - token: identifier
    ///   - closure: execute
    public class func once(_ token: UnsafeRawPointer, execute closure: (() -> ())) {
        
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        guard !_tokens.contains(token) else { return }
        
        _tokens.insert(token)
        
        closure()
    }

    
    public func after(delay: TimeInterval, execute closure: @escaping () -> ()) {
        
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
    
    public func timer(flags: DispatchSource.TimerFlags = [],
                      deadline: DispatchTime = .now(),
                      interval: DispatchTimeInterval,
                      leeway: DispatchTimeInterval = .milliseconds(1),
                      repeat: Bool = true, handler: @escaping @convention(block) () -> ()) -> DispatchSourceTimer {
        
        let timer = DispatchSource.makeTimerSource(flags: flags, queue: self)
        
        timer.setEventHandler(handler: handler)
        
        if `repeat` {
            
            timer.scheduleRepeating(deadline: deadline, interval: interval, leeway: leeway)
        } else {
            
            timer.scheduleOneshot(deadline: deadline, leeway: leeway)
        }
        
        return timer
    }
}


/// 给resume 和 cancel 起个别名 便于 阅读
public extension DispatchSourceTimer {
    
    public func start() {
        self.resume()
    }
    
    public func stop() {
        self.cancel()
    }
}

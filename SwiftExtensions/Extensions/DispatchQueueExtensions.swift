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
    
    private static var _onceTracker_token = [UnsafeRawPointer]()
    
    private static var _onceTracker_keys = [String]()
    
    public class func once(token: UnsafeRawPointer!, block: (Void)->Void) {
        
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        guard !_onceTracker_token.contains(token) else { return }
        
        _onceTracker_token.append(token)
        
        block()
    }
    
    public class func once(key: String!, block: () -> ()) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        guard !_onceTracker_keys.contains(key) else { return }
        
        _onceTracker_keys.append(key)
        
        block()
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

extension DispatchSourceTimer {
    
    public func start() {
        self.resume()
    }
    
    public func stop() {
        self.cancel()
    }
}

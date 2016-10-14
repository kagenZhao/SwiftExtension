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
    
    private static var _onceTracker = [String]()
    public class func once(token: String, block: (Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        guard !_onceTracker.contains(token) else { return }
        _onceTracker.append(token)
        block()
    }
    
    public func after(delay: TimeInterval, execute closure: @escaping () -> ()) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
}

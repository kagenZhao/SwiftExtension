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
    private static var _onceTracker = [String]()
    public class func once(token: String, block: (Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        guard !_onceTracker.contains(token) else { return }
        _onceTracker.append(token)
        block()
    }
}

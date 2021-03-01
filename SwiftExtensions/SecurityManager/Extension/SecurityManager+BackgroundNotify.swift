//
//  SecurityManager+BackgroundNotify.swift
//  wmIOS
//
//  Created by Kagen Zhao on 2021/2/19.
//  Copyright © 2021 kagen. All rights reserved.
//

import UIKit

extension SecurityManager {
    public func authenticateInApplicationBecomeActive(timeInterval: TimeInterval, validateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())? = nil) {
        SecurityBackgroundNotify.shared.authenticateInApplicationBecomeActive(timeInterval: timeInterval, validateComplete: validateComplete)
    }
}

fileprivate class SecurityBackgroundNotify {
    public static let shared = SecurityBackgroundNotify()
    
    private var notificationObservers: [Any] = []
    private var enableBackgroundTimeInterval: TimeInterval = 5
    private var becomeActiveAction: ((Bool, SecurityManager.AuthenticateError?) -> ())?

    public func authenticateInApplicationBecomeActive(timeInterval: TimeInterval, validateComplete: ((Bool, SecurityManager.AuthenticateError?) -> ())? = nil) {
        becomeActiveAction = validateComplete
        enableBackgroundTimeInterval = timeInterval
    }
    
    private init() {
        let obs1 = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { (notification) in
            let key = "com.kagenz.SecurityManager.backgroundTime.\(SecurityManager.shared.userIdentifier)"
            UserDefaults.standard.set(Date(), forKey: key)
            UserDefaults.standard.synchronize()
        }
        
        let obs2 = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) {[unowned self] (notification) in
            let key = "com.kagenz.SecurityManager.backgroundTime.\(SecurityManager.shared.userIdentifier)"
            guard let oldDate = UserDefaults.standard.value(forKey: key) as? Date else { return }
            let date = Date()
            let times = abs(date.timeIntervalSince(oldDate))
            if times > self.enableBackgroundTimeInterval {
                
            }
        }
        notificationObservers.append(obs1)
        notificationObservers.append(obs2)
    }
}

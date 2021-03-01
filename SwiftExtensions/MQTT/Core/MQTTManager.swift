//
//  MQTTManager.swift
//  MQTTManager
//
//  Created by 赵国庆 on 2019/9/4.
//  Copyright © 2019 赵国庆. All rights reserved.
//

import UIKit
import HandyJSON
import RxSwift
import Alamofire

public final class MQTTManager {
    private var _publisher: MQTTMessagePublisher?
    private let _disposeBag = DisposeBag()
    private var reachability: NetworkReachabilityManager?
    private init() {}
}

// MARK: - Public Functions
extension MQTTManager {
    public static let shared = MQTTManager()
    
    public var publisher: MQTTMessagePublisher? { return _publisher }
    
    public func startMonitoring() {
        register(CocoaMQTTPublisher())
        register(for: .system, type: .echo, proceser: MQTTEchoProceser())
        
        // 监听登录登出
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "login")).subscribe(onNext: {[weak self] (notification) in
            self?._publisher?.reStart()
        }).disposed(by: _disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "logout")).subscribe(onNext: {[weak self] (notification) in
            self?._publisher?.disconnect()
        }).disposed(by: _disposeBag)
        
        func createReachability() -> NetworkReachabilityManager? {
            let r = NetworkReachabilityManager()
            r?.startListening(onUpdatePerforming: {[weak self] (status) in
                switch status {
                case .unknown, .notReachable:
                    self?._publisher?.disconnect()
                case .reachable(_):
                    self?._publisher?.connect()
                }
            })
            return r
        }
        
        reachability = createReachability()
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).subscribe(onNext: {[weak self] (notification) in
            guard let self = self else { return }
            switch self.reachability?.status {
            case .unknown, .notReachable:
                return
            case nil:
                self.reachability = createReachability()
            case .reachable(_):
                break
            }
            switch self._publisher?.state {
            case .initial?, .disconnected?:
                self._publisher?.connect()
            default:
                return
            }
        }).disposed(by: _disposeBag)
    }
    
    /// 注册Publisher, 可切换不同的MQTT库
    public func register<Publisher: MQTTMessagePublisher>(_ publisher: Publisher) {
        if let oldPublisher = self._publisher {
            oldPublisher.disconnect()
        }
        _publisher = publisher
    }
    
    /// 注册Proceser, 处理不同的业务类型
    public func register<Proceser: MQTTMessageProceser>(for module: MQTTMessageModule, type: MQTTMessageType, proceser: Proceser) {
        _publisher?.register(for: module, type: type, proceser: proceser)
    }
}


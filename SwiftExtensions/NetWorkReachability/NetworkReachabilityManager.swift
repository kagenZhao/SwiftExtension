//
//  NetworkReachabilityManager.swift
//  NetWorkReachabilityTest
//
//  Created by Kagen Zhao on 2016/10/12.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//
#if !os(watchOS)
    import UIKit
    import SystemConfiguration
    import CoreTelephony.CTTelephonyNetworkInfo
    import CoreTelephony.CTCarrier
    
    public let NetworkReachabilityNotificationItem = "com.kagen.networking.reachability.change.item"
    
    extension Notification.Name {
        public struct Reachability {
            public static let DidChange = Notification.Name(rawValue: "com.kagen.networking.reachability.change")
        }
    }
    
    public typealias Observer = (NetworkReachabilityStatus) -> Void
    
    
    /// 网络类型
    ///
    /// - unknown:      未知网络类型
    /// - notReachable: 当前无网络
    /// - WWAN:         WWAN 网络
    /// - WiFi:         WiFi 网络
    public enum NetworkReachabilityStatus {
        
        case unknown
        
        case notReachable
        
        case WWAN(NetworkReachabilityWWANStatus)
        
        case WiFi(WiFiInfo)
        
        
        /// 如果当前网络是WWAN 则判断 网络类型
        /// 如果不是 则返回 nil
        func getWWANStatus() -> NetworkReachabilityWWANStatus?{
            if case let .WWAN(status) = self {
                return status
            }
            return nil
        }
        
        /// 如果当前网络是WIFI 则获取其中的WiFiInfo
        /// 如果不是 则返回 nil
        func getWifiInfo() -> WiFiInfo? {
            if case let .WiFi(info) = self {
                return info
            }
            return nil
        }
        
        /// 用于判断使用 因为判断方法不会判断case里面的泛型 所以只是 返回了一个默认值
        static var WWAN_base: NetworkReachabilityStatus { return .WWAN(.net4g)}
        static var WiFi_base: NetworkReachabilityStatus { return .WiFi(.empty)}
    }
    
    
    /// WWAN网络类型
    ///
    /// - net2g
    /// - net3g
    /// - net4g
    public enum NetworkReachabilityWWANStatus {
        
        case net2g
        
        case net3g
        
        case net4g
    }
    
    final public class NetworkReachabilityManager {
        
        private var reachability: SCNetworkReachability
        
//        fileprivate var wifiManager: WiFiDidChangedManager = WiFiDidChangedManager()
        
        fileprivate var previousStatus: NetworkReachabilityStatus?
        
        /// 当前实例是否处于监听状态
        public private(set) var isNotifing: Bool = false
        
        /// 监听者回调
        public var observer: Observer?
        
        /// 当前的网络类型
        public var status: NetworkReachabilityStatus = .unknown
        
        /// 是否接受WiFi改变通知
        /// 必须在初始化时设置, 在监听时设置会没有效果
        /// default = false
//        public var receiveWiFiChangeNotify: Bool = false {
//            didSet {
//                if receiveWiFiChangeNotify == false {
//                    stopWifiNotify()
//                }
//            }
//        }
        
        /// 是否监听2g, 3g, 4g 改变
        /// 必须在初始化时设置, 在监听时设置会没有效果
        /// default = false
//        public var receiveTechnologyChangeNotify: Bool = false {
//            didSet {
//                if receiveTechnologyChangeNotify == false {
//                    stopTechnologyNotify()
//                }
//            }
//        }
        
        /// 当前是否联网
        public var isReachable: Bool { return isReachableViaWiFi || isReachableViaWWAN }
        
        /// 当前是否是 WWAN
        public var isReachableViaWWAN: Bool { return status == .WWAN_base }
        
        /// 当前是否是 WiFi
        public var isReachableViaWiFi: Bool { return status == .WiFi_base }
        
        /// 单例 (可用可不用)
        public static let shared: NetworkReachabilityManager? = {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            return NetworkReachabilityManager(address: &zeroAddress)
        }()
        
        
        /// 基础初始化方法
        /// 其他初始化方法如果返回不是nil 都会走此方法
        ///
        /// - parameter reachability: SCNetworkReachability
        ///
        /// - returns: NetworkReachabilityManager
        public init(reachability: SCNetworkReachability) {
            self.reachability = reachability;
        }
        
        /// 根据host 初始化SCNetworkReachability
        ///
        /// - parameter host: host
        ///
        /// - returns: NetworkReachabilityManager
        public convenience init?(host: String) {
            guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }
            
            self.init(reachability: reachability)
        }
        
        /// 根据address 初始化SCNetworkReachability
        ///
        /// - parameter address: sockaddr_in
        ///
        /// - returns: NetworkReachabilityManager
        public convenience init?(address: inout sockaddr_in) {
            guard let reachability = withUnsafePointer(to: &address, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else { return nil }
            
            self.init(reachability: reachability)
        }
        
        
        /// 开始监听
        ///
        /// - returns: 返回开始监听是否成功
        @discardableResult
        public func startMonitoring() -> Bool {
            stopMonitoring()
            
//            startWiFiNotity()
            
//            startTechnologyNotify()
            
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            
            context.info = Unmanaged.passUnretained(self).toOpaque()
            
            let callBackResult = SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
                guard let info = info else { return }
                let reachability = Unmanaged<NetworkReachabilityManager>.fromOpaque(info).takeUnretainedValue()
                reachability._statusChange(flags: flags);
                }, &context
            )
            
            let runloopResult = SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
            
            getCurrentFlags()
            
            isNotifing = callBackResult && runloopResult
            
            return isNotifing
        }
        
        private let queue = DispatchQueue.global()
        private func getCurrentFlags() {
            queue.async {
                var flags = SCNetworkReachabilityFlags()
                if SCNetworkReachabilityGetFlags(self.reachability, &flags) {
                    self._statusChange(flags: flags)
                }
            }
        }
        
        /// 开启 WIFI 改变的监听
//        private func startWiFiNotity() {
//            guard receiveWiFiChangeNotify else { return }
//            
//            wifiManager.wifiChangeCallBack = {[weak self] info in
//                guard let self_strong = self else { return }
//                self_strong.getCurrentFlags()
//            }
//            
//            wifiManager.addNotify()
//        }
        
        /// 开启2,3,4g监听
//        private func startTechnologyNotify() {
//            guard receiveTechnologyChangeNotify else { return }
//            
//            NotificationCenter.default.addObserver(self, selector: #selector(technologyDidChange(noti:)), name: NSNotification.Name.CTRadioAccessTechnologyDidChange, object: nil)
//        }
//        
//        @objc private func technologyDidChange(noti: Notification) {
//            self.getCurrentFlags()
//        }
        
        /// 结束监听
        public func stopMonitoring() {
//            stopWifiNotify()
            
//            stopTechnologyNotify()
            
            SCNetworkReachabilitySetCallback(reachability, nil, nil)
            
            SCNetworkReachabilitySetDispatchQueue(reachability, nil)
            
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
            
            isNotifing = false
        }
        
        
        /// 结束WIFI的监听
//        private func stopWifiNotify() {
//            wifiManager.removeNotify()
//        }
        
        /// 结束2,3,4g监听
//        private func stopTechnologyNotify() {
//            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.CTRadioAccessTechnologyDidChange, object: nil)
//        }
        
        deinit {
            stopMonitoring()
        }
    }
    
    extension NetworkReachabilityManager {
        fileprivate func _statusChange(flags: SCNetworkReachabilityFlags) {
            let status = _statusForFlags(flags: flags)
            DispatchQueue.main.async {
                guard let previousStatus = self.previousStatus else {
                    self.status = status
                    self._pushNotify(status)
                    return
                }
                if previousStatus == status {
                    switch (previousStatus, status) {
                    case (.unknown, .unknown), (.notReachable, .notReachable):
                        return
                    case let (.WWAN(preInfo), .WWAN(currentInfo)):
                        if preInfo != currentInfo {
                            self.status = status
                            self._pushNotify(status)
                        }
                        return
                    case let (.WiFi(preInfo), .WiFi(currentInfo)):
                        if preInfo != currentInfo {
                            self.status = status
                            self._pushNotify(status)
                        }
                        return
                    default:
                        return
                    }
                } else {
                    self.status = status
                    self._pushNotify(status)
                }
            }
        }
        
        private func _statusForFlags(flags: SCNetworkReachabilityFlags) -> NetworkReachabilityStatus {
            
            //        .transientConnection    1
            //        .reachable              2
            //        .connectionRequired     4
            //        .connectionOnTraffic    8
            //        .interventionRequired   16
            //        .connectionOnDemand     32
            //        .isLocalAddress         65526
            //        .isDirect               131072
            //        .isWWAN                 262144
            //        .connectionAutomatic    8
            
            print(flags)
            
            guard flags.contains(.reachable) else { return .notReachable }
            
            var status: NetworkReachabilityStatus = .notReachable
            
            let wifiInfo = WiFiDidChangedManager.getCurrentWiFiInfo()
            
            if !flags.contains(.connectionRequired) { status = .WiFi(wifiInfo) }
            
            if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
                if !flags.contains(.interventionRequired) { status = .WiFi(wifiInfo) }
            }
            
            #if os(iOS)
                if flags.contains(.isWWAN) { status = _WWANStatus(flags: flags) }
            #endif
            
            return status
        }
        
        private func _WWANStatus(flags: SCNetworkReachabilityFlags) -> NetworkReachabilityStatus {
            let phonyNetWork = CTTelephonyNetworkInfo()
            guard let currentStr = phonyNetWork.currentRadioAccessTechnology else {
                if flags.contains(.transientConnection) {
                    if flags.contains(.connectionRequired) { return .WWAN(.net2g) }
                    return .WWAN(.net3g)
                }
                return .unknown
            }
            if currentStr == CTRadioAccessTechnologyLTE { return .WWAN(.net4g) }
            else if currentStr == CTRadioAccessTechnologyGPRS || currentStr == CTRadioAccessTechnologyEdge { return .WWAN(.net2g) }
            else { return .WWAN(.net3g) }
        }
        
        private func _pushNotify(_ status: NetworkReachabilityStatus) {
            self.observer?(status)
            NotificationCenter.default.post(name: NSNotification.Name.Reachability.DidChange, object: nil, userInfo: [NetworkReachabilityNotificationItem:status])
        }
        
    }
    
    
    // MARK: - 注意 判断相等的方法 不会只会判断基础类型 不会判断括号中的泛型
    extension NetworkReachabilityStatus: Equatable {
        public static func ==(
            lhs: NetworkReachabilityStatus,
            rhs: NetworkReachabilityStatus)
            -> Bool
        {
            switch (lhs, rhs) {
            case (.unknown, .unknown), (.notReachable, .notReachable), (.WWAN, .WWAN), (.WiFi, .WiFi):
                return true
            default:
                return false
            }
        }
    }
    
    extension NetworkReachabilityWWANStatus: Equatable {
        public static func ==(
            lhs: NetworkReachabilityWWANStatus,
            rhs: NetworkReachabilityWWANStatus)
            -> Bool {
                switch (lhs, rhs) {
                case (.net2g, .net2g), (.net3g, .net3g), (.net4g, .net4g):
                    return true
                default:
                    return false
                }
        }
    }
    
#endif

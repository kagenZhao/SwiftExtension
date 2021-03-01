//
//  MQTTEchoProceser.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/9/9.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import RxSwift
import HandyJSON
import CoreTelephony
import CoreLocation
import DeviceKit
import Alamofire

private struct MQTTEchoBody: HandyJSON {
    var payload = "" // 不同长度的字符串
    var receiveTime = "" // 收到时间
    var receiveMsgId = ""
    var system = "" // 系统信息，IOS/Android等
    var device = "" // 设备信息，苹果/华为等
    var ip = "" // 127.0.0.1
    var network: String? // 网络信息，wifi/4G等
    var nLatitude: String? // 网络定位纬度（如有）
    var nLongtitude: String? // 网络定位经度（如有）
    var gLatitude: String? // GPS定位维度（如有）
    var gLongtitude: String? // GPS定位经度（如有）
    public init() {}
}


public class MQTTEchoProceser: MQTTMessageProceser {
    
    private var coordinate: CLLocationCoordinate2D?
    
    public func processMessage(_ message: MQTTResponse<[String: Any]>) {
        guard message.head.module == .system, message.head.type == .echo else { return }
        guard var returnMessage: MQTTResponse<MQTTEchoBody> = message.transformBody() else { return }
        guard let publisher = MQTTManager.shared.publisher else { return }
        guard let publishTopic = publisher.publishTopic else { return }
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        returnMessage.head.qos = publishTopic.qos
        returnMessage.head.ttl = 0
        returnMessage.head.module = .system
        returnMessage.head.type = .echo
        returnMessage.head.sendTime = TimeInterval(currentTime)
        returnMessage.head.msgId = UUID().uuidString
        returnMessage.head.emqClientId = publisher.clientID
        returnMessage.body.ip = AppInfo.Device.getIpAddress()
        returnMessage.body.device = Device.identifier
        returnMessage.body.system = UIDevice.current.systemName + UIDevice.current.systemVersion
        returnMessage.body.receiveMsgId = message.head.msgId
        returnMessage.body.receiveTime = String(currentTime)
        returnMessage.body.network = getNetworkStatus()
        getLocation {[weak self] (coordinate) in
            if let coordinate = coordinate ?? self?.coordinate {
                self?.coordinate = coordinate
                let latitude = coordinate.latitude.preciseDecimal(digits: 12)
                let longitude = coordinate.longitude.preciseDecimal(digits: 12)
                returnMessage.body.nLatitude = latitude
                returnMessage.body.nLongtitude = longitude
                returnMessage.body.gLatitude = latitude
                returnMessage.body.gLongtitude = longitude
            } else {
                returnMessage.body.nLatitude = nil
                returnMessage.body.nLongtitude = nil
                returnMessage.body.gLatitude = nil
                returnMessage.body.gLongtitude = nil
            }
            publisher.publish(returnMessage)
        }
    }
    
    
    private func getNetworkStatus() -> String {
        switch NetworkReachabilityManager.default?.status {
        case nil, .unknown: return "未知"
        case .notReachable: return "无网络"
        case .reachable(let type):
            switch type {
            case .ethernetOrWiFi:
                return "WIFI"
            case .cellular:
                let carrierType = CTTelephonyNetworkInfo().currentRadioAccessTechnology
                switch carrierType {
                case CTRadioAccessTechnologyGPRS?,
                     CTRadioAccessTechnologyEdge?,
                     CTRadioAccessTechnologyCDMA1x?:
                    return "2G"
                case CTRadioAccessTechnologyWCDMA?,
                     CTRadioAccessTechnologyHSDPA?,
                     CTRadioAccessTechnologyHSUPA?,
                     CTRadioAccessTechnologyCDMAEVDORev0?,
                     CTRadioAccessTechnologyCDMAEVDORevA?,
                     CTRadioAccessTechnologyCDMAEVDORevB?,
                     CTRadioAccessTechnologyeHRPD?:
                    return "3G"
                case CTRadioAccessTechnologyLTE?:
                    return "4G"
                default:
                    return "移动网络"
                }
            }
        
        }
    }
    
    
    func getLocation(complete: @escaping ((CLLocationCoordinate2D?) -> ())) {
        /**
         2019/10/09
         4.5版本暂时不添加新的权限
         */
        complete(nil)
        
//        guard CLLocationManager.locationServicesEnabled() else {
//            complete(nil)
//            return
//        }
//        let locationManager = CLLocationManager()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.distanceFilter = 100.0
//        locationManager.requestWhenInUseAuthorization()
//        var didChangeAuthorizationStatusDispose: Disposable?
//        var didUpdateLocationsDispose: Disposable?
//
//        didUpdateLocationsDispose = locationManager.rx
//            .didUpdateLocations
//            .filter({ $0.count > 0 })
//            .map({ $0.first! })
//            .timeout(.seconds(3), scheduler: MainScheduler.instance)
//            .subscribe(onNext: { (currentLocation) in
//                complete(currentLocation.coordinate)
//                locationManager.stopUpdatingLocation()
//                didUpdateLocationsDispose?.dispose()
//                didChangeAuthorizationStatusDispose?.dispose()
//            }, onError: { err in
//                complete(nil)
//                locationManager.stopUpdatingLocation()
//                didUpdateLocationsDispose?.dispose()
//                didChangeAuthorizationStatusDispose?.dispose()
//            })
//
//        didChangeAuthorizationStatusDispose = locationManager.rx
//            .didChangeAuthorizationStatus
//            .subscribe(onNext: { (status) in
//                switch status {
//                case .notDetermined:
//                    locationManager.requestWhenInUseAuthorization()
//                case .authorizedAlways, .authorizedWhenInUse:
//                    locationManager.startUpdatingLocation()
//                default:
//                    complete(nil)
//                    didChangeAuthorizationStatusDispose?.dispose()
//                    didUpdateLocationsDispose?.dispose()
//                }
//            })
    }
}

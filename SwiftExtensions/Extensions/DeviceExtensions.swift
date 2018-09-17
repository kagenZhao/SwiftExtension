//
//  DeviceExtensions.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2018/8/27.
//  Copyright © 2018年 kagenZhao. All rights reserved.
//

import UIKit
import DeviceKit
import SwiftDate

extension Device {
    
    public static var alliOS: [Device] {
        return allPods + allPads + allPhones + allSimulatorPads + allSimulatorPods + allSimulatorPhones + [.homePod]
    }
    
    public static var allNoneBiometry: [Device] {
        let result: [Device] = [.iPodTouch5, iPodTouch6, .iPhone4, .iPhone5, .iPhone5c, .iPad2, .iPad3, .iPad4, .iPadAir, .iPadMini, .iPadMini2, .homePod]
        return result + result.map(Device.simulator)
    }
    
    /// TouchID 的设备在2018年之前已经结束了 接下来都应该是FaceID的设备
    /// 所以这个数组应该是准确的
    public static var allTouchId: [Device] {
        let result: [Device] = [.iPhone5s, .iPhone6, .iPhone6Plus, .iPhone6s, .iPhone6sPlus, .iPhone7, .iPhone7Plus, .iPhone8, .iPhone8Plus, .iPadAir2, .iPad5, .iPad6, .iPadMini3, .iPadPro9Inch, .iPadPro12Inch, .iPadPro12Inch2, .iPadPro10Inch]
        return result + result.map(Device.simulator)
    }
    
    /// 将来的iPad和iPhone 都是 FaceID
    /// 所以 这个数组目前还不准确, 尽量不要用
    /// Pod "Device" 更新时 请及时添加
    public static var allFaceId: [Device] {
        let result: [Device] = [.iPhoneX]
        return result + result.map(Device.simulator)
    }
    
    public func mapYear() -> Date? {
        #if os(iOS)
        switch self {
        case .iPodTouch5: return "2012-9".toDate()?.date
        case .iPodTouch6: return "2015-7".toDate()?.date
        case .iPhone4: return "2010-6".toDate()?.date
        case .iPhone4s: return "2011-10".toDate()?.date
        case .iPhone5: return "2012-9".toDate()?.date
        case .iPhone5c: return "2012-9".toDate()?.date
        case .iPhone5s: return "2013-9".toDate()?.date
        case .iPhone6: return "2014-9".toDate()?.date
        case .iPhone6Plus: return "2014-9".toDate()?.date
        case .iPhone6s: return "2015-9".toDate()?.date
        case .iPhone6sPlus: return "2015-9".toDate()?.date
        case .iPhone7: return "2016-9".toDate()?.date
        case .iPhone7Plus: return "2016-9".toDate()?.date
        case .iPhoneSE: return "2016-3".toDate()?.date
        case .iPhone8: return "2017-9".toDate()?.date
        case .iPhone8Plus: return "2017-9".toDate()?.date
        case .iPhoneX: return "2017-9".toDate()?.date
        case .iPad2: return "2011-3".toDate()?.date
        case .iPad3: return "2012-3".toDate()?.date
        case .iPad4: return "2012-10".toDate()?.date
        case .iPadAir: return "2013-10".toDate()?.date
        case .iPadAir2: return "2014-10".toDate()?.date
        case .iPad5: return "2017-3".toDate()?.date
        case .iPad6: return "2018-3".toDate()?.date
        case .iPadMini: return "2012-10".toDate()?.date
        case .iPadMini2: return "2013-10".toDate()?.date
        case .iPadMini3: return "2014-10".toDate()?.date
        case .iPadMini4: return "2015-9".toDate()?.date
        case .iPadPro9Inch: return "2016-3".toDate()?.date
        case .iPadPro12Inch: return "2015-9".toDate()?.date
        case .iPadPro12Inch2: return "2017-6".toDate()?.date
        case .iPadPro10Inch: return "2017-6".toDate()?.date
        case .homePod: return "2017-6".toDate()?.date
        case .simulator(_): return Device.mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS").mapYear()
        case .unknown(_): return nil
        }
        #elseif os(tvOS)
        switch self {
        case .appleTV4: return "2015-9".toDate()?.date
        case .appleTV4K: return "2017-9".toDate()?.date
        case .simulator(_): return Device.mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS").mapYear()
        case .unknown(_): return nil
        }
        #endif
    }
    
    private enum AppleClass: String, CaseIterable {
        case iPod = "iPod"
        case iPhone = "iPhone"
        case iPad = "iPad"
        case audioAccessory = "AudioAccessory"
        case appleTV = "AppleTV"
        case i386 = "i386"
        case x86_64 = "x86_64"
        case future = "_Future_"
    }
    
    private func mapToVersion() -> (AppleClass, Int, Int)? {
        #if os(iOS)
        switch self {
        case .iPodTouch5: return (.iPod, 5, 1)
        case .iPodTouch6: return (.iPod, 5, 1)
        case .iPhone4: return (.iPod, 5, 1)
        case .iPhone4s: return (.iPod, 5, 1)
        case .iPhone5: return (.iPod, 5, 1)
        case .iPhone5c: return (.iPod, 5, 1)
        case .iPhone5s: return (.iPod, 5, 1)
        case .iPhone6: return (.iPod, 5, 1)
        case .iPhone6Plus: return (.iPod, 5, 1)
        case .iPhone6s: return (.iPod, 5, 1)
        case .iPhone6sPlus: return (.iPod, 5, 1)
        case .iPhone7: return (.iPod, 5, 1)
        case .iPhone7Plus: return (.iPod, 5, 1)
        case .iPhoneSE: return (.iPod, 5, 1)
        case .iPhone8: return (.iPod, 5, 1)
        case .iPhone8Plus:return (.iPod, 5, 1)
        case .iPhoneX: return (.iPod, 5, 1)
        case .iPad2: return (.iPod, 5, 1)
        case .iPad3: return (.iPod, 5, 1)
        case .iPad4: return (.iPod, 5, 1)
        case .iPadAir: return (.iPod, 5, 1)
        case .iPadAir2: return (.iPod, 5, 1)
        case .iPad5: return (.iPod, 5, 1)
        case .iPad6: return (.iPod, 5, 1)
        case .iPadMini: return (.iPod, 5, 1)
        case .iPadMini2: return (.iPod, 5, 1)
        case .iPadMini3: return (.iPod, 5, 1)
        case .iPadMini4: return (.iPod, 5, 1)
        case .iPadPro9Inch: return (.iPod, 5, 1)
        case .iPadPro12Inch: return (.iPod, 5, 1)
        case .iPadPro12Inch2: return (.iPod, 5, 1)
        case .iPadPro10Inch: return (.iPod, 5, 1)
        case .homePod: return (.iPod, 5, 1)
        case .simulator(_): return Device.mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS").mapToVersion()
        case .unknown(let idf):
            for cls in AppleClass.allCases {
                if idf.hasPrefix(cls.rawValue) {
                    let suff = idf.prefix(cls.rawValue.count)
                    let version = suff.components(separatedBy: ",")
                    if version.count == 2, let v1 = Int(version[0]), let v2 = Int(version[1]) {
                        return (cls, v1, v2)
                    } else {
                        return (cls, Int(version[0]) ?? 99, 1)
                    }
                }
            }
            if idf == "iOS" { // 模拟器
                return nil
            } else { // 新的设备, 新的产品线
                return (.future, 1, 1)
            }
        }
        #elseif os(tvOS)
        switch self {
        case .appleTV4: return (.appleTV, 5, 3)
        case .appleTV4K: return (.appleTV, 6, 2)
        case .simulator(_): return Device.mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS").mapYear()
        case .unknown(_):
            for cls in AppleClass.allCases {
                if idf.hasPrefix(cls.rawValue) {
                    let suff = idf.prefix(cls.rawValue.count)
                    let version = suff.components(separatedBy: ",")
                    if version.count == 2, let v1 = Int(version[0]), let v2 = Int(version[1]) {
                        return (cls, v1, v2)
                    } else {
                        return (cls, Int(version[0]) ?? 99, 1)
                    }
                }
            }
            if idf == "tvOS" { // 模拟器
                return nil
            } else { // 新的设备, 新的产品线
                return (.future, 1, 1)
            }
        }
        #endif
    }
    

}

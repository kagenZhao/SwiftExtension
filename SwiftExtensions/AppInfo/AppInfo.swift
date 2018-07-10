//
//  AppMemoryInfo.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/21.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation

//@discardableResult
//@_silgen_name("memoryUsage") // 少量 oc 或者 c 文件可以不用桥接文件, 用 @_silgen_name("functionName") 代替
//private func memoryUsage() -> UInt64

//@_silgen_name("totalMemory")
//private func totalMemory() -> UInt64

//@_silgen_name("freeMemory")
//private func freeMemory() -> UInt64

//@_silgen_name("logMemoryInfo")
//private func logMemoryInfo()

//@_silgen_name("freeDiskSize")
//private func freeDiskSize() -> UInt64

//@_silgen_name("totalDiskSize")
//private func totalDiskSize() -> UInt64

//@_silgen_name("appUsageDiskSize")
//private func appUsageDiskSize(_ folder: String) -> UInt64


public enum CountStyle {
    case decimal(ByteStyle) // 1000 bytes are shown as 1 KB
    case binary(ByteStyle) // 1024 bytes are shown as 1 KB
    
    fileprivate var value: Double {
        switch self {
        case .decimal(let style):
            return pow(1000, Double(style.rawValue))
        case .binary(let style):
            return pow(1024, Double(style.rawValue))
        }
    }
    
    fileprivate var unit: String {
        switch self {
        case .decimal(let style), .binary(let style):
            return style.unit
        }
    }
    
    fileprivate func smartChoose(_ value: Double) -> CountStyle {
        var baseNumber: Double = 1000;
        var resultStyle: ByteStyle!
        switch self {
        case .decimal(let style): if style != .smart { return self }; baseNumber = 1000;
        case .binary(let style): if style != .smart { return self }; baseNumber = 1024
        }
        switch value {
        case ...(baseNumber * Double(ByteStyle.bt.rawValue)): resultStyle = .bt
        case (baseNumber * Double(ByteStyle.bt.rawValue))...(baseNumber * Double(ByteStyle.kb.rawValue)): resultStyle = .kb
        case (baseNumber * Double(ByteStyle.kb.rawValue))...(baseNumber * Double(ByteStyle.mb.rawValue)): resultStyle = .mb
        case (baseNumber * Double(ByteStyle.mb.rawValue))...(baseNumber * Double(ByteStyle.gb.rawValue)): resultStyle = .gb
        case (baseNumber * Double(ByteStyle.gb.rawValue))...(baseNumber * Double(ByteStyle.tb.rawValue)): resultStyle = .tb
        case (baseNumber * Double(ByteStyle.tb.rawValue))...(baseNumber * Double(ByteStyle.pb.rawValue)): resultStyle = .pb
        case (baseNumber * Double(ByteStyle.pb.rawValue))...(baseNumber * Double(ByteStyle.eb.rawValue)): resultStyle = .eb
        case (baseNumber * Double(ByteStyle.eb.rawValue))...(baseNumber * Double(ByteStyle.zb.rawValue)): resultStyle = .zb
        case (baseNumber * Double(ByteStyle.zb.rawValue))...(baseNumber * Double(ByteStyle.yb.rawValue)): resultStyle = .yb
        default:
            resultStyle = .bt
        }
        
        switch self {
        case .decimal(_): return .decimal(resultStyle);
        case .binary(_): return .binary(resultStyle)
        }
    }
}

public enum ByteStyle: Int {
    case smart = -1
    case bt
    case kb
    case mb
    case gb
    case tb
    case pb
    case eb
    case zb
    case yb
    
    fileprivate var unit: String {
        switch self {
        case .smart: return "Auto"
        case .bt: return "B"
        case .kb: return "KB"
        case .mb: return "MB"
        case .gb: return "GB"
        case .tb: return "TB"
        case .pb: return "PB"
        case .eb: return "EB"
        case .zb: return "ZB"
        case .yb: return "YB"
        }
    }
}


public struct AppInfo {}

public extension AppInfo {
    //    public struct CPU {
    //
    //
    //    }
}

public extension AppInfo {
    public struct Memory {
        
        public static func appUsage(_ style: CountStyle = .decimal(.smart)) -> (value: Double, string: String) {
            var v = Double(memoryUsage())
            v = v / style.smartChoose(v).value
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func deviceTotal(_ style: CountStyle = .decimal(.smart)) -> (value: Double, string: String) {
            var v = Double(totalMemory())
            v = v / style.smartChoose(v).value
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func deviceAvailable(_ style: CountStyle = .decimal(.smart)) -> (value: Double, string: String) {
            var v = Double(freeMemory())
            v = v / style.smartChoose(v).value
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
    }
}

public extension AppInfo {
    public struct Disk {
        
        public static func deviceAvailable(_ style: CountStyle = .decimal(.smart)) -> (value: Double, string: String) {
            var v = Double(freeDiskSize())
            v = v / style.smartChoose(v).value
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func deviceTotal(_ style: CountStyle = .decimal(.smart)) -> (value: Double, string: String) {
            var v = Double(totalDiskSize())
            v = v / style.smartChoose(v).value
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func deiveUsage(_ style: CountStyle = .decimal(.smart)) -> (value: Double, string: String) {
            var v = Double(totalDiskSize() - freeDiskSize())
            v = v / style.smartChoose(v).value
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func appUsage(_ folder: String, _ style: CountStyle = .decimal(.smart)) -> (value: Double, string: String) {
            var v = Double(appUsageDiskSize(folder))
            v = v / style.smartChoose(v).value
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
    }
}

public extension AppInfo {
    public struct Device {
        @_silgen_name("getIpAddress")
        public static func getIpAddress() -> String
        
        /// 电池电量
        public static var battery: Float { return UIDevice.current.batteryLevel }
        
        /// 充电状态
        public static var batteryMode: UIDevice.BatteryState { return UIDevice.current.batteryState }
        
        /// 低电量模式
        @available(iOS 9.0, *)
        public static var isLowPowerMode: Bool { return ProcessInfo.processInfo.isLowPowerModeEnabled }
        
        /// 屏幕亮度
        public static var brightness: Float {
            get { return UIScreen.main.brightness.toFloat }
            set { UIScreen.main.brightness = newValue.toCGFloat }
        }
        
        /// 音量
        public static var volume: Float {
            set {
                VolumeController.shared.volume = newValue
            }
            get {
                return VolumeController.shared.volume
            }
        }
    }
}


// MARK: - Tools
public extension AppInfo.Memory {
    public static func memoryInfo( vmStats: inout vm_statistics_data_t) -> Bool {
        var infoCount: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.size / MemoryLayout<integer_t>.size)
        let kernReturn: kern_return_t = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_host_self(), task_flavor_t(HOST_VM_INFO), $0, &infoCount)
            }
        }
        return kernReturn == KERN_SUCCESS
    }
    
    public static func logMemoryInfo() {
        var vmStats = vm_statistics_data_t()
        if memoryInfo(vmStats: &vmStats) {
            let info = ProcessInfo()
            print("***======Memory Log Begin======***");
            print("     Total:         \(info.physicalMemory) ");
            print("     Free:          \(vm_size_t(vmStats.free_count) * vm_page_size)")
            print("     Active:        \(vm_size_t(vmStats.active_count) * vm_page_size)");
            print("     Inactive:      \(vm_size_t(vmStats.inactive_count) * vm_page_size)");
            print("     Wire:          \(vm_size_t(vmStats.wire_count) * vm_page_size)");
            print("     Zerofill:      \(vm_size_t(vmStats.zero_fill_count) * vm_page_size)");
            print("     Reactivations: \(vm_size_t(vmStats.reactivations) * vm_page_size)");
            print("     Pageins:       \(vm_size_t(vmStats.pageins) * vm_page_size)");
            print("     Pageouts:      \(vm_size_t(vmStats.pageouts) * vm_page_size)");
            print("     Faults:        \(vmStats.faults)");
            print("     Cow_faults:    \(vmStats.cow_faults)");
            print("     Lookups:       \(vmStats.lookups)");
            print("     Hits:          \(vmStats.hits)");
            print("***=======Memory Log End=======***\n");
        } else {
            print("***======No Memory Info======***")
        }
    }
    
    public static func totalMemory() -> UInt64 {
        return ProcessInfo().physicalMemory;
    }
    
    public static func freeMemory() -> UInt64 {
        var vmStats = vm_statistics_data_t()
        if memoryInfo(vmStats: &vmStats) {
            return UInt64(vmStats.free_count) * UInt64(vm_page_size)
        }
        return 0
    }
    
    public static func memoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)
        let kernReturn: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(HOST_BASIC_INFO), $0, &size)
            }
        }
        return kernReturn == KERN_SUCCESS ? info.resident_size : 0;
    }
}

public extension AppInfo.Disk {
    public static func appUsageDiskSize(_ folder: String? = nil) -> UInt64 {
        guard let path = folder ?? NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
            return 0
        }
        
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return 0
        }
        
        return contents.reduce(UInt64(0)) { (result, subPath)in
            guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: "\(path)/\(subPath)") else {
                return result
            }
            guard let size = fileAttributes[.size] as? UInt64 else {
                return result
            }
            return result + size
        }
    }
    
    public static func totalDiskSize() -> UInt64 {
        return diskSize(for: .systemSize)
    }
    
    public static func freeDiskSize() -> UInt64 {
        return diskSize(for: .systemFreeSize)
    }
    
    fileprivate static func diskSize(for key: FileAttributeKey) -> UInt64 {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
            return 0
        }
        guard let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: path) else {
            return 0
        }
        
        guard let totalSize = dictionary[key] as? UInt64 else {
            return 0
        }
        
        return totalSize
    }
}

extension AppInfo {
    fileprivate static func fix(_ s: String) -> String {
        var str = s
        if let temp = str.components(separatedBy: ".").last {
            if Int(temp)! == 0 { str = str.components(separatedBy: ".").first! }
            else if Double(temp)! / 10.0 == 0.0 { str = str.components(separatedBy: ".").first! + ".\(Int(temp)! / 10)" }
        }
        return str
    }
}

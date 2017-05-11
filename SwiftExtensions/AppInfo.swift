//
//  AppMemoryInfo.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/21.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation

@discardableResult
@_silgen_name("memoryUsage") // 少量 oc 或者 c 文件可以不用桥接文件, 用 @_silgen_name("functionName") 代替
private func memoryUsage() -> UInt64

@_silgen_name("totalMemory")
private func totalMemory() -> UInt64

@_silgen_name("freeMemory")
private func freeMemory() -> UInt64

@_silgen_name("logMemoryInfo")
private func logMemoryInfo()

@_silgen_name("diskAvailable")
private func diskAvailable() -> UInt64

@_silgen_name("totalDiskSize")
private func totalDiskSize() -> UInt64

@_silgen_name("appUsageDiskSize")
private func appUsageDiskSize(_ folder: String) -> UInt64


public enum CountStyle {
    case decimal(ByteStyle) // 1000 bytes are shown as 1 KB
    case binary(ByteStyle) // 1024 bytes are shown as 1 KB
    
    fileprivate var value: UInt64 {
        switch self {
        case .decimal(let style):
            return UInt64(pow(1000, Double(style.rawValue)))
        case .binary(let style):
            return UInt64(pow(1024, Double(style.rawValue)))
        }
    }
    
    fileprivate var unit: String {
        switch self {
        case .decimal(let style), .binary(let style):
            return style.unit
        }
    }
}

public enum ByteStyle: Int {
    case bt
    case kb
    case mb
    case gb
    
    fileprivate var unit: String {
        switch self {
        case .bt: return "B"
        case .kb: return "KB"
        case .mb: return "MB"
        case .gb: return "GB"
        }
    }
}


public struct AppInfo {
    
    public struct Memory {
        
        public static func appUsage(_ style: CountStyle = .decimal(.bt)) -> (value: Double, string: String) {
            let v = Double(memoryUsage()) / Double(style.value)
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func deviceTotal(_ style: CountStyle = .decimal(.bt)) -> (value: Double, string: String) {
            let v = Double(totalMemory()) / Double(style.value)
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func deviceAvailable(_ style: CountStyle = .decimal(.bt)) -> (value: Double, string: String) {
            let v = Double(freeMemory()) / Double(style.value)
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func log() { logMemoryInfo() }
    }
    
    public struct Disk {
        
        public static func deviceAvailable(_ style: CountStyle = .decimal(.bt)) -> (value: Double, string: String) {
            let v = Double(diskAvailable()) / Double(style.value)
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func deviceTotal(_ style: CountStyle = .decimal(.bt)) -> (value: Double, string: String) {
            let v = Double(totalDiskSize()) / Double(style.value)
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func deiveUsage(_ style: CountStyle = .decimal(.bt)) -> (value: Double, string: String) {
            let v = Double(totalDiskSize() - diskAvailable()) / Double(style.value)
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
        
        public static func appUsage(_ folder: String, _ style: CountStyle = .decimal(.bt)) -> (value: Double, string: String) {
            let v = Double(appUsageDiskSize(folder)) / Double(style.value);
            return (value: v, string: AppInfo.fix(String(format: "%.2f", v)) + style.unit)
        }
    }
    
//    public struct CPU {
//        
//       
//    }
    
    fileprivate static func fix(_ s: String) -> String {
        var str = s
        if let temp = str.components(separatedBy: ".").last {
            if Int(temp)! == 0 { str = str.components(separatedBy: ".").first! }
            else if Double(temp)! / 10.0 == 0.0 { str = str.components(separatedBy: ".").first! + ".\(Int(temp)! / 10)" }
        }
        return str
    }
}

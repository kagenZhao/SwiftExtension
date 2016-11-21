//
//  AppMemoryInfo.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/21.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation

open class AppMemoryInfo {
    
    class func usage() -> UInt64 {
        var info =  mach_task_basic_info()
        var size = UInt32(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)
        let kerr = withUnsafeMutablePointer(to: &info, {
            $0.withMemoryRebound(to: integer_t.self, capacity: MemoryLayout<integer_t>.size, { (p) -> kern_return_t in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), p, &size)
            })
        })
        
        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(info.resident_size)")
        } else {
            print("Error with task_info: \(mach_error_string(kerr))")
        }
        
        return info.resident_size
    }
}

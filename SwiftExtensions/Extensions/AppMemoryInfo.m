//
//  AppMemoryInfoC.m
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/22.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

unsigned long long memoryUsage(){
    
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                   MACH_TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %llu", info.resident_size);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    return info.resident_size;
}


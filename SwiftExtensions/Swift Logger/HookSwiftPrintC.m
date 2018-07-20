//
//  HookSwiftPrintC.m
//  SwiftExtensions
//
//  Created by 赵国庆 on 2018/7/17.
//  Copyright © 2018年 kagenZhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/uio.h>
#import <stdio.h>
#import <fishhook/fishhook.h>


// 这两个方法是 swift 的print调用的
// 修复swift4
static char *__chineseChar = {0};
static int __buffIdx = 0;
static NSString *__syncToken = @"token";

static size_t (*orig_fwrite)(const void * __restrict, size_t, size_t, FILE * __restrict);
static size_t new_fwrite(const void * __restrict ptr, size_t size, size_t nitems, FILE * __restrict stream) {
    @synchronized (__syncToken) {
        char *str = (char *)ptr;
        NSString *s = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        __buffIdx = 0;
        __chineseChar = calloc(1, sizeof(char));
//        [[logInWindowManager share] addPrintWithMessage:s needReturn:false];
    }
    return orig_fwrite(ptr, size, nitems, stream);
}

static int (*orin___swbuf)(int, FILE *);
static int new___swbuf(int c, FILE *p) {
    @synchronized (__syncToken) {
        __chineseChar = realloc(__chineseChar, sizeof(char) * (__buffIdx + 2));
        __chineseChar[__buffIdx] = (char)c;
        __chineseChar[__buffIdx + 1] = '\0';
        __buffIdx++;
        if (((char)c) == '\n') {
            NSString *s = [NSString stringWithCString:__chineseChar encoding:NSUTF8StringEncoding];
            __buffIdx = 0;
            __chineseChar = calloc(1, sizeof(char));
//            [[logInWindowManager share] addPrintWithMessage:s needReturn:false];
        }
    }
    return orin___swbuf(c, p);
}

// 发现新问题, 这个方法和NSLog重复了.. 所以把不hook NSLog了
static ssize_t (*orig_writev)(int a, const struct iovec *, int);
static ssize_t new_writev(int a, const struct iovec *v, int v_len) {
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < v_len; i++) {
        char *c = (char *)v[i].iov_base;
        [string appendString:[NSString stringWithCString:c encoding:NSUTF8StringEncoding]];
    }
    ssize_t result = orig_writev(a, v, v_len);
    dispatch_async(dispatch_get_main_queue(), ^{
//        [[logInWindowManager share] addPrintWithMessage:string needReturn:false];
    });
    return result;
}


static void rebindFunction() {
    int error = 0;
    //    rebind_symbols((struct rebinding[1]){{"NSLog", new_NSLog, (void *)&orig_NSLog}}, 1);
    error = rebind_symbols((struct rebinding[1]){{"writev", new_writev, (void *)&orig_writev}}, 1);
    if (error < 0) {
        NSLog(@"错误 writev");
    }
    error = rebind_symbols((struct rebinding[1]){{"fwrite", new_fwrite, (void *)&orig_fwrite}}, 1);
    if (error < 0) {
        NSLog(@"错误 fwrite");
    }
    error = rebind_symbols((struct rebinding[1]){{"__swbuf", new___swbuf, (void *)&orin___swbuf}}, 1);
    if (error < 0) {
        NSLog(@"错误 __swbuf");
    }
}


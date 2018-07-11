//
//  UIViewController+Rotation.h
//  wmICIOS
//
//  Created by 赵国庆 on 2018/7/11.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "UIViewController+Rotation.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIViewController (Rotation)

// 有一些 系统内部类, 无法重写, 这里就给出一个列表来进行修改
- (NSDictionary <NSString *, NSArray *>*)preferenceRotateInternalClass {
    return @{
             @"AVFullScreenViewController":@[@YES, @(UIInterfaceOrientationMaskAll)]
             };
}

/**
 * 默认所有都不支持转屏,如需个别页面支持除竖屏外的其他方向，请在viewController重写这三个方法
 */
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    NSArray *preference = self.preferenceRotateInternalClass[NSStringFromClass(topVC.class)];
    if (preference) return [preference[0] boolValue];
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    NSArray *preference = self.preferenceRotateInternalClass[NSStringFromClass(topVC.class)];
    if (preference) return [preference[1] integerValue];
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIViewController *)rotation_findTopViewController {
    if ([self isKindOfClass:UINavigationController.class]) {
        return ((UINavigationController *)self).topViewController.rotation_findTopViewController ?: self;
    } else if ([self isKindOfClass:UITabBarController.class]) {
        return ((UITabBarController *)self).selectedViewController.rotation_findTopViewController ?: self;
    } else {
        NSArray <NSString *>* excludeCls = @[@"UISnapshotModalViewController"];
        UIViewController *presentedVC = self.presentedViewController;
        if (presentedVC != nil && ![excludeCls containsObject:NSStringFromClass(presentedVC.class)]) {
            return self.presentedViewController.rotation_findTopViewController;
        } else if ([excludeCls containsObject:NSStringFromClass(self.class)]) {
            return self.presentingViewController;
        } else {
            return self;
        }
    }
}

@end

@implementation UITabBarController (Rotation)
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    NSArray *preference = self.preferenceRotateInternalClass[NSStringFromClass(topVC.class)];
    if (preference) return [preference[0] boolValue];
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    NSArray *preference = self.preferenceRotateInternalClass[NSStringFromClass(topVC.class)];
    if (preference) return [preference[1] integerValue];
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

@end

@implementation UINavigationController (ZFPlayerRotation)

- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    NSArray *preference = self.preferenceRotateInternalClass[NSStringFromClass(topVC.class)];
    if (preference) return [preference[0] boolValue];
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    NSArray *preference = self.preferenceRotateInternalClass[NSStringFromClass(topVC.class)];
    if (preference) return [preference[1] integerValue];
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end

@implementation UIAlertController (Rotation)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
@end

@implementation UIApplication (Rotation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oldMethod = class_getInstanceMethod([self class], @selector(setDelegate:));
        Method newMethod = class_getInstanceMethod([self class], @selector(hook_setDelegate:));
        method_exchangeImplementations(oldMethod, newMethod);
    });
}

- (void)hook_setDelegate:(id<UIApplicationDelegate>)delegate {
    SEL oldSelector = @selector(application:supportedInterfaceOrientationsForWindow:);
    SEL newSelector = @selector(hook_application:supportedInterfaceOrientationsForWindow:);
    Method oldMethod_del = class_getInstanceMethod([delegate class], oldSelector);
    Method oldMethod_self = class_getInstanceMethod([self class], oldSelector);
    Method newMethod = class_getInstanceMethod([self class], newSelector);
    BOOL isSuccess = class_addMethod([delegate class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
    if (isSuccess) {
        class_replaceMethod([delegate class], newSelector, class_getMethodImplementation([self class], oldSelector), method_getTypeEncoding(oldMethod_self));
    } else {
        BOOL isVictory = class_addMethod([delegate class], newSelector, class_getMethodImplementation([delegate class], oldSelector), method_getTypeEncoding(oldMethod_del));
        if (isVictory) {
            class_replaceMethod([delegate class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
        }
    }
    [self hook_setDelegate:delegate];
}

- (UIInterfaceOrientationMask)hook_application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    //    UIInterfaceOrientationMask oldResult = [self hook_application:application supportedInterfaceOrientationsForWindow:window];
    if (window.rootViewController.rotation_findTopViewController) {
        return window.rootViewController.rotation_findTopViewController.supportedInterfaceOrientations;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
@end



//
//  UIViewController+Rotation.h
//  wmICIOS
//
//  Created by 赵国庆 on 2018/7/11.
//  Copyright © 2018年 kagen. All rights reserved.
//

#import "UIViewController+Rotation.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#import <objc/message.h>

static void _exchangeClassInstanceMethod(Class cls, SEL s1, SEL s2) {
    Method originalMethod = class_getInstanceMethod(cls, s1);
    Method swizzledMethod = class_getInstanceMethod(cls, s2);
    if (class_addMethod(cls, s1, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(cls, s2, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface UIViewControllerRotationModel : NSObject
@property (nonatomic, copy) NSString *cls;
@property (nonatomic, assign) BOOL shouldAutorotate;
@property (nonatomic, assign) UIInterfaceOrientationMask supportedInterfaceOrientations;
@property (nonatomic, assign) UIInterfaceOrientation preferredInterfaceOrientationForPresentation;
@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyle;
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@end

@implementation UIViewControllerRotationModel
- (instancetype)initWithCls:(NSString *)cls
           shouldAutorotate: (BOOL)shouldAutorotate
supportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
preferredInterfaceOrientationForPresentation:(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
    preferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
     prefersStatusBarHidden:(BOOL)prefersStatusBarHidden {
    self = [super init];
    if (self) {
        _cls = cls;
        _shouldAutorotate = shouldAutorotate;
        _supportedInterfaceOrientations = supportedInterfaceOrientations;
        _preferredInterfaceOrientationForPresentation = preferredInterfaceOrientationForPresentation;
        _preferredStatusBarStyle = preferredStatusBarStyle;
        _prefersStatusBarHidden = prefersStatusBarHidden;
    }
    return self;
}
@end

@interface UIViewController ()
@property (nonatomic, assign) BOOL rotation_isDissmissing;
@end

@implementation UIViewController (Rotation)

static void *rotation_isDissmissingKey;
- (BOOL)rotation_isDissmissing {
    return [objc_getAssociatedObject(self, &rotation_isDissmissingKey) boolValue];
}

- (void)setRotation_isDissmissing:(BOOL)rotation_isDissmissing {
    objc_setAssociatedObject(self, &rotation_isDissmissingKey, @(rotation_isDissmissing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _exchangeClassInstanceMethod(UIViewController.class, @selector(dismissViewControllerAnimated:completion:), @selector(hook_dismissViewControllerAnimated:completion:));
        _exchangeClassInstanceMethod(UIViewController.class, @selector(presentViewController:animated:completion:), @selector(hook_presentViewController:animated:completion:));
    });
}

- (void)hook_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    __weak typeof(self) weak_self = self;
    self.rotation_isDissmissing = true;
    [self hook_dismissViewControllerAnimated:flag completion:^{
        weak_self.rotation_isDissmissing = false;
        if (completion) {
            completion();
        }
    }];
}

- (void)hook_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self hook_presentViewController:viewControllerToPresent animated:flag completion:^{
        if (completion) {
            completion();
        }
    }];
}

// 有一些 系统内部类, 无法重写, 这里就给出一个列表来进行修改
static NSDictionary <NSString *,UIViewControllerRotationModel *>* _rotation_preferenceRotateInternalClassModel;
- (NSDictionary <NSString *,UIViewControllerRotationModel *>*)rotation_preferenceRotateInternalClassModel {
    if (!_rotation_preferenceRotateInternalClassModel) {
        _rotation_preferenceRotateInternalClassModel = @{
                                                @"AVFullScreenViewController": [[UIViewControllerRotationModel alloc] initWithCls:@"AVFullScreenViewController"
                                                                                                                 shouldAutorotate:YES
                                                                                                   supportedInterfaceOrientations:UIInterfaceOrientationMaskAll
                                                                                     preferredInterfaceOrientationForPresentation:UIInterfaceOrientationPortrait
                                                                                                          preferredStatusBarStyle:UIStatusBarStyleDefault
                                                                                                           prefersStatusBarHidden:NO],
                                                
                                                @"UIAlertController": [[UIViewControllerRotationModel alloc] initWithCls:@"UIAlertController"
                                                                                                        shouldAutorotate:YES
                                                                                          supportedInterfaceOrientations:UIInterfaceOrientationMaskAll
                                                                            preferredInterfaceOrientationForPresentation:UIInterfaceOrientationPortrait
                                                                                                 preferredStatusBarStyle:UIStatusBarStyleDefault
                                                                                                  prefersStatusBarHidden:NO],

                                                };
    }
    return _rotation_preferenceRotateInternalClassModel;
}

/**
 * 默认所有都不支持转屏,如需个别页面支持除竖屏外的其他方向，请在viewController重写这三个方法
 */
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.shouldAutorotate;
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.supportedInterfaceOrientations;
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.preferredInterfaceOrientationForPresentation;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.preferredStatusBarStyle;
    return topVC == self ? UIStatusBarStyleDefault : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.prefersStatusBarHidden;
    return topVC == self ? NO : topVC.prefersStatusBarHidden;
}

- (UIViewController *)rotation_findTopViewController {
    UIViewController *result;
    if ([self isKindOfClass:UINavigationController.class]) {
        result = ((UINavigationController *)self).topViewController.rotation_findTopViewController;
    } else if ([self isKindOfClass:UITabBarController.class]) {
        result = ((UITabBarController *)self).selectedViewController.rotation_findTopViewController;
    } else {
        /// 在系统进行跳转的时候 会有一个中间态 这个中间态不需要处理
        NSArray <NSString *>* excludeCls = @[@"UISnapshotModalViewController"];
        /// 当前控制器 模态的Controller
        UIViewController *presentedVC = self.presentedViewController;
        if (presentedVC != nil && ![excludeCls containsObject:NSStringFromClass(presentedVC.class)]) {
            result = self.presentedViewController.rotation_findTopViewController;
        } else if ([excludeCls containsObject:NSStringFromClass(self.class)]) {
            /// 模态出当前控制器的Controller
            result = self.presentingViewController;
        } else {
            result = self;
        }
    }
    result = result ?: self;
    if (result.rotation_isDissmissing) {
        result = result.rotation_findLastNotDismissController;
    }
    return result;
}

- (UIViewController *)rotation_findLastNotDismissController {
    NSArray <NSString *>* excludeCls = @[@"UISnapshotModalViewController"];
    UIViewController *result = self;
    while (result.rotation_isDissmissing && ![excludeCls containsObject:NSStringFromClass(result.class)]) {
        result = self.presentingViewController;
    }
    return result;
}
@end


/*
 在这里 UINavigationController和UITabBarController 必须重写
 因为当 默认的UINavigationController和UITabBarController 创建的时候内部也重写了这些方法
 这里要把它再重写掉
 */

@implementation UINavigationController (Rotation)

/**
 * 默认所有都不支持转屏,如需个别页面支持除竖屏外的其他方向，请在viewController重写这三个方法
 */
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.shouldAutorotate;
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.supportedInterfaceOrientations;
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.preferredInterfaceOrientationForPresentation;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.preferredStatusBarStyle;
    return topVC == self ? UIStatusBarStyleDefault : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.prefersStatusBarHidden;
    return topVC == self ? NO : topVC.prefersStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? nil : topVC;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? nil : topVC;
}

@end

@implementation UITabBarController (Rotation)
/**
 * 默认所有都不支持转屏,如需个别页面支持除竖屏外的其他方向，请在viewController重写这三个方法
 */
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.shouldAutorotate;
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.supportedInterfaceOrientations;
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.preferredInterfaceOrientationForPresentation;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.preferredStatusBarStyle;
    return topVC == self ? UIStatusBarStyleDefault : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference) return preference.prefersStatusBarHidden;
    return topVC == self ? NO : topVC.prefersStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? nil : topVC;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? nil : topVC;
}

@end


@implementation UIApplication (Rotation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _exchangeClassInstanceMethod(self.class, @selector(setDelegate:), @selector(hook_setDelegate:));
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



//
//  UIViewController+Rotation.m
//  wmICIOS
//
//  Created by 赵国庆 on 2018/7/11.
//  Copyright © 2018年 yy. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 屏幕旋转控制类, 耦合性低, 但有些许的侵入性,
 
 使用情景:
    现在市面上大部分app 并不是所有页面都可以旋转屏幕, 一般只有些许几个页面需要旋转屏幕, 比如查看文档, 观看视频等界面.
    这个扩展应运而生, 专门管理这个旋转状态, 默认界面都禁止旋转, 需要旋转的界面重写系统方法即可.
 
 为什么用OC:
    如果按照一般的写法, 就应该是创建BaseViewController, BaseNavigationController, BaseTabBarController 这三个基类,
    修改其 shouldAutorotate, supportedInterfaceOrientations, preferredInterfaceOrientationForPresentation 方法来实现个别界面旋转效果
    但是这样项目的耦合性就非常大, 需要所有类都进行继承.
 
 使用方法:
    只需要在项目中引入文件, 在需要旋转的界面重写 shouldAutorotate, supportedInterfaceOrientations, preferredInterfaceOrientationForPresentation 这三个方法即可 非常低耦合
 */


@interface UIViewController (Rotation)
@end

@interface UITabBarController (Rotation)
@end

@interface UINavigationController (Rotation)
@end

@interface UIAlertController (Rotation)
@end

@interface UIApplication (Rotation)
@end

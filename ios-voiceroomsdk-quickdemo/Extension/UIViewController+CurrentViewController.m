//
//  UIViewController+CurrentViewController.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by xuefeng on 2021/11/5.
//

#import "UIViewController+CurrentViewController.h"

@implementation UIViewController (CurrentViewController)
+ (UIViewController *)vrs_currentViewController {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self vrs_findCurrentShowingViewControllerFromVC:vc];
    return currentVC;
}

+ (UIViewController *)vrs_findCurrentShowingViewControllerFromVC:(UIViewController *)vc {
    UIViewController *currentVC;
    if ([vc presentedViewController]) {
        //判断当前根视图有没有present视图出来
        UIViewController *nextVC = [vc presentedViewController];
        currentVC = [self vrs_findCurrentShowingViewControllerFromVC:nextVC];
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        //判断当前根视图是UITabBarController
        UIViewController *nextVC = [(UITabBarController*)vc selectedViewController];
        currentVC = [self vrs_findCurrentShowingViewControllerFromVC:nextVC];
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        //判断当前根视图是UINavigationController
        UIViewController *nextVC = [(UINavigationController *)vc visibleViewController];
        currentVC = [self vrs_findCurrentShowingViewControllerFromVC:nextVC];
    }else {
        currentVC = vc;
    }
    return vc;
}

@end

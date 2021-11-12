//
//  LoginViewController.h
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController

/// 初始化方法
/// @param viewController 登录成功后跳转的VC
- (instancetype)initWithHomeViewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END

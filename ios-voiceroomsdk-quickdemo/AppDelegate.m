//
//  AppDelegate.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/8/17.
//

#import "AppDelegate.h"
#import <RCVoiceRoomLib/RCVoiceRoomLib.h>
#import "RoomListViewController.h"
#import <SVProgressHUD.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import "User.h"
#import "UserManager.h"
#import "LoginViewController.h"
#import "LaunchManager.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

/*
 融云key可在开发者后台获取
 demo使用的是临时token，可以在开发者后台调用接口获得
 正式环境中，请从自己的服务器通过接口获取
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIViewController *rootVC;
    if ([UserManager isLogin]) {
        [WebService shareInstance].auth = [UserManager sharedManager].currentUser.authorization;
        rootVC =  [[RoomListViewController alloc] init];
        //LaunchManager初始化语音房SDK
        [LaunchManager initSDKWithAppKey:AppKey imToken:[UserManager sharedManager].currentUser.token completion:^(BOOL success, RCConnectErrorCode code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"连接融云成功，当前id%@", [UserManager sharedManager].currentUser.userId]];
                    Log("voice sdk initializ success");
                } else {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"连接融云失败 code: %ld",code]];
                    Log("voice sdk initializ fail %ld",(long)code);
                }
            });
        }];
    } else {
        rootVC = [[LoginViewController alloc] initWithHomeViewController:[[RoomListViewController alloc] init]];
    }
    
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

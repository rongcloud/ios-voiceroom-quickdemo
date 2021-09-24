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

@interface AppDelegate ()


@end

@implementation AppDelegate

/*
 融云key可在开发者后台获取
 demo使用的是临时token，可以在开发者后台调用接口获得
 正式环境中，请从自己的服务器通过接口获取
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupThirdParty];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    RoomListViewController *listVC = [[RoomListViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:listVC];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Setup Thirdparty library

- (void)setupThirdParty {
    // currentUser 代表当前用户
    // 在测试时可以用两台设备测试，两台设备的使用不同的用户初始化
    // 可在开发者后台，通过API调用生成用户和token
   
    User *currentUser = [[User alloc] initWithUserId:@"" withToken:@""];
    [UserManager sharedManager].currentUser = currentUser;
    NSString *appKey = @"";
    
    // 这里可以用融云IM进行初始化也可以用语聊房sdk初始化
    [self useVoiceRoomInit:appKey withUser:[UserManager sharedManager].currentUser];
    
}

// 融云IM初始化方法
- (void)useRongIMInit:(NSString *)appKey withUser:(User *)user {
    [[RCCoreClient sharedCoreClient] initWithAppKey:appKey];
    [[RCCoreClient sharedCoreClient] connectWithToken:user.token dbOpened:^(RCDBErrorCode code) {

    } success:^(NSString *userId) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"连接融云成功，当前id%@", userId]];
    } error:^(RCConnectErrorCode errorCode) {

    }];
}

// 融云语聊房初始化
- (void)useVoiceRoomInit:(NSString *)appKey withUser:(User *)user {
    [[RCVoiceRoomEngine sharedInstance] initWithAppkey:appKey];
    [[RCVoiceRoomEngine sharedInstance] connectWithToken:user.token success:^{
        NSLog(@"connect success");
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"连接融云成功，当前id%@", [UserManager sharedManager].currentUser.userId]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        NSLog(@"connect failed, %@", msg);
        [SVProgressHUD showErrorWithStatus:[@"连接融云失败" stringByAppendingString:msg]];
    }];
}

@end

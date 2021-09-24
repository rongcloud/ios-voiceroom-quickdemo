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
    // appkey为您的融云key
    // currentUser 代表当前用户，otherUser代表其他用户
    // 在测试时可以用两台设备测试，两台设备的currentUser和otherUser互相相反就行
    // 在开发者后台中按照readme教程申请两个token，使用两台设备分别用不同的User 运行demo。即可测试两个用户在同一个语聊房
    User *currentUser = [[User alloc] initWithUserId:@"" withToken:@""];
    User *otherUser = [[User alloc] initWithUserId:@"" withToken:@""];
    [UserManager sharedManager].currentUser = currentUser;
    [UserManager sharedManager].otherUser = otherUser;
    NSString *appKey = @"";
    
    // 这里可以用融云IM进行初始化也可以用语聊房sdk初始化
    [self useVoiceRoomInit:appKey withUser:currentUser];
    
}

// 融云IM初始化方法
- (void)useRongIMInit:(NSString *)appKey withUser:(User *)user {
    [[RCCoreClient sharedCoreClient] initWithAppKey:appKey];
    [[RCCoreClient sharedCoreClient] connectWithToken:user.token dbOpened:^(RCDBErrorCode code) {

    } success:^(NSString *userId) {

    } error:^(RCConnectErrorCode errorCode) {

    }];
}

// 融云语聊房初始化
- (void)useVoiceRoomInit:(NSString *)appKey withUser:(User *)user {
    [[RCVoiceRoomEngine sharedInstance] initWithAppkey:appKey];
    [[RCVoiceRoomEngine sharedInstance] connectWithToken:user.token success:^{
        NSLog(@"connect success");
        [SVProgressHUD showSuccessWithStatus:@"连接融云成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        NSLog(@"connect failed, %@", msg);
        [SVProgressHUD showErrorWithStatus:[@"连接融云失败" stringByAppendingString:msg]];
    }];
}

@end

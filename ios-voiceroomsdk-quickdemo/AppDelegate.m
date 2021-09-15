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
    NSString *appKey = @"pvxdm17jpwh7r";
    NSString *token1 = @"J7l5qEUFD2UOstvSmbkyTa0Oah91uycXlawyBR/l+NA=@4vsh.cn.rongnav.com;4vsh.cn.rongcfg.com";
    NSString *token2 = @"g6oGiwYubKQg4Nnxj+zoE+GKGVVACgMzE/ZdVCQ622M=@4vsh.cn.rongnav.com;4vsh.cn.rongcfg.com";
    // 通过语聊房初始化的好处在于不用再初始化融云的IMLib 和 IMKit了。所以最好使用语聊房初始化替代之前的RCCoreClient
    [[RCVoiceRoomEngine sharedInstance] initWithAppkey:appKey];
    [[RCVoiceRoomEngine sharedInstance] connectWithToken:token2 success:^{
        NSLog(@"connect success");
        [SVProgressHUD showSuccessWithStatus:@"连接融云成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        NSLog(@"connect failed, %@", msg);
        [SVProgressHUD showErrorWithStatus:[@"连接融云失败" stringByAppendingString:msg]];
    }];
}

@end

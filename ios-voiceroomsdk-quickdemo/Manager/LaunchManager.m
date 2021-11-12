//
//  LaunchManager.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by xuefeng on 2021/11/2.
//

#import "LaunchManager.h"

@implementation LaunchManager

+ (void)initSDKWithAppKey:(NSString *)appKey
                  imToken:(NSString *)imToken
               completion:(LaunchManagerCompletion)completion {
    // 这里可以用融云IM进行初始化也可以用语聊房sdk初始化
    // 此处选择语聊房sdk初始化
    [self useVoiceRoomInit:appKey withImToken:imToken completion:completion];
}

// 融云IM初始化方法 @ __attribute__((deprecate))?
+ (void)useRongIMInit:(NSString *)appKey
          withImToken:(NSString *)imToken
           completion:(LaunchManagerCompletion)completion {
    [[RCCoreClient sharedCoreClient] initWithAppKey:appKey];
    [[RCCoreClient sharedCoreClient] connectWithToken:imToken dbOpened:^(RCDBErrorCode code) {
        
    } success:^(NSString *userId) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"连接融云成功，当前id%@", userId]];
    } error:^(RCConnectErrorCode errorCode) {

    }];
}

// 融云语聊房初始化
+ (void)useVoiceRoomInit:(NSString *)appKey
             withImToken:(NSString *)imToken
              completion:(LaunchManagerCompletion)completion{
    [[RCVoiceRoomEngine sharedInstance] initWithAppkey:appKey];
    [[RCVoiceRoomEngine sharedInstance] connectWithToken:imToken success:^{
        if (completion) {
            completion(YES,0);
        }
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        if (completion) {
            completion(NO,code);
        }
    }];
}
@end

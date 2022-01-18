//
//  LaunchManager.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by xuefeng on 2021/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LaunchManagerCompletion)(BOOL success, RCConnectErrorCode code);

@interface LaunchManager : NSObject

/// 初始化 语聊房SDK
/// @param appKey  官网申请的appkey
/// @param imToken 登录成功后返回的用户信息，用于登录im服务
/// @param completion 初始化完成回调
+ (void)initSDKWithAppKey:(NSString *)appKey
                  imToken:(NSString *)imToken
               completion:(LaunchManagerCompletion _Nullable)completion;
@end

NS_ASSUME_NONNULL_END

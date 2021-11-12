//
//  User.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, copy) NSString *userId; //用户id
@property (nonatomic, copy) NSString *token;  //登录im的token
@property (nonatomic, copy) NSString *userName; //用户名
@property (nonatomic, copy) NSString *authorization; //业务接口需要的auth字符串


/// 获取当前用户信息
+ (instancetype)currentUser;


/// 持久化当前的用户信息
/// @return 是否保存成功
- (BOOL)save;
@end

NS_ASSUME_NONNULL_END

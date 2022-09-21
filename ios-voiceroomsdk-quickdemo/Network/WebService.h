//
//  WebService.h
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/25.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


typedef NS_ENUM(NSUInteger, RoomType) {
    RoomTypeVoice = 1,
    RoomTypeRadio,
    RoomTypeVideo,
};

typedef void(^SuccessCompletion)(id _Nullable responseObject);

typedef void(^FailureCompletion)(NSError * _Nonnull error);


NS_ASSUME_NONNULL_BEGIN

@interface WebService : AFHTTPSessionManager

//业务方签名 登录接口获取
@property (nonatomic, copy, readwrite) NSString *auth;

/// 获取实例
+ (instancetype)shareInstance;


/// GET 请求
/// @param URLString  path url
/// @param parameters 入参
/// @param auth  接口是否需要签名
/// @param responseClass  返回对象类型 缺省值为字典
/// @param success 成功回调
/// @param failure 失败回调
+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(nullable id)parameters
                         auth:(BOOL)auth
                responseClass:(nullable Class)responseClass
                      success:(nullable SuccessCompletion)success
                      failure:(nullable FailureCompletion)failure;

/// POST 请求
/// @param URLString path url
/// @param parameters 入参
/// @param auth 接口是否需要签名
/// @param responseClass 返回对象类型 缺省值为字典
/// @param success 成功回调
/// @param failure 失败回调
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
                          auth:(BOOL)auth
                 responseClass:(nullable Class)responseClass
                       success:(nullable SuccessCompletion)success
                       failure:(nullable FailureCompletion)failure;

/// 登录
/// @param number 电话号码
/// @param verifyCode 验证码   //测试环境验证码可以输入任意值
/// @param deviceId  设备ID UUIDString
/// @param userName 昵称
/// @param portrait 头像
/// @param success 成功回调
/// @param failure 失败回调
+ (void)loginWithPhoneNumber:(NSString *)number
                  verifyCode:(NSString *)verifyCode
                    deviceId:(NSString *)deviceId
                    userName:(nullable NSString *)userName
                    portrait:(nullable NSString *)portrait
               responseClass:(nullable Class)responseClass
                     success:(nullable SuccessCompletion)success
                     failure:(nullable FailureCompletion)failure;


/// 创建房间列表
/// @param name 房间名
/// @param isPrivate  是否是私密房间  0 否  1 是
/// @param backgroundUrl 背景图片
/// @param themePictureUrl 主题照片
/// @param password  私密房间密码MD5
/// @param type  房间类型  1.语聊 2.电台  3.直播
/// @param kv  保留值，可缺省传空
/// @param success 成功回调
/// @param failure 失败回调
+ (void)createRoomWithName:(NSString *)name
                 isPrivate:(NSInteger)isPrivate
             backgroundUrl:(NSString *)backgroundUrl
           themePictureUrl:(NSString *)themePictureUrl
                  password:(NSString *)password
                      type:(NSInteger)type
                        kv:(NSArray <NSDictionary *>*)kv
             responseClass:(nullable Class)responseClass
                   success:(nullable SuccessCompletion)success
                   failure:(nullable FailureCompletion)failure;


+ (void)checkCreatedRoom:(NSInteger)type
             responseClass:(nullable Class)responseClass
                   success:(nullable SuccessCompletion)success
                 failure:(nullable FailureCompletion)failure;

/// 删除房间
/// @param roomId 房间ID
/// @param success 成功回调
/// @param failure 失败回调
+ (void)deleteRoomWithRoomId:(NSString *)roomId
                     success:(nullable SuccessCompletion)success
                     failure:(nullable FailureCompletion)failure;


/// 房间列表
/// @param size 返回数据量
/// @param page 分页
/// @param type 房间类型 1.语聊 2.电台  3.直播
/// @param success 成功回调
/// @param failure 失败回调
+ (void)roomListWithSize:(NSInteger)size
                    page:(NSInteger)page
                    type:(RoomType)type
           responseClass:(nullable Class)responseClass
                 success:(nullable SuccessCompletion)success
                 failure:(nullable FailureCompletion)failure;


/// 获取直播间内的用户
/// @param roomId  房间id
/// @param success 成功回调
/// @param failure 失败回调
+ (void)roomUserListWithRoomId:(NSString *)roomId
                 responseClass:(nullable Class)responseClass
                       success:(nullable SuccessCompletion)success
                       failure:(nullable FailureCompletion)failure;

/// 批量获取用户信息
/// @param uids  用户uid列表
/// @param success 成功回调
/// @param failure 失败回调
+ (void)fetchUserInfoListWithUids:(NSArray<NSString *>*)uids
                    responseClass:(nullable Class)responseClass
                          success:(nullable SuccessCompletion)success
                          failure:(nullable FailureCompletion)failure;

/// 更新房间在线状态
/// @param roomId 房间ID
+ (void)updateOnlineRoomStatusWithRoomId:(NSString *)roomId
                           responseClass:(nullable Class)responseClass
                                 success:(nullable SuccessCompletion)success
                                 failure:(nullable FailureCompletion)failure;
@end

NS_ASSUME_NONNULL_END

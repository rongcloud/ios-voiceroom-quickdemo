//
//  WebService.m
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/25.
//

#import "WebService.h"
#import "YYModel.h"
#import "NetworkConst.h"

static NSDictionary * _header() {
    NSString *businessToken = BusinessToken;
    if (businessToken == nil || businessToken.length == 0) {
        Log(@"businessToken must be nonnull");
        assert(0);
    }
    return @{
        @"Content-Type":@"application/json;charset=UTF-8",
        @"BusinessToken":BusinessToken,
    };
};

static inline void _responseHandler(Class responseClase, NSDictionary *responseObject, SuccessCompletion success) {
    if (responseClase == nil) {
        success(responseObject);
    } else {
        
        id resobj = [responseClase yy_modelWithDictionary:responseObject];

        success(resobj);
    }
}

@implementation WebService

+ (instancetype)shareInstance {
    static dispatch_once_t once;
    static id shareInstance;
    dispatch_once(&once, ^{
        NSAssert(kHost != nil && kHost.length > 0, @"kHost must be non-empty");
        shareInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kHost]];
        [shareInstance setRequestSerializer:[AFJSONRequestSerializer serializer]];
    });
    return shareInstance;
}

+ (void)loginWithPhoneNumber:(NSString *)number
                  verifyCode:(NSString *)verifyCode
                    deviceId:(NSString *)deviceId
                    userName:(nullable NSString *)userName
                    portrait:(nullable NSString *)portrait
               responseClass:(nullable Class)responseClass
                     success:(nullable SuccessCompletion)success
                     failure:(nullable FailureCompletion)failure {
    
    NSMutableDictionary *param = [@{
        @"mobile":number,
        @"verifyCode":verifyCode,
        @"deviceId":deviceId,
    } mutableCopy];
    
    if (userName != nil && userName.length > 0) {
        param[@"userName"] = userName;
    }
    
    if (portrait != nil && portrait.length > 0) {
        param[@"portrait"] = portrait;
    }
    
    [[self shareInstance] POST:np_login parameters:param auth:NO responseClass:responseClass success:success failure:failure];
}

+ (void)createRoomWithName:(NSString *)name
                 isPrivate:(NSInteger)isPrivate
             backgroundUrl:(NSString *)backgroundUrl
           themePictureUrl:(NSString *)themePictureUrl
                  password:(NSString *)password
                      type:(NSInteger)type
                        kv:(NSArray <NSDictionary *>*)kv
             responseClass:(nullable Class)responseClass
                   success:(nullable SuccessCompletion)success
                   failure:(nullable FailureCompletion)failure {
    NSDictionary *param = @{
        @"name":name,
        @"isPrivate":@(isPrivate),
        @"backgroundUrl":backgroundUrl,
        @"themePictureUrl":themePictureUrl,
        @"roomType":@(type),
        @"password":password,
        @"kv":kv,
    };
    
    [[self shareInstance] POST:np_room_creat parameters:param auth:YES responseClass:responseClass success:success failure:failure];
    
}

+ (void)deleteRoomWithRoomId:(NSString *)roomId
                     success:(nullable SuccessCompletion)success
                     failure:(nullable FailureCompletion)failure {
    [[self shareInstance] GET:[NSString stringWithFormat:np_room_delete,roomId] parameters:nil auth:YES responseClass:nil success:success failure:failure];
}

+ (void)roomListWithSize:(NSInteger)size
                    page:(NSInteger)page
                    type:(RoomType)type
           responseClass:(nullable Class)responseClass
                 success:(nullable SuccessCompletion)success
                 failure:(nullable FailureCompletion)failure {
    NSDictionary *param = @{
        @"size":@(size),
        @"page":@(page),
        @"type":@(type),
    };
    [[self shareInstance] GET:np_room_list parameters:param auth:YES responseClass:responseClass success:success failure:failure];
}


+ (void)roomUserListWithRoomId:(NSString *)roomId
                 responseClass:(nullable Class)responseClass
                       success:(nullable SuccessCompletion)success
                       failure:(nullable FailureCompletion)failure {
    [[self shareInstance] GET:[NSString stringWithFormat:np_room_users_list,roomId] parameters:nil auth:YES responseClass:responseClass success:success failure:failure];
}

+ (void)fetchUserInfoListWithUids:(NSArray<NSString *>*)uids
                    responseClass:(nullable Class)responseClass
                          success:(nullable SuccessCompletion)success
                          failure:(nullable FailureCompletion)failure {
    NSDictionary *param = @{
        @"userIds":uids,
    };
    [[self shareInstance] POST:np_fetch_user_info parameters:param auth:YES responseClass:responseClass success:success failure:failure];
}

+ (void)updateOnlineRoomStatusWithRoomId:(NSString *)roomId
                           responseClass:(nullable Class)responseClass
                                 success:(nullable SuccessCompletion)success
                                 failure:(nullable FailureCompletion)failure {
    [self GET:np_update_room_online_status parameters:@{@"roomId":roomId} auth:YES responseClass:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
                          auth:(BOOL)auth
                 responseClass:(nullable Class)responseClass
                       success:(nullable SuccessCompletion)success
                       failure:(nullable FailureCompletion)failure {
    return [[self shareInstance] POST:URLString parameters:parameters auth:auth responseClass:responseClass success:success failure:failure];
}

+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(nullable id)parameters
                         auth:(BOOL)auth
                responseClass:(nullable Class)responseClass
                      success:(nullable SuccessCompletion)success
                      failure:(nullable FailureCompletion)failure {
    return [[self shareInstance] GET:URLString parameters:parameters auth:auth responseClass:responseClass success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
                          auth:(BOOL)auth
                 responseClass:(nullable Class)responseClass
                       success:(nullable SuccessCompletion)success
                       failure:(nullable FailureCompletion)failure {
    
    NSDictionary *header = _header();
    
    if (auth && self.auth != nil) {
        NSMutableDictionary *val = [[NSMutableDictionary alloc] initWithDictionary:header];
        [val setValue:self.auth forKey:@"Authorization"];
        header = [val copy];
    }
    
    return [self POST:URLString parameters:parameters headers:header progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            _responseHandler(responseClass, responseObject, success);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            Log(@"request error \n url = %@ \n error code = %ld \n msg = %@ \n",URLString,(long)error.code,error.description);
        }
    }];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(nullable id)parameters
                         auth:(BOOL)auth
                responseClass:(nullable Class)responseClass
                      success:(nullable SuccessCompletion)success
                      failure:(nullable FailureCompletion)failure  {
    
    NSDictionary *header = _header();
    
    if (auth && self.auth != nil) {
        NSMutableDictionary *val = [[NSMutableDictionary alloc] initWithDictionary:header];
        [val setValue:self.auth forKey:@"Authorization"];
        header = [val copy];
    }
    
    return [self GET:URLString parameters:parameters headers:header progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            _responseHandler(responseClass, responseObject, success);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            Log(@"request error \n url = %@ \n error code = %ld \n msg = %@ \n",URLString,(long)error.code,error.description);
        }
    }];
}
@end

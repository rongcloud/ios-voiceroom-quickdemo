#import <Foundation/Foundation.h>

@class LoginResponse;
@class LoginResponseData;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface LoginResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) LoginResponseData *data;
@end

@interface LoginResponseData : NSObject
@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, copy)   NSString *userName;
@property (nonatomic, copy)   NSString *portrait;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy)   NSString *authorization;
@property (nonatomic, copy)   NSString *imToken;
@end

NS_ASSUME_NONNULL_END

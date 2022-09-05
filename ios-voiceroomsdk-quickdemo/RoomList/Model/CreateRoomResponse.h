#import <Foundation/Foundation.h>

@class CreateRoomResponse;
@class RCSceneRoom;
@class RCSceneRoomUser;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface CreateRoomResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, strong) RCSceneRoom *data;
@end

@interface RCSceneRoom : NSObject
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, copy)   NSString *roomId;
@property (nonatomic, copy)   NSString *roomName;
@property (nonatomic, copy)   NSString *themePictureUrl;
@property (nonatomic, copy)   NSString *backgroundUrl;
@property (nonatomic, assign) NSInteger isPrivate;
@property (nonatomic, copy)   NSString *password;
@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, assign) NSInteger updateDt;
@property (nonatomic, strong) RCSceneRoomUser *createUser;
@property (nonatomic, assign) NSInteger roomType;
@property (nonatomic, assign) NSInteger userTotal;
@property (nonatomic, assign) BOOL isStop;
@end

@interface RCSceneRoomUser : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *portrait;
@end

NS_ASSUME_NONNULL_END

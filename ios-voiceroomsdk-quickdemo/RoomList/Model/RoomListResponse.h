#import <Foundation/Foundation.h>

@class RoomListResponse;
@class RoomListData;
@class RoomListRoom;
@class RoomListCreateUser;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface RoomListResponse : NSObject
@property (nonatomic, nullable, strong) NSNumber *code;
@property (nonatomic, nullable, strong) NSString *msg;
@property (nonatomic, nullable, strong) RoomListData *data;
@end

@interface RoomListData : NSObject
@property (nonatomic, nullable, strong) NSNumber *totalCount;
@property (nonatomic, nullable, copy)   NSArray<RoomListRoom *> *rooms;
@property (nonatomic, nullable, copy)   NSArray<NSString *> *images;
@end

@interface RoomListRoom : NSObject
@property (nonatomic, nullable, strong) NSNumber *id;
@property (nonatomic, nullable, copy)   NSString *roomId;
@property (nonatomic, nullable, copy)   NSString *roomName;
@property (nonatomic, nullable, copy)   NSString *themePictureUrl;
@property (nonatomic, nullable, copy)   NSString *backgroundUrl;
@property (nonatomic, nullable, strong) NSNumber *isPrivate;
@property (nonatomic, nullable, copy)   NSString *password;
@property (nonatomic, nullable, copy)   NSString *userId;
@property (nonatomic, nullable, strong) NSNumber *updateDt;
@property (nonatomic, nullable, strong) RoomListCreateUser *createUser;
@property (nonatomic, nullable, strong) NSNumber *roomType;
@property (nonatomic, nullable, strong) NSNumber *userTotal;
@property (nonatomic, nullable, strong) NSNumber *stop;
@end

@interface RoomListCreateUser : NSObject
@property (nonatomic, nullable, copy) NSString *userId;
@property (nonatomic, nullable, copy) NSString *userName;
@property (nonatomic, nullable, copy) NSString *portrait;
@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>

@class RoomUserListResponse;
@class RoomUser;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface RoomUserListResponse : NSObject
@property (nonatomic, nullable, strong) NSNumber *code;
@property (nonatomic, nullable, copy)   NSString *msg;
@property (nonatomic, nullable, copy)   NSArray<RoomUser *> *data;
@end

@interface RoomUser : NSObject
@property (nonatomic, nullable, copy) NSString *userId;
@property (nonatomic, nullable, copy) NSString *userName;
@property (nonatomic, nullable, copy) NSString *portrait;
@end

NS_ASSUME_NONNULL_END

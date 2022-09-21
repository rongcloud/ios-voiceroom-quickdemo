#import <Foundation/Foundation.h>

@class RoomListResponse;
@class RoomListData;
@class RoomListRoom;

#import "RoomResponse.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface RoomListResponse : NSObject
@property (nonatomic, nullable, strong) NSNumber *code;
@property (nonatomic, nullable, strong) NSString *msg;
@property (nonatomic, nullable, strong) RoomListData *data;
@end

@interface RoomListData : NSObject
@property (nonatomic, nullable, strong) NSNumber *totalCount;
@property (nonatomic, nullable, copy)   NSArray<RCSceneRoom *> *rooms;
@property (nonatomic, nullable, copy)   NSArray<NSString *> *images;
@end


NS_ASSUME_NONNULL_END

#import "RoomListResponse.h"

@implementation RoomListResponse
@end

@implementation RoomListData
- (void)setRooms:(NSArray<RoomListRoom *> *)rooms {
    if (rooms != nil && rooms.count > 0 && [rooms.firstObject isKindOfClass:[NSDictionary class]]) {
        _rooms = [rooms vrs_jsonsToModelsWithClass:[RoomListRoom class]];
    } else {
        _rooms = rooms;
    }
}
@end

@implementation RoomListRoom
@end

@implementation RoomListCreateUser
@end

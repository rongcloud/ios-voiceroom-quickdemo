#import "RoomListResponse.h"

@implementation RoomListResponse
@end

@implementation RoomListData
- (void)setRooms:(NSArray<RCSceneRoom *> *)rooms {
    if (rooms != nil && rooms.count > 0 && [rooms.firstObject isKindOfClass:[NSDictionary class]]) {
        _rooms = [rooms vrs_jsonsToModelsWithClass:[RCSceneRoom class]];
    } else {
        _rooms = rooms;
    }
}
@end

 


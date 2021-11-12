#import "RoomUserListResponse.h"

@implementation RoomUserListResponse
- (void)setData:(NSArray<RoomUser *> *)data {
    _data = [data vrs_jsonsToModelsWithClass:[RoomUser class]];
}
@end

@implementation RoomUser
@end

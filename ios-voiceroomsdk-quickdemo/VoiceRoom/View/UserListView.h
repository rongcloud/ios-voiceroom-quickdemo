//
//  UserListView.h
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/28.
//

#import <UIKit/UIKit.h>
#import "RoomUserListResponse.h"

typedef NS_ENUM(NSUInteger, UserListType) {
    UserListTypeRequest = 1,
    UserListTypeRoomInvite,
    UserListTypeRoomUser,
    UserListTypeRoomCreator,
};

typedef NS_ENUM(NSUInteger, UserListAction) {
    UserListActionAgree = 1,
    UserListActionReject,
    UserListActionInvite,
    UserListActionCancelInvite,
    UserListActionKick,
};


typedef void(^UserListHandler)(NSString *_Nonnull uid,NSInteger action);

NS_ASSUME_NONNULL_BEGIN

@interface UserListView : UIView
@property (nonatomic, assign, readonly, getter=isHost) BOOL host;
@property (nonatomic, copy) UserListHandler handler;
@property (nonatomic, assign) UserListType listType;

- (instancetype)initWithHost:(BOOL)host;
- (void)reloadDataWithUsers:(NSArray <RoomUser *>*)users;
- (void)show;
- (void)dismiss;


@end

NS_ASSUME_NONNULL_END

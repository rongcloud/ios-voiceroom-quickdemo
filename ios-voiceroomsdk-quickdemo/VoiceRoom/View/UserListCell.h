//
//  UserListCell.h
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/28.
//

#import <UIKit/UIKit.h>

extern NSString *const UserListCellIdentifier;

typedef NS_ENUM(NSUInteger, UserListCellStyle) {
    UserListCellStyleDefault = 1,
    UserListCellStyleKick,
    UserListCellStyleRequest,
    UserListCellStyleCancelInvite,
    UserListCellStylePKCreator,
};

typedef NS_ENUM(NSUInteger, UserListCellAction) {
    UserListCellActionAgree = 1,
    UserListCellActionReject,
    UserListCellActionInvite,
    UserListCellActionCancelInvite,
    UserListCellActionKick,
    UserListCellActionPKInvite,
    UserListCellActionPKCancel,
};


typedef void(^UserListCellHandler)(UserListCellAction action);

NS_ASSUME_NONNULL_BEGIN

@interface UserListCell : UITableViewCell
@property (nonatomic, assign)UserListCellStyle cellStyle;
@property (nonatomic, copy)UserListCellHandler handler;


- (void)updateRoomName:(NSString *)roomName roomId:(NSString *)roomId;

@end

NS_ASSUME_NONNULL_END

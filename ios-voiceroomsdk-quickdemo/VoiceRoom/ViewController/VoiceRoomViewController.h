//
//  VoiceRoomViewController.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/10.
//

#import <UIKit/UIKit.h>
#import <RCVoiceRoomLib/RCVoiceRoomLib.h>
@class UserListView;

NS_ASSUME_NONNULL_BEGIN

@interface VoiceRoomViewController : UIViewController

- (instancetype)initWithJoinRoomId:(NSString *)roomId;

- (instancetype)initWithRoomId:(NSString *)roomId
                      roomInfo:(RCVoiceRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END

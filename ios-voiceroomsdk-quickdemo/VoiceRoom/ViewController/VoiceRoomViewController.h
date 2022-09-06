//
//  VoiceRoomViewController.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/10.
//

#import <UIKit/UIKit.h>
#import <RCVoiceRoomLib/RCVoiceRoomLib.h>
#import "RoomResponse.h"

@class UserListView;

@interface VoiceRoomViewController : UIViewController

- (instancetype)initWithRoom:(RCSceneRoom *)roomResp roomInfo:(RCVoiceRoomInfo *)roomInfo;

@end


//
//  RoomInfo.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/15.
//

#import <Foundation/Foundation.h>
#import <RCVoiceRoomLib/RCVoiceRoomLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomInfo : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) RCVoiceRoomInfo *roomInfo;

@end

NS_ASSUME_NONNULL_END

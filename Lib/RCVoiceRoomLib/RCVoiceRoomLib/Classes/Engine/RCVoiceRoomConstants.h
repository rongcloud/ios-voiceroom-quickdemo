//
//  RCVoiceRoomConstants.h
//  RCE
//
//  Created by 叶孤城 on 2021/6/18.
//
#ifndef RCVoiceRoomConstants_h
#define RCVoiceRoomConstants_h

/// 房间信息key
FOUNDATION_EXPORT NSString * const RCRoomInfoKey;
/// 请求连麦
FOUNDATION_EXPORT NSString * const RCRequestSeatPrefixKey;

/// 排麦相关
FOUNDATION_EXPORT NSString * const RCRequestSeatContentRequest;
FOUNDATION_EXPORT NSString * const RCRequestSeatContentAccept;
FOUNDATION_EXPORT NSString * const RCRequestSeatContentCancelled;
FOUNDATION_EXPORT NSString * const RCRequestSeatContentDeny;
/// 踢出房间
FOUNDATION_EXPORT NSString * const RCKickUserOutRoomContent;
/// 邀请上麦
FOUNDATION_EXPORT NSString * const RCPickerUserSeatContent;
/// 用户加入房间
FOUNDATION_EXPORT NSString * const RCAudienceJoinRoom;
/// 用户离开房间
FOUNDATION_EXPORT NSString * const RCAudienceLeaveRoom;
/// 麦克风动态
FOUNDATION_EXPORT NSString * const RCUserOnSeatSpeakingKey;

/// 麦位信息
FOUNDATION_EXPORT NSString * const RCSeatInfoSeatPartPrefixKey;

/// 房间PK信息
FOUNDATION_EXPORT NSString * const RCVoiceRoomPKInfoKey;

/// 静音PK用户的麦克风
FOUNDATION_EXPORT NSString * const RCVoiceRoomPKInfoKey;

/// 忽略PK请求
FOUNDATION_EXPORT NSString * const RCIgnorePKInviteKey;

#endif /* RCVoiceRoomConstants_h */

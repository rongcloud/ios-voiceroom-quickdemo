//
//  RoomListTableViewCell.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/10.
//

#import <UIKit/UIKit.h>
#import "RoomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RoomListTableViewCell : UITableViewCell

- (void)updateCell:(RoomInfo *)info;

@end

NS_ASSUME_NONNULL_END

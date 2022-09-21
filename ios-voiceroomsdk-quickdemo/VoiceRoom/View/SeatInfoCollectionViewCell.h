//
//  SeatInfoCollectionViewCell.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/15.
//

#import <UIKit/UIKit.h>

@class RCVoiceSeatInfo;
NS_ASSUME_NONNULL_BEGIN

@interface SeatInfoCollectionViewCell : UICollectionViewCell

- (void)updateCell:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)seatIndex;

@end

NS_ASSUME_NONNULL_END

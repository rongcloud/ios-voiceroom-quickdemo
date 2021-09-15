//
//  SeatInfoCollectionViewCell.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/15.
//

#import "SeatInfoCollectionViewCell.h"
#import <Masonry.h>
#import <RCVoiceRoomLib/RCVoiceSeatInfo.h>

@interface SeatInfoCollectionViewCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *micStatusImageView;
@property (nonatomic, strong) UILabel *micIndexLabel;

@end

@implementation SeatInfoCollectionViewCell

- (void)buildLayout {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.micIndexLabel];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.size.equalTo(@(CGSizeMake(56, 56)));
    }];
    
    [self.micIndexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - Public Method

- (void)updateCell:(RCVoiceSeatInfo *)seatInfo {
    switch (seatInfo.status) {
        case RCSeatStatusEmpty:
            self.micStatusImageView.image = [UIImage imageNamed:@"plus_user_to_seat_icon"];
            break;
        case RCSeatStatusUsing:
            self.micStatusImageView.image = nil;
        case RCSeatStatusLocking:
            self.micStatusImageView.image = [UIImage imageNamed:@"lock_seat_icon"];
        default:
            break;
    }
    
}

#pragma mark - Lazy Init

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 28;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UIImageView *)micStatusImageView {
    if (!_micStatusImageView) {
        _micStatusImageView = [[UIImageView alloc] init];
        _micStatusImageView.image = [UIImage imageNamed:@"plus_user_to_seat_icon"];
    }
    return _avatarImageView;
}

@end

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
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UILabel *micIndexLabel;

@end

@implementation SeatInfoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    return self;
}

- (void)buildLayout {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.micIndexLabel];
    [self.contentView addSubview:self.micStatusImageView];
    [self.contentView addSubview:self.muteImageView];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.size.equalTo(@(CGSizeMake(56, 56)));
    }];
    
    [self.micIndexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
    }];
    
    [self.micStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.avatarImageView);
        make.size.equalTo(@(CGSizeMake(16, 16)));
    }];
    
    [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.avatarImageView);
    }];
}

#pragma mark - Public Method

- (void)updateCell:(RCVoiceSeatInfo *)seatInfo withSeatIndex:(NSUInteger)index {
    self.micIndexLabel.text = [NSString stringWithFormat:@"第%lu号麦", (unsigned long)index];
    self.avatarImageView.image = [UIImage imageNamed:@"circle_bg"];
    switch (seatInfo.status) {
        case RCSeatStatusEmpty:
            self.micStatusImageView.image = [UIImage imageNamed:@"plus_user_to_seat_icon"];
            break;
        case RCSeatStatusUsing:
            self.micStatusImageView.image = nil;
            if (seatInfo.userId != nil && seatInfo.userId.length > 0) {
                self.micIndexLabel.text = seatInfo.userId;
                self.avatarImageView.image = [UIImage imageNamed:@"avatar1"];
            }
        case RCSeatStatusLocking:
            self.micStatusImageView.image = [UIImage imageNamed:@"lock_seat_icon"];
        default:
            break;
    }
    self.muteImageView.hidden = !seatInfo.isMuted;
    self.micStatusImageView.hidden = (seatInfo.status == RCSeatStatusUsing);
}

#pragma mark - Lazy Init

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 28;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.image = [UIImage imageNamed:@"circle_bg"];
    }
    return _avatarImageView;
}

- (UIImageView *)micStatusImageView {
    if (!_micStatusImageView) {
        _micStatusImageView = [[UIImageView alloc] init];
        _micStatusImageView.image = [UIImage imageNamed:@"plus_user_to_seat_icon"];
        _micStatusImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _micStatusImageView;
}

- (UIImageView *)muteImageView {
    if (!_muteImageView) {
        _muteImageView = [[UIImageView alloc] init];
        _muteImageView.image = [UIImage imageNamed:@"mute_microphone_icon"];
    }
    return _muteImageView;
}

- (UILabel *)micIndexLabel {
    if (!_micIndexLabel) {
        _micIndexLabel = [[UILabel alloc] init];
        _micIndexLabel.textColor = [UIColor whiteColor];
        _micIndexLabel.font = [UIFont systemFontOfSize:12 weight: UIFontWeightRegular];
        _micIndexLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _micIndexLabel;
}

@end

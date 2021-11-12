//
//  RoomListTableViewCell.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/10.
//

#import "RoomListTableViewCell.h"
#import <Masonry.h>

@interface RoomListTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *roomIdLabel;
@property (nonatomic, strong) UIView *container;

@end

@implementation RoomListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildLayout];
    }
    return self;
}

- (void)buildLayout {
    [self.contentView addSubview:self.container];
    [self.container addSubview:self.nameLabel];
    [self.container addSubview:self.roomIdLabel];
    
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(20);
        make.top.bottom.equalTo(self.contentView).inset(10);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container).offset(26);
        make.left.equalTo(self.container).offset(16);
    }];
    
    [self.roomIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
        make.left.equalTo(self.nameLabel);
        make.bottom.equalTo(self.container.mas_bottom).inset(26);
    }];
}

#pragma mark - Lazy Init

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    }
    return _nameLabel;
}

- (UILabel *)roomIdLabel {
    if (!_roomIdLabel) {
        _roomIdLabel = [[UILabel alloc] init];
        _roomIdLabel.textColor = [UIColor blackColor];
        _roomIdLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return _roomIdLabel;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor whiteColor];
        _container.layer.cornerRadius = 6;
        _container.clipsToBounds = YES;
    }
    return _container;
}

- (void)updateCellWithName:(NSString *)roomName roomId:(NSString *)roomId; {
    self.nameLabel.text = [@"房间名称：" stringByAppendingString:roomName];
    self.roomIdLabel.text = [@"房间ID：" stringByAppendingString:roomId];
}

@end

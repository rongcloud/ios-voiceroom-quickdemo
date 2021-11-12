//
//  UserListCell.m
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/28.
//

#import "UserListCell.h"

NSString *const UserListCellIdentifier = @"UserListCellIdentifier";

@interface UserListCell ()
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *rejectButton;
@property (nonatomic, strong) UIButton *kickButton;
@property (nonatomic, strong) UIButton *inviteButton;
@property (nonatomic, strong) UIButton *cancelInviteButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idLabel;
@end


@implementation UserListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.cellStyle = UserListCellStyleRequest;
        [self buildLayout];
    }
    return self;
}

-(void)setCellStyle:(UserListCellStyle)cellStyle {
    if (cellStyle == UserListCellStyleRequest) {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = NO;
        self.kickButton.hidden = YES;
        self.inviteButton.hidden = YES;
        self.cancelInviteButton.hidden = YES;
    } else if (cellStyle == UserListCellStyleKick) {
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = YES;
        self.kickButton.hidden = NO;
        self.inviteButton.hidden = NO;
        self.cancelInviteButton.hidden = YES;
    } else if (cellStyle == UserListCellStyleCancelInvite) {
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = YES;
        self.kickButton.hidden = YES;
        self.inviteButton.hidden = YES;
        self.cancelInviteButton.hidden = NO;
    } else if (cellStyle == UserListCellStylePKCreator){
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = YES;
        self.kickButton.hidden = YES;
        self.inviteButton.hidden = NO;
        self.cancelInviteButton.hidden = NO;
    } else {
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = YES;
        self.kickButton.hidden = YES;
        self.inviteButton.hidden = YES;
        self.cancelInviteButton.hidden = YES;
    }
}

- (void)updateRoomName:(NSString *)roomName roomId:(NSString *)roomId {
    self.nameLabel.text = [NSString stringWithFormat:@"房间名: %@",roomName];
    self.idLabel.text = [NSString stringWithFormat:@"房间ID: %@",roomId];
}

- (void)agree {
    if (self.handler) {
        self.handler(UserListCellActionAgree);
    }
}

- (void)reject {
    if (self.handler) {
        self.handler(UserListCellActionReject);
    }
}

- (void)kick {
    if (self.handler) {
        self.handler(UserListCellActionKick);
    }
}

- (void)invite {
    if (self.handler) {
        self.handler(UserListCellActionInvite);
    }
}

- (void)cancelInvite {
    if (self.handler) {
        self.handler(UserListCellActionCancelInvite);
    }
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor blackColor];
    }
    return _nameLabel;
}

- (UILabel *)idLabel {
    if (_idLabel == nil) {
        _idLabel = [[UILabel alloc] init];
        _idLabel.font = [UIFont systemFontOfSize:14];
        _idLabel.textColor = [UIColor blackColor];
    }
    return _idLabel;
}

- (UIButton *)agreeButton {
    if (_agreeButton == nil) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.backgroundColor = mainColor;
        [_agreeButton setTitle:@"同意" forState:UIControlStateNormal];
        [_agreeButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_agreeButton addTarget:self action:@selector(agree) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeButton;
}

- (UIButton *)rejectButton {
    if (_rejectButton == nil) {
        _rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rejectButton.backgroundColor = mainColor;
        [_rejectButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [_rejectButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_rejectButton addTarget:self action:@selector(reject) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rejectButton;
}

- (UIButton *)kickButton {
    if (_kickButton == nil) {
        _kickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _kickButton.backgroundColor = mainColor;
        [_kickButton setTitle:@"踢出" forState:UIControlStateNormal];
        [_kickButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_kickButton addTarget:self action:@selector(kick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _kickButton;
}

- (UIButton *)inviteButton {
    if (_inviteButton == nil) {
        _inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _inviteButton.backgroundColor = mainColor;
        [_inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
        [_inviteButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_inviteButton addTarget:self action:@selector(invite) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inviteButton;
}


- (UIButton *)cancelInviteButton {
    if (_cancelInviteButton == nil) {
        _cancelInviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelInviteButton.backgroundColor = mainColor;
        [_cancelInviteButton setTitle:@"取消邀请" forState:UIControlStateNormal];
        [_cancelInviteButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_cancelInviteButton addTarget:self action:@selector(cancelInvite) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelInviteButton;
}

- (void)buildLayout {
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.leading.equalTo(self.contentView).offset(10);
    }];
    
    [self.contentView addSubview:self.idLabel];
    [self.idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        make.leading.equalTo(self.contentView).offset(10);
    }];
    
    [self.contentView addSubview:self.agreeButton];
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-20);
    }];
    
    [self.contentView addSubview:self.kickButton];
    [self.kickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.agreeButton);
    }];
    
    [self.contentView addSubview:self.rejectButton];
    [self.rejectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.trailing.equalTo(self.agreeButton.mas_leading).offset(-20);
    }];
    
    [self.contentView addSubview:self.inviteButton];
    [self.inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.rejectButton);
    }];
    
    [self.contentView addSubview:self.cancelInviteButton];
    [self.cancelInviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.agreeButton);
    }];
}

@end

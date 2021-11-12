//
//  UserListView.m
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/28.
//

#import "UserListView.h"
#import "UserListCell.h"

@interface UserListView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL host;
@property (nonatomic, copy) NSArray<RoomUser *>* dataSource;
@end

@implementation UserListView

#pragma mark initialized

- (instancetype)initWithHost:(BOOL)host {
    if (self = [super init]) {
        self.listType = UserListTypeRequest;
        self.host = host;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 20.0f;
        self.layer.borderColor = mainColor.CGColor;
        self.layer.borderWidth = 1.f;
        [self buildLayout];
    }
    return self;
}

#pragma mark public method

// 显示列表
- (void)show {
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = CGRectMake(self.frame.origin.x, (kScreenHeight - self.frame.size.height)/2, self.frame.size.width, self.frame.size.height);
    }];
}

// 隐藏列表
-(void)dismiss {
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = CGRectMake(self.frame.origin.x, kScreenHeight, self.frame.size.width, self.frame.size.height);
    }];
}

// 刷新数据
- (void)reloadDataWithUsers:(NSArray<RoomUser *> *)users {
    if (users != nil) {
        self.dataSource = users;
        [self.tableView reloadData];
    }
}

#pragma mark - tableviwe delegate datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource == nil ? 0 : self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListCell *cell = (UserListCell*)[tableView dequeueReusableCellWithIdentifier:UserListCellIdentifier];
    if (cell == nil) {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserListCellIdentifier];
    }
    
    RoomUser *user = self.dataSource[indexPath.row];
    if (self.isHost) {
        if (self.listType == UserListTypeRoomUser) {
            cell.cellStyle = UserListCellStyleKick;
        } else if (self.listType == UserListTypeRoomInvite) {
            cell.cellStyle = UserListCellStyleCancelInvite;
        } else if (self.listType == UserListTypeRoomCreator) {
            cell.cellStyle = UserListCellStylePKCreator;
        } else {
            cell.cellStyle = UserListCellStyleRequest;
        }
    } else {
        cell.cellStyle = UserListCellStyleDefault;
    }
    [cell updateRoomName:user.userName roomId:user.userId];
    WeakSelf(self)
    [cell setHandler:^(UserListCellAction action) {
        StrongSelf(weakSelf)
        [strongSelf dismiss];
        if (strongSelf.handler) {
            strongSelf.handler(user.userId,action);
        }
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  120.f;
}


#pragma mark - getter

- (UIView *)topBar {
    if (_topBar == nil) {
        _topBar = [[UIView alloc] init];
        _topBar.backgroundColor = mainColor;
    }
    return _topBar;
}

- (UIButton *)dismissButton {
    if (_dismissButton == nil) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.backgroundColor = mainColor;
        [_dismissButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_dismissButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma  mark - layout subviews

- (void)buildLayout {
    
    [self addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44.f);
        make.leading.trailing.top.equalTo(self);
    }];
    
    [self.topBar addSubview:self.dismissButton];
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.equalTo(self.topBar);
        make.width.mas_equalTo(44.f);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBar.mas_bottom);
        make.bottom.trailing.leading.equalTo(self);
    }];
}

@end

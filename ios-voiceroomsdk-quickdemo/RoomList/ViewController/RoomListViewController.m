//
//  RoomListViewController.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/10.
//

#import "RoomListViewController.h"
#import "RoomListTableViewCell.h"
#import <RCVoiceRoomLib/RCVoiceRoomLib.h>
#import <Masonry.h>
#import "VoiceRoomViewController.h"
#import "RoomInfo.h"
#import "UIColor+Hex.h"
#import <SVProgressHUD.h>
#import <AVFoundation/AVFoundation.h>
#import "RoomListResponse.h"
#import "NSString+MD5.h"
#import "CreateRoomResponse.h"

@interface RoomListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<RoomListRoom *> *roomlist;
@property (nonatomic, strong) UIBarButtonItem *createRoomButton;

@end

static NSString * const roomCellIdentifier = @"RoomListTableViewCell";
@implementation RoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildLayout];
    [WebService roomListWithSize:20 page:0 type:RoomTypeVoice responseClass:[RoomListResponse class] success:^(id  _Nullable responseObject) {
        RoomListResponse *res = (RoomListResponse *)responseObject;
        if (res.code.integerValue == StatusCodeSuccess) {
            [self.roomlist addObjectsFromArray:res.data.rooms];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"房间数据获取失败 code:%d",res.code.intValue]];
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"房间数据获取失败 code:%ld",(long)error.code]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSLog(@"get micphone access");
        }
    }];
}

- (void)buildLayout {
    self.title = @"房间列表";
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8F9"];
    self.navigationItem.rightBarButtonItem = self.createRoomButton;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Init Method

- (UIBarButtonItem *)createRoomButton {
    if (!_createRoomButton) {
        _createRoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleCreateRoom:)];
    }
    return _createRoomButton;
}

#pragma mark - Private method
- (void)handleCreateRoom:(UIBarButtonItem *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    WeakSelf(self)
//    UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"创建PK房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        StrongSelf(weakSelf)
//        [strongSelf pushVoiceRoomControllerWithType:YES];
//    }];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"创建房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        StrongSelf(weakSelf)
        [strongSelf pushVoiceRoomControllerWithType:NO];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    [actionSheet addAction:joinAction];
    [actionSheet addAction:createAction];
    [actionSheet addAction:cancelAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (NSString *)generateRoomName {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSString *dateString = [formatter stringFromDate:date];
    NSString *roomName = [NSString stringWithFormat:@"%@ %@",UserManager.userName,dateString];
    return roomName;
}

- (void)pushVoiceRoomControllerWithType:(BOOL)isPK {
    NSString *roomName = [self generateRoomName];
    NSString *password = [@"password" vrs_md5];
    NSString *imageUrl = @"https://img2.baidu.com/it/u=2842763149,821152972&fm=26&fmt=auto";
    [WebService createRoomWithName:roomName isPrivate:0 backgroundUrl:imageUrl themePictureUrl:imageUrl password:password type:RoomTypeVoice kv:@[] responseClass:[CreateRoomResponse class] success:^(id  _Nullable responseObject) {
        if (responseObject) {
            Log(@"network create room success")
            CreateRoomResponse *res = (CreateRoomResponse *)responseObject;
            if (res.data != nil) {
                [SVProgressHUD showSuccessWithStatus:LocalizedString(@"create_room_success")];
                UIViewController *vc = [self createRoomWithType:isPK roomName:roomName roomId:res.data.roomId];
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                Log(@"network logic error code: %ld",(long)res.code);
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ code: %ld",LocalizedString(@"network_error"),res.code]];
            }

        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ code: %ld",LocalizedString(@"create_room_fail"),(long)error.code]];
    }];
}

- (UIViewController *)createRoomWithType:(BOOL)isPK roomName:(NSString *)roomName roomId:(NSString *)roomId {
    RCVoiceRoomInfo *roomInfo = [[RCVoiceRoomInfo alloc] init];
    roomInfo.roomName = roomName;
    // 设置9个麦位
    roomInfo.seatCount = isPK ? 2 : 9;
    //非自由麦，上麦需要申请
    roomInfo.isFreeEnterSeat = NO;
    // 进入语聊房
    VoiceRoomViewController *vc;
    vc = [[VoiceRoomViewController alloc] initWithRoomId:roomId roomInfo:roomInfo];
    return vc;
}


#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
    RoomListRoom *room = self.roomlist[indexPath.row];
    [cell updateCellWithName:room.roomName roomId:room.roomId];
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VoiceRoomViewController *vc = [[VoiceRoomViewController alloc] initWithJoinRoomId:self.roomlist[indexPath.row].roomId];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Lazy Init

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[RoomListTableViewCell class] forCellReuseIdentifier:roomCellIdentifier];
    }
    return _tableView;
}

- (NSMutableArray *)roomlist {
    if (!_roomlist) {
        _roomlist = [NSMutableArray array];
    }
    return _roomlist;
}

@end

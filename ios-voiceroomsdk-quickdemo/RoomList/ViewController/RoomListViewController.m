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
//#import "RoomInfo.h"
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
@property (nonatomic, strong) UITextField *roomNameField;

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
//    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//        if (granted) {
//            NSLog(@"get micphone access");
//        }
//    }];
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
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"创建房间" message:@"输入房间名字" preferredStyle: UIAlertControllerStyleAlert];
    
    [actionSheet addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.roomNameField = textField;
    }];
    
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"创建房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.roomNameField.text.length != 0) {
            [self checkRoomToEnterOrCreate:self.roomNameField.text];
        } else {
            [SVProgressHUD showErrorWithStatus:@"房间名字不能为空"];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
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


- (void)checkRoomToEnterOrCreate:(NSString *)roomName {
    [WebService checkCreatedRoom:RoomTypeVoice responseClass:[CreateRoomResponse class] success:^(id  _Nullable responseObject) {
        if (responseObject) {
            CreateRoomResponse *res = (CreateRoomResponse *)responseObject;
            if (res.data != nil) {
                [self enterExist:res.data];
            } else {
                [self createNew:roomName];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ code: %ld", @"check createdRoom fail", (long)error.code]];
    }];
}

- (void)enterExist:(RCSceneRoom *)roomInfo {
    NSString *existMsg = [NSString stringWithFormat:@"已创建房间: %@",roomInfo.roomName];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"用户已创建房间" message:existMsg preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"进入房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        VoiceRoomViewController *voiceRoomVc = [[VoiceRoomViewController alloc] initWithRoomId:roomInfo.roomId roomInfo:nil];
        [self.navigationController pushViewController:voiceRoomVc animated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:createAction];
    [actionSheet addAction:cancelAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (void)createNew:(NSString *)roomName {
    NSString *password = @"1234";
    NSString *imageUrl = @"";
    [WebService createRoomWithName:roomName isPrivate:0 backgroundUrl:imageUrl themePictureUrl:imageUrl password:password type:RoomTypeVoice kv:@[] responseClass:[CreateRoomResponse class] success:^(id  _Nullable responseObject) {
        if (responseObject) {
            CreateRoomResponse *res = (CreateRoomResponse *)responseObject;
            if (res.data != nil) {
                [SVProgressHUD showSuccessWithStatus:LocalizedString(@"create_room_success")];\
                RCVoiceRoomInfo *roomInfo = [[RCVoiceRoomInfo alloc] init];
                roomInfo.roomName = roomName;
                roomInfo.seatCount = 9;
                roomInfo.isFreeEnterSeat = NO;
                VoiceRoomViewController *voiceRoomVc = [[VoiceRoomViewController alloc] initWithRoomId:res.data.roomId roomInfo:roomInfo];
                [self.navigationController pushViewController:voiceRoomVc animated:YES];
            } else {
                Log(@"network logic error code: %ld",(long)res.code);
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ code: %ld",LocalizedString(@"network_error"),res.code]];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ code: %ld",LocalizedString(@"create_room_fail"),(long)error.code]];
    }];
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
    VoiceRoomViewController *vc = [[VoiceRoomViewController alloc] initWithRoomId:self.roomlist[indexPath.row].roomId roomInfo:nil];
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

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

@interface RoomListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<RoomInfo *> *roomlist;
@property (nonatomic, strong) UIBarButtonItem *createRoomButton;

@end

static NSString * const roomCellIdentifier = @"RoomListTableViewCell";
@implementation RoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildLayout];
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
    UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"加入房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self joinRoom];
    }];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"创建房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self createRoom];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actionSheet addAction:joinAction];
    [actionSheet addAction:createAction];
    [actionSheet addAction:cancelAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)createRoom {
    // 根据时间创建一个房间名称
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [formatter stringFromDate:date];
    NSString *roomName = [NSString stringWithFormat:@"%@%@", @"测试房间", dateString];
    
    // 输入一个房间ID
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"加入房间" message:@"输入房间ID" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"房间ID";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *roomId = [[alertController textFields][0] text];
        if (roomId.length > 0) {
            // 创建语聊房实例
            // 创建房间必须初始化房间信息，设置房间名称和麦位数量。
            // 否则无法创建成功
            RCVoiceRoomInfo *roomInfo = [[RCVoiceRoomInfo alloc] init];
            roomInfo.roomName = roomName;
            // 设置9个麦位
            roomInfo.seatCount = 9;
            // 进入语聊房
            VoiceRoomViewController *vc = [[VoiceRoomViewController alloc] initWithRoomId:roomId roomInfo:roomInfo];
            [self.navigationController pushViewController:vc animated:YES];
            
            // 储存语聊房到本地，主要是便于UI展示
            RoomInfo *info = [[RoomInfo alloc] init];
            info.roomId = roomId;
            info.roomInfo = roomInfo;
            [self.roomlist addObject:info];
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:@"请输入数字"];
        }
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)joinRoom {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"加入房间" message:@"输入房间ID" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"房间ID";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *roomId = [[alertController textFields][0] text];
        if (roomId.length > 0) {
            VoiceRoomViewController *vc = [[VoiceRoomViewController alloc] initWithJoinRoomId:roomId];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
    [cell updateCell:self.roomlist[indexPath.row]];
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

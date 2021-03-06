//
//  VoiceRoomViewController.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/10.
//

#import "VoiceRoomViewController.h"
#import <RCVoiceRoomLib/RCVoiceRoomLib.h>
#import <SVProgressHUD.h>
#import "SeatInfoCollectionViewCell.h"
#import "UIColor+Hex.h"
#import <Masonry.h>
#import "UserManager.h"
#import "RoomUserListResponse.h"
#import "UserListView.h"

static NSString * const cellIdentifier = @"SeatInfoCollectionViewCell";
@interface VoiceRoomViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, RCVoiceRoomDelegate>

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) BOOL isCreate;

// 根据roomInfoDidUpdate获取的最新roomInfo
@property (nonatomic, copy) RCVoiceRoomInfo *roomInfo;
// 根据seatInfoDidUpdate 获取的最新麦位信息
@property (nonatomic, copy) NSArray<RCVoiceSeatInfo *> *seatlist;
// 用来显示麦位的collectionView
@property (nonatomic, strong) UICollectionView *collectionView;
// 背景
@property (nonatomic, strong) UIImageView *backgroundImageView;
// 退出房间
@property (nonatomic, strong) UIButton *quitButton;
// 用户id label
@property (nonatomic, strong) UILabel *userLabel;

// 用户列表
@property (nonatomic, strong) UserListView *listView;

//主播是否已经上麦
@property (nonatomic, assign, getter=isOnTheSeat) BOOL onTheSeat;

//观众申请的麦位序号
@property (nonatomic, assign) NSInteger requestSeatIndex;

//是否为PK直播间
@property (nonatomic, assign, getter=isPK) BOOL pk;

#warning 如下方法需要在PK分类中重载
- (void)pk_loadPKModule;
- (void)pk_invite;
- (void)pk_quit;
- (void)pk_sendPKAction:(NSInteger)action userId:(NSString *)userId;
- (void)pk_messageDidReceive:(nonnull RCMessage *)message;
@end

@implementation VoiceRoomViewController

- (instancetype)initWithJoinRoomId:(NSString *)roomId {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.roomId = roomId;
        self.isCreate = NO;
    }
    return self;
}

- (instancetype)initWithRoomId:(NSString *)roomId roomInfo:(RCVoiceRoomInfo *)roomInfo {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.roomId = roomId;
        self.roomInfo = roomInfo;
        self.isCreate = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [RCVoiceRoomEngine.sharedInstance setDelegate:self];
    if (self.isCreate) {
        [self createVoiceRoom:_roomId info:_roomInfo];
    } else {
        [self joinVoiceRoom:_roomId];
    }
    self.requestSeatIndex = -1;
    // 设置语聊房代理
    [self buildLayout];
   
    // 加载PK模块
    if (self.isPK) {
        [self pk_loadPKModule];
    }
    
    [self updateRoomOnlineStatus];
    [[RCVoiceRoomEngine sharedInstance] notifyVoiceRoom:@"refreshBackgroundImage" content:@""];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Private Method

- (void)updateRoomOnlineStatus {
    [WebService updateOnlineRoomStatusWithRoomId:self.roomId responseClass:nil success:^(id  _Nullable responseObject) {
        Log(@"update room online status success");
    } failure:^(NSError * _Nonnull error) {
        Log(@"update room online status fail code : %ld",error.code);
    }];
}

#pragma mark - Room Life Cycle Create Join Leave

// 离开房间
- (void)quitRoom {
    
    //离开房间
    void(^leaveRoom)(void) = ^(void){
        if (self.isPK) {
            [self pk_quit];
        }
        [[RCVoiceRoomEngine sharedInstance] leaveRoom:^{
            [SVProgressHUD showSuccessWithStatus:@"离开房间成功"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:true];
            });
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"离开房间失败 code: %ld",(long)code]];
        }];
    };
    
    if (self.isCreate) {
        //主播端调用业务接口销毁房间
        [WebService deleteRoomWithRoomId:self.roomId success:^(id  _Nullable responseObject) {
            leaveRoom();
        } failure:^(NSError * _Nonnull error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"离开房间失败 code: %ld",error.code]];
        }];
    } else {
        //观众端直接离开
        leaveRoom();
    }
    
    
}

//加入房间
- (void)createVoiceRoom:(NSString *)roomId info:(RCVoiceRoomInfo *)roomInfo {
    [[RCVoiceRoomEngine sharedInstance] createAndJoinRoom:roomId room:roomInfo success:^{
        [SVProgressHUD showSuccessWithStatus:@"创建成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:@"创建失败"];
    }];
}

//离开房间
- (void)joinVoiceRoom:(NSString *)roomId {
    [[RCVoiceRoomEngine sharedInstance] joinRoom:roomId success:^{
        [SVProgressHUD showSuccessWithStatus:@"加入房间成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:@"加入房间失败"];
    }];
}

#pragma mark - Button Action

//获取申请上麦用户列表
- (void)fetchRequestList {
    [[RCVoiceRoomEngine sharedInstance] getRequestSeatUserIds:^(NSArray<NSString *> * _Nonnull users) {
        if (users && users.count > 0) {
            Log(@"host request users list is empty");
            //使用 Engine 获取的用户ID批量获取用户信息
            [WebService fetchUserInfoListWithUids:users responseClass:[RoomUserListResponse class] success:^(id  _Nullable responseObject) {
                Log(@"host network fetch users info success");
                [SVProgressHUD showSuccessWithStatus:LocalizedString(@"live_fetch_request_list_success")];
                RoomUserListResponse *resObj = (RoomUserListResponse *)responseObject;
                if (resObj.code.integerValue == StatusCodeSuccess) {
                    [self.listView setListType:UserListTypeRequest];
                    [self.listView reloadDataWithUsers:resObj.data];
                    [self.listView show];
                }
            } failure:^(NSError * _Nonnull error) {
                Log(@"host network fetch users info failed code: %ld",(long)error.code);
            }];
        } else {
            [SVProgressHUD showSuccessWithStatus:LocalizedString(@"live_request_list_empty")];
        }
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        
    }];
}
//获取房间内用户列表
- (void)fetchUserList {
    [WebService roomUserListWithRoomId:self.roomId responseClass:[RoomUserListResponse class] success:^(id  _Nullable responseObject) {
        Log(@"host network fetch room users list success");
        [SVProgressHUD showSuccessWithStatus:LocalizedString(@"live_fetch_user_list_success")];
        RoomUserListResponse *resObj = (RoomUserListResponse *)responseObject;
        if (resObj.data == nil || resObj.data.count == 0) {
            [SVProgressHUD showSuccessWithStatus:LocalizedString(@"live_user_list_empty")];
        } else {
            [self.listView setListType:UserListTypeRoomUser];
            [self.listView reloadDataWithUsers:resObj.data];
            [self.listView show];
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showSuccessWithStatus:LocalizedString(@"live_fetch_user_list_fail")];
        Log(@"host network fetch room users list failed code: %ld",(long)error.code);
    }];
}

//观众端取消上麦申请
- (void)cancelRequest {
    [[RCVoiceRoomEngine sharedInstance] cancelRequestSeat:^{
        [SVProgressHUD showSuccessWithStatus:@"取消上麦申请成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"取消上麦申请失败 code: %ld",(long)code]];
    }];
}

- (void)speakerEnable:(UIButton *)sender {
    [[RCVoiceRoomEngine sharedInstance] enableSpeaker:!sender.selected];
    sender.selected = !sender.selected;
}

- (void)micDisable:(UIButton *)sender {
    [[RCVoiceRoomEngine sharedInstance] disableAudioRecording:!sender.selected];
    sender.selected = !sender.selected;
}

- (void)muteAll:(UIButton *)sender {
    [[RCVoiceRoomEngine sharedInstance] muteOtherSeats:!sender.selected];
    sender.selected = !sender.selected;
}

- (void)lockAll:(UIButton *)sender {
    [[RCVoiceRoomEngine sharedInstance] lockOtherSeats:!sender.selected];
    sender.selected = !sender.selected;
}

#pragma mark Functions

//展示功能列表
- (void)showActionSheetWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"请选择操作" preferredStyle:UIAlertControllerStyleActionSheet];
    WeakSelf(self);
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"上麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        StrongSelf(weakSelf);
        [strongSelf enterSeatWithSeatInfo:seatInfo seatIndex:index];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"下麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        StrongSelf(weakSelf);
        [strongSelf leaveSeatWithSeatInfo:seatInfo seatIndex:index];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"闭麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        StrongSelf(weakSelf);
        [strongSelf muteSeatWithSeatInfo:seatInfo seatIndex:index];
    }]];
    
#warning 以下功能会根据用户是主播还是观众进行区分
    if (self.isCreate) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"锁麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            StrongSelf(weakSelf);
            [strongSelf lockSeatWithSeatInfo:seatInfo seatIndex:index];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"踢出麦位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            StrongSelf(weakSelf);
            [strongSelf kickSeatWithSeatInfo:seatInfo seatIndex:index];
        }]];
    } else {
        //观众
        //TODO:
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:actionSheet animated:YES completion:nil];
}

//上麦
- (void)enterSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    
    if (self.isCreate || self.roomInfo.isFreeEnterSeat)
        goto host;//自由麦模式或者当前用户为主播跳转到host分支
    else
        goto audience;//跳转到观众分支
host:
    if (seatInfo.status == RCSeatStatusEmpty) {
        if (self.isOnTheSeat) {
            //已经在麦上，换座位
            [[RCVoiceRoomEngine sharedInstance] switchSeatTo:index success:^{
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"换座位成功当前座位号: %ld",(long)index]];
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"换座位失败 code: %ld",(long)code]];
            }];
        } else {
            //不在麦上，直接上麦
            [[RCVoiceRoomEngine sharedInstance] enterSeat:index success:^{
                [SVProgressHUD showSuccessWithStatus:@"上麦成功"];
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"上麦失败 code: %ld",(long)code]];
            }];
        }
        self.onTheSeat = YES;
    } else if (seatInfo.status == RCSeatStatusUsing) {
        [SVProgressHUD showErrorWithStatus:@"当前座位被占用"];
    } else if (seatInfo.status == RCSeatStatusLocking) {
        [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
    }
audience:
    if (seatInfo.status == RCSeatStatusEmpty) {
        self.requestSeatIndex = index;
        [[RCVoiceRoomEngine sharedInstance] requestSeat:^{
            [SVProgressHUD showSuccessWithStatus:@"上麦请求发送成功"];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"上麦失败 code: %ld",(long)code]];
        }];
    } else if (seatInfo.status == RCSeatStatusUsing) {
        [SVProgressHUD showErrorWithStatus:@"当前座位被占用"];
    } else if (seatInfo.status == RCSeatStatusLocking) {
        [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
    }
}
//下麦
- (void)leaveSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    
    if (seatInfo.status == RCSeatStatusUsing) {
        if ([seatInfo.userId isEqualToString:UserManager.userId]) {
            //host 主动下麦
            [[RCVoiceRoomEngine sharedInstance] leaveSeatWithSuccess:^{
                [SVProgressHUD showSuccessWithStatus:@"下麦成功"];
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"下麦失败 code: %ld",(long)code]];
            }];
        } else {
            //host 踢人下麦
            if (self.isCreate) {
                [[RCVoiceRoomEngine sharedInstance] kickUserFromSeat:seatInfo.userId success:^{
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"用户：%@ 下麦成功",seatInfo.userId]];
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"下麦失败 code: %ld",(long)code]];
                }];
            } else {
                [SVProgressHUD showErrorWithStatus:@"下麦失败，观众没有此位置的下麦权限"];
            }
            
        }
    } else if (seatInfo.status == RCSeatStatusEmpty) {
        [SVProgressHUD showErrorWithStatus:@"当前座位为空"];
    } else if (seatInfo.status == RCSeatStatusLocking) {
        [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
    }
}

//锁麦
- (void)lockSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    if (seatInfo.status == RCSeatStatusLocking) {
        //当前为锁定状态时进行解锁操作
        [[RCVoiceRoomEngine sharedInstance] lockSeat:index lock:NO success:^{
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位:%ld解锁成功",index]];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位解锁失败 code: %ld",code]];
        }];
    } else {
        //锁定座位
        [[RCVoiceRoomEngine sharedInstance] lockSeat:index lock:YES success:^{
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位:%ld锁定成功",index]];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位锁定失败 code: %ld",code]];
        }];
    }
}

//锁麦
- (void)muteSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    if (seatInfo.status == RCSeatStatusUsing || seatInfo.status == RCSeatStatusEmpty) {
        [[RCVoiceRoomEngine sharedInstance] muteSeat:index mute:!seatInfo.isMuted success:^{
            NSString *string = seatInfo.isMuted ? @"解除静音成功" : @"静音成功";
            [SVProgressHUD showSuccessWithStatus:string];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            NSString *string = seatInfo.isMuted ? @"解除静音失败 code: %ld" : @"解除静音失败 code: %ld";
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:string,(long)code]];
        }];
    }  else if (seatInfo.status == RCSeatStatusLocking) {
        [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
    }
}

//踢人
- (void)kickSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    if (seatInfo.status == RCSeatStatusUsing) {
        [[RCVoiceRoomEngine sharedInstance] kickUserFromSeat:seatInfo.userId success:^{
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"用户:%@已经被踢出座位",seatInfo.userId]];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"踢出用户失败 code: %ld",(long)code]];
        }];
    } else if (seatInfo.status == RCSeatStatusEmpty) {
        [SVProgressHUD showErrorWithStatus:@"当前座位为空"];
    } else if (seatInfo.status == RCSeatStatusLocking) {
        [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
    }
}

//处理用户列表相关的操作  requestList 同意，拒绝，inviteList 取消，userList 踢人 邀请
#warning 只有主播端有下面的 action 操作，观众端只展示邀请列表的消息
- (void)handleAudienceRequest:(NSInteger)action uid:(NSString *)uid  {
    switch (action) {
            //同意用户的上麦申请
        case UserListActionAgree:
            {
                [[RCVoiceRoomEngine sharedInstance] acceptRequestSeat:uid success:^{
                    
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    
                }];
            }
            break;
            //拒绝用户的上麦申请
        case UserListActionReject:
            {
                [[RCVoiceRoomEngine sharedInstance] rejectRequestSeat:uid success:^{
                    
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    
                }];
            }
            break;
            //根据用户的uid将用户踢出直播间
        case UserListActionKick:
            {
                [[RCVoiceRoomEngine sharedInstance] kickUserFromRoom:uid success:^{
                    
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    
                }];
            }
            break;
            //邀请用户上麦
        case UserListActionInvite:
            {
                if (self.listView.listType == UserListTypeRoomCreator && self.isPK) {
                    [self pk_sendPKAction:UserListActionInvite userId:uid];
                } else {
                    NSInteger emptyIndex = [self emptySeatIndex];
                    if (emptyIndex >= 0) {
                        NSDictionary *content = @{@"uid":uid,@"index":@(emptyIndex)};
                        NSString *contentString = [content yy_modelToJSONString];
                        [[RCVoiceRoomEngine sharedInstance] sendInvitation:contentString success:^(NSString * _Nonnull str) {
                            
                        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                            
                        }];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"当前没有空置的麦位"];
                    }
                }
                
            }
            break;
            //根据uid取消对某个用户的上麦邀请
        case UserListActionCancelInvite:
            {
                if (self.listView.listType == UserListTypeRoomCreator && self.isPK) {
                    [self pk_sendPKAction:UserListActionCancelInvite userId:uid];
                } else {
                    [[RCVoiceRoomEngine sharedInstance] cancelInvitation:uid success:^{
                        
                    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                        
                    }];
                }
            }
            break;
        default:
            break;
    }
}

- (void)showAlertWithTitle:(NSString *)title completion:(void(^)(BOOL accept))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(YES);
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(NO);
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (NSInteger)emptySeatIndex {
    for (int i = 0; i<self.seatlist.count; i++) {
        RCVoiceSeatInfo *info = self.seatlist[i];
        if (info.status == RCSeatStatusEmpty) {
            return i;
        }
    }
    return -1;
}


#pragma mark - CollectionView Delegate & DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _seatlist.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SeatInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell updateCell:self.seatlist[indexPath.row] withSeatIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RCVoiceSeatInfo *info = self.seatlist[indexPath.row];
    if (info) {
        [self showActionSheetWithSeatInfo:info seatIndex:indexPath.row];
    }
}

#pragma mark - VoiceRoomLib Delegate

// 房间信息初始化完毕，可在此方法进行一些初始化操作，例如进入房间房主自动上麦等
- (void)roomKVDidReady {
    
}

// 任何麦位的变化都会触发此回调。
- (void)seatInfoDidUpdate:(NSArray<RCVoiceSeatInfo *> *)seatInfolist {
    self.seatlist = seatInfolist;
    [self.collectionView reloadData];
}

// 任何房间信息的修改都会触发此回调。
- (void)roomInfoDidUpdate:(RCVoiceRoomInfo *)roomInfo {
    self.roomInfo = roomInfo;
}

// 收到被下麦的回调
- (void)kickSeatDidReceive:(NSUInteger)seatIndex {
    [[RCVoiceRoomEngine sharedInstance] leaveSeatWithSuccess:^{
        [SVProgressHUD showSuccessWithStatus:@"被踢下麦"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:@"被踢下麦失败"];
    }];
}

// 聊天室消息回调
- (void)messageDidReceive:(nonnull RCMessage *)message {
    Log(@"PKMSG: objectName %@",message.objectName);
    [self pk_messageDidReceive:message];
}

// 被抱麦的回调，userId为邀请你上麦的用户id
- (void)pickSeatDidReceiveBy:(nonnull NSString *)userId {
    [self showAlertWithTitle:@"接收到主播的上麦邀请" completion:^(BOOL accept) {
        if (accept) {
            NSInteger emptyIndex = [self emptySeatIndex];
            if (emptyIndex >= 0) {
                [[RCVoiceRoomEngine sharedInstance] enterSeat:emptyIndex success:^{
                    [SVProgressHUD showSuccessWithStatus:@"上麦成功"];
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    [SVProgressHUD showErrorWithStatus:@"上麦失败"];
                }];
            } else {
                [SVProgressHUD showErrorWithStatus:@"没有空余麦位"];
            }
        }
    }];
}

// 你发出的连麦申请被接受了。这时可以调用上麦接口直接上麦
- (void)requestSeatDidAccept {
    Log(@"host accept audience on seat request");
    [SVProgressHUD showSuccessWithStatus:@"主播接受上麦请求"];
    [[RCVoiceRoomEngine sharedInstance] enterSeat:self.requestSeatIndex success:^{
        [SVProgressHUD showSuccessWithStatus:@"上麦成功"];
        Log(@"audience on seat success");
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"上麦失败 code: %ld",code]];
    }];
}

// 你发出的连麦申请被拒绝了。这时可以调用Hud显示被拒绝信息
- (void)requestSeatDidReject {
    [SVProgressHUD showErrorWithStatus:@"主播拒绝上麦请求，上麦失败"];
}

// 申请上麦的列表发生了变化，你可以调用getLatestRequestSeat接口获取最新的申请连麦的用户列表
- (void)requestSeatListDidChange {
    [SVProgressHUD showSuccessWithStatus:@"请求列表发生变化"];
}

// 房间发生了未知错误
- (void)roomDidOccurError:(RCVoiceRoomErrorCode)code {
    
}

// 通过
- (void)roomNotificationDidReceive:(nonnull NSString *)name content:(nonnull NSString *)content {
    
}

// 某个麦位被锁定时会触发此回调
- (void)seatDidLock:(NSInteger)index isLock:(BOOL)isLock {
    
}

// 某个麦位被静音或解除静音时会触发此回调
- (void)seatDidMute:(NSInteger)index isMute:(BOOL)isMute {
    
}

// 某个麦位有人说话时会触发此回调
- (void)speakingStateDidChange:(NSUInteger)seatIndex speakingState:(BOOL)isSpeaking {
    
}

// 用户进入房间时会触发此回调
- (void)userDidEnter:(nonnull NSString *)userId {
    
}

// 用户上了某个麦位时会触发此回调
- (void)userDidEnterSeat:(NSInteger)seatIndex user:(nonnull NSString *)userId {
    
}

// 用户离开房间时触发此回调
- (void)userDidExit:(nonnull NSString *)userId {
    
}

// 用户被踢出房间时触发此回调
- (void)userDidKickFromRoom:(nonnull NSString *)targetId byUserId:(nonnull NSString *)userId {
    
}

// 用户下麦某个麦位触发此回调
- (void)userDidLeaveSeat:(NSInteger)seatIndex user:(nonnull NSString *)userId {
    
}

// 以下4个为自定义邀请，可不用关心
- (void)invitationDidAccept:(nonnull NSString *)invitationId {
    
}

- (void)invitationDidCancel:(nonnull NSString *)invitationId {
    
}

- (void)invitationDidReceive:(nonnull NSString *)invitationId from:(nonnull NSString *)userId content:(nonnull NSString *)content {
    
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict;
    if (jsonData != nil) {
        NSError *err;
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    }
    if (dict == nil)
        return;
    
    NSString *uid = dict[@"uid"];
    NSInteger index = [(NSNumber *)dict[@"index"] integerValue];
    
    if (uid != nil && [uid isEqualToString:UserManager.userId]) {
        [self showAlertWithTitle:@"收到上麦请求" completion:^(BOOL accept) {
            if (accept) {
                [[RCVoiceRoomEngine sharedInstance] acceptInvitation:invitationId success:^{
                    [[RCVoiceRoomEngine sharedInstance] enterSeat:index success:^{
                        [SVProgressHUD showSuccessWithStatus:@"上麦成功"];
                    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"上麦失败 code: %ld",(long)code]];
                    }];
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"接受邀请失败 code: %ld",(long)code]];
                }];
            } else {
                [[RCVoiceRoomEngine sharedInstance] rejectInvitation:invitationId success:^{
                    Log(@"reject invitation");
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"拒绝邀请失败 code: %ld",(long)code]];
                }];
            }
        }];
    }
}

- (void)invitationDidReject:(nonnull NSString *)invitationId {
    
}

#pragma mark -Layout Subviews

- (void)buildLayout {
    self.title = @"语聊房";
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8F9"];
    [self.view addSubview:self.backgroundImageView];
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.quitButton];
    [self.quitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).inset(20);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        make.size.equalTo(@(CGSizeMake(44, 44)));
    }];
    
    self.userLabel.text = [NSString stringWithFormat:@"当前用户id：%@\n当前用户名：%@", UserManager.userId,UserManager.userName];
    [self.view addSubview:self.userLabel];
    [self.userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(self.quitButton).offset(30);
    }];
    
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.userLabel.mas_bottom).offset(20);
        make.height.equalTo(@(255));
    }];
    
    UIButton *requestListButton = [self actionButtonFactory:@"申请列表" withAction:@selector(fetchRequestList)];
    UIButton *userListButton = [self actionButtonFactory:@"用户列表" withAction:@selector(fetchUserList)];
    UIButton *cancelRequestButton = [self actionButtonFactory:@"取消上麦申请" withAction:@selector(cancelRequest)];
    UIButton *speakerEnableButton = [self actionButtonFactory:@"扬声器模式" withAction:@selector(speakerEnable:)];
    [speakerEnableButton setTitle:@"听筒模式" forState:UIControlStateSelected];
    speakerEnableButton.selected = YES;
    UIButton *micDisableButton = [self actionButtonFactory:@"禁用麦克风" withAction:@selector(micDisable:)];
    [micDisableButton setTitle:@"打开麦克风" forState:UIControlStateSelected];
    
    NSArray *container1;
    if (self.isCreate) {
        container1 = @[requestListButton,userListButton,speakerEnableButton,micDisableButton];
    } else {
        container1 = @[requestListButton,userListButton,cancelRequestButton];
    }
    UIStackView *stackView1 = [self stackViewWithViews:container1];
    [self.view addSubview:stackView1];
    [stackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20);
        make.trailing.equalTo(self.view).offset(-20);
        make.bottom.mas_equalTo(self.view).offset(-120);
        make.height.mas_equalTo(60);
    }];
    
    UIButton *muteAllButton = [self actionButtonFactory:@"全员静音" withAction:@selector(muteAll:)];
    UIButton *lockAllButton = [self actionButtonFactory:@"全员锁麦" withAction:@selector(lockAll:)];
    NSArray *container2;
    if (self.isCreate) {
        container2 = @[muteAllButton,lockAllButton];
    } else {
        container2 = @[speakerEnableButton,micDisableButton];
    }
    UIStackView *stackView2 = [self stackViewWithViews:container2];
    [self.view addSubview:stackView2];
    
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20);
        make.trailing.equalTo(self.view).offset(-20);
        make.top.mas_equalTo(stackView1.mas_bottom);
        make.height.mas_equalTo(60);
    }];
    
    [self.view addSubview:self.listView];
}

- (UIButton *)actionButtonFactory:(NSString *)title withAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorFromHexString:@"#EF499A"];
    button.layer.cornerRadius = 6;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState: UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    [button addTarget:self action:action forControlEvents: UIControlEventTouchUpInside];
    [[button.widthAnchor constraintGreaterThanOrEqualToConstant:70] setActive:YES];
    return button;
}

- (UIStackView *)stackViewWithViews:(NSArray *)views {
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:views];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 10;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    return stackView;
}

#pragma mark - lazy Init

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(75, 75);
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[SeatInfoCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
    }
    return _collectionView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roombackground.jpeg"]];
    }
    return _backgroundImageView;
}

- (NSArray<RCVoiceSeatInfo *> *)seatlist {
    if (!_seatlist) {
        _seatlist = [NSArray array];
    }
    return _seatlist;
}

- (UIButton *)quitButton {
    if (!_quitButton) {
        _quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_quitButton setImage:[UIImage imageNamed:@"white_quite_icon"] forState:UIControlStateNormal];
        [_quitButton addTarget:self action:@selector(quitRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quitButton;
}

- (UILabel *)userLabel {
    if (!_userLabel) {
        _userLabel = [[UILabel alloc] init];
        _userLabel.font = [UIFont systemFontOfSize:14];
        _userLabel.textColor = [UIColor whiteColor];
        _userLabel.numberOfLines = 0;
    }
    return _userLabel;
}

- (UserListView *)listView {
    if (_listView == nil) {
        UserListView *listView = [[UserListView alloc] initWithHost:self.isCreate];
        listView.frame = CGRectMake(10, kScreenHeight, kScreenWidth - 20, kScreenHeight - 300);
        WeakSelf(self)
        [listView setHandler:^(NSString * _Nonnull uid, NSInteger action) {
            StrongSelf(weakSelf)
            [strongSelf handleAudienceRequest:action uid:uid];
        }];
        _listView = listView;
    }
    return _listView;
}

//如下方法在分类中实现
- (void)pk_loadPKModule {}
- (void)pk_invite {}
- (void)pk_quit {}
- (void)pk_sendPKAction:(NSInteger)action userId:(NSString *)userId {}
- (void)pk_messageDidReceive:(nonnull RCMessage *)message {}

@end

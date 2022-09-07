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
#import <AVFoundation/AVFoundation.h>
#import "RoomListResponse.h"

static NSString * const cellIdentifier = @"SeatInfoCollectionViewCell";
@interface VoiceRoomViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, RCVoiceRoomDelegate>

@property (nonatomic, strong) RCSceneRoom *roomResp;

@property (nonatomic, assign) BOOL currentUserIsRoomOwner;

@property (nonatomic, copy) RCVoiceRoomInfo *roomInfo;

@property (nonatomic, strong) NSArray<RCVoiceSeatInfo *> *seatlist;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RCVoiceUserInfo *> *seatUserMap;
@property (nonatomic, strong) NSMutableArray<RoomUser *> *requestRoomUsers;

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

@property (nonatomic, strong) RCSceneRoom *roomToPk;


#warning 如下方法需要在PK分类中重载
- (void)pk_loadPKModule;
- (void)pk_invite;
- (void)pk_quit;
- (void)pk_sendPKAction:(NSInteger)action userId:(NSString *)userId;
- (void)pk_messageDidReceive:(nonnull RCMessage *)message;
@end

@implementation VoiceRoomViewController

- (NSMutableDictionary<NSString *,RCVoiceUserInfo *> *)seatUserMap {
    if (!_seatUserMap) {
        _seatUserMap = [NSMutableDictionary dictionary];
    }
    return _seatUserMap;
}

- (NSMutableArray<RoomUser *> *)requestRoomUsers {
    if (!_requestRoomUsers) {
        _requestRoomUsers = [NSMutableArray array];
    }
    return _requestRoomUsers;
}

- (instancetype)initWithRoom:(RCSceneRoom *)roomResp roomInfo:(RCVoiceRoomInfo *)roomInfo {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.roomResp = roomResp;
        self.roomInfo = roomInfo;
        self.currentUserIsRoomOwner = [roomResp.createUser.userId isEqualToString:UserManager.userId];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildLayout];

    [RCVoiceRoomEngine.sharedInstance setDelegate:self];
    
    NSString *roomId = self.roomResp.roomId;
    if (self.roomInfo) {
        [self createVoiceRoom:roomId info:_roomInfo];
    } else {
        [self joinVoiceRoom:roomId];
    }
    
    self.requestSeatIndex = -1;
   
    // 加载PK模块
    if (self.isPK) {
        [self pk_loadPKModule];
    }
    
    [self updateRoomOnlineStatus];
    
    [[RCVoiceRoomEngine sharedInstance] notifyVoiceRoom:@"refreshBackgroundImage" content:@""];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.roomResp.roomName;
    [self.navigationItem setHidesBackButton:YES];
}

#pragma mark - Private Method

- (void)updateRoomOnlineStatus {
    [WebService updateOnlineRoomStatusWithRoomId:self.roomResp.roomId responseClass:nil success:^(id  _Nullable responseObject) {
        Log(@"update room online status success");
    } failure:^(NSError * _Nonnull error) {
        Log(@"update room online status fail code : %ld",error.code);
    }];
}

#pragma mark - Room Life Cycle Create Join Leave

// 离开房间
- (void)quitRoom {
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择操作" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"离开房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        leaveRoom();
    }]];
    
    if (_currentUserIsRoomOwner) {
        [alert addAction:[UIAlertAction actionWithTitle:@"关闭删除房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [WebService deleteRoomWithRoomId:self.roomResp.roomId success:^(id  _Nullable responseObject) {
                leaveRoom();
            } failure:^(NSError * _Nonnull error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"离开房间失败 code: %ld",error.code]];
            }];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)createVoiceRoom:(NSString *)roomId info:(RCVoiceRoomInfo *)roomInfo {
    [[RCVoiceRoomEngine sharedInstance] createAndJoinRoom:roomId room:roomInfo success:^{
        [SVProgressHUD showSuccessWithStatus:@"创建成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        NSString *status = [NSString stringWithFormat:@"创建失败: %ld, %@",code,msg];
        [SVProgressHUD showSuccessWithStatus:status];
        [self.navigationController popViewControllerAnimated:true];
    }];
}

- (void)joinVoiceRoom:(NSString *)roomId {
    [[RCVoiceRoomEngine sharedInstance] joinRoom:roomId success:^{
        [SVProgressHUD showSuccessWithStatus:@"加入房间成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        NSString *status = [NSString stringWithFormat:@"加入失败: %ld, %@",code,msg];
        [SVProgressHUD showSuccessWithStatus:status];
        [self.navigationController popViewControllerAnimated:true];
    }];
}

#pragma mark - Button Action

//获取申请上麦用户列表
- (void)fetchRequestList {
    [self.listView setListType:UserListTypeRequest];
    [self.listView reloadDataWithUsers:self.requestRoomUsers];
    [self.listView show];
}

//获取房间内用户列表
- (void)fetchUserList {
    [WebService roomUserListWithRoomId:self.roomResp.roomId responseClass:[RoomUserListResponse class] success:^(id  _Nullable responseObject) {
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
    [[RCVoiceRoomEngine sharedInstance] disableAudioRecording:!sender.selected success:^{
        sender.selected = !sender.selected;
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                
    }];
}

- (void)muteAll:(UIButton *)sender {
//    [[RCVoiceRoomEngine sharedInstance] muteOtherSeats:!sender.selected];
    sender.selected = !sender.selected;
}

- (void)lockAll:(UIButton *)sender {
//    [[RCVoiceRoomEngine sharedInstance] lockOtherSeats:!sender.selected];
    sender.selected = !sender.selected;
}

#pragma mark Functions

//展示功能列表
- (void)showActionSheetWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"麦位" message:@"请选择操作" preferredStyle:UIAlertControllerStyleActionSheet];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"上麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self enterSeatWithSeatInfo:seatInfo seatIndex:index];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"下麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self leaveSeatWithSeatInfo:seatInfo seatIndex:index];
    }]];
  
    if (self.currentUserIsRoomOwner) {
        NSString *micTitle = seatInfo.mute ? @"解除麦位静音" : @"麦位静音";
        [actionSheet addAction:[UIAlertAction actionWithTitle:micTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self muteSeatWithSeatInfo:seatInfo seatIndex:index];
        }]];
        
        NSString *lockTitle = seatInfo.lock ? @"解锁麦位" : @"锁定麦位";
        [actionSheet addAction:[UIAlertAction actionWithTitle:lockTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self lockSeatWithSeatInfo:seatInfo seatIndex:index];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"踢出麦位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self kickUserFromSeat:index];
        }]];
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

//上麦
- (void)enterSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    if (self.currentUserIsRoomOwner || self.roomInfo.isFreeEnterSeat) {
        if (self.isOnTheSeat) { // 已经在麦上，换座位
            [[RCVoiceRoomEngine sharedInstance] switchSeatTo:index success:^{
                self.onTheSeat = YES;
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"换座位成功当前座位号: %ld",(long)index]];
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"换座位失败 code: %ld",(long)code]];
            }];
        } else { //不在麦上，直接上麦
            [[RCVoiceRoomEngine sharedInstance] enterSeat:index success:^{
                [SVProgressHUD showSuccessWithStatus:@"上麦成功"];
                self.onTheSeat = YES;
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"上麦失败 code: %ld",(long)code]];
            }];
        }
    } else {
        self.requestSeatIndex = index;
        [[RCVoiceRoomEngine sharedInstance] requestSeat:index content:@"" successBlock:^{
            [SVProgressHUD showSuccessWithStatus:@"上麦请求发送成功"];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"上麦失败 code: %ld",(long)code]];
        }];
    }
}

// 下麦
- (void)leaveSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    NSString *seatKey = [NSString stringWithFormat:@"%zd",index];
    RCVoiceUserInfo *user = self.seatUserMap[seatKey];
    if ([user.userId isEqualToString:UserManager.userId]) { // 自己所在的麦位
        [[RCVoiceRoomEngine sharedInstance] leaveSeatWithSuccess:^{
            [SVProgressHUD showSuccessWithStatus:@"下麦成功"];
            self.onTheSeat = NO;
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            NSString *status = [NSString stringWithFormat:@"下麦: %ld, %@",code,msg];
            [SVProgressHUD showErrorWithStatus:status];
        }];
    } else {
        if (self.currentUserIsRoomOwner) { // 房主踢人下麦
            [[RCVoiceRoomEngine sharedInstance] kickUserFromSeat:user.userId content:@"" success:^{
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"用户 %@ 下麦成功",user.userId]];
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                NSString *status = [NSString stringWithFormat:@"踢下麦失败: %ld, %@",code,msg];
                [SVProgressHUD showErrorWithStatus:status];
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:@"观众没有踢下麦权限"];
        }
    }
}

//锁麦
- (void)lockSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    NSString *status = seatInfo.isLocked ? @"解锁" : @"锁定";
    [[RCVoiceRoomEngine sharedInstance] lockSeat:@[@(index)] lock:!seatInfo.isLocked success:^{
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位:%ld %@ 成功",index,status]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位 %@ 失败 code: %ld",status,code]];
    }];
}

//静音
- (void)muteSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    BOOL toMute = !seatInfo.isMuted;
    [[RCVoiceRoomEngine sharedInstance] muteSeat:@[@(index)] mute:toMute success:^{
        NSString *status = toMute ? @"静音成功" : @"解除静音成功";
        [SVProgressHUD showSuccessWithStatus:status];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        NSString *err = toMute ? @"静音失败 code: %ld" : @"解除静音失败 code: %ld";
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:err,(long)code]];
    }];
}

//踢人
- (void)kickUserFromSeat:(NSInteger)seatIndex {
    NSString *seatKey = [NSString stringWithFormat:@"%zd",seatIndex];
    RCVoiceUserInfo *user = self.seatUserMap[seatKey];
    
    [[RCVoiceRoomEngine sharedInstance] kickUserFromSeat:user.userId content:@"" success:^{
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"用户:%@已经被踢出座位",user.userId]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"踢出用户失败 code: %ld",(long)code]];
    }];
}

//处理用户列表相关的操作  requestList 同意，拒绝，inviteList 取消，userList 踢人 邀请
#warning 只有主播端有下面的 action 操作，观众端只展示邀请列表的消息
- (void)handleAudienceRequest:(NSInteger)action uid:(NSString *)uid  {
    switch (action) {
            //同意用户的上麦申请
        case UserListActionAgree:
            {
                [[RCVoiceRoomEngine sharedInstance] responseRequestSeat:YES userId:uid content:@"OK" success:^{
                    
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    
                }];
            }
            break;
            //拒绝用户的上麦申请
        case UserListActionReject:
            {
                [[RCVoiceRoomEngine sharedInstance] responseRequestSeat:NO userId:uid content:@"OK" success:^{
                    
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    
                }];
            }
            break;
            //根据用户的uid将用户踢出直播间
        case UserListActionKick:
            {
                [[RCVoiceRoomEngine sharedInstance] kickUserFromRoom:uid content:@"请出去" success:^{
                    [SVProgressHUD showSuccessWithStatus:@"踢人成功"];
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
                    if (self.seatlist.count >= self.roomInfo.seatCount) {
                        [[RCVoiceRoomEngine sharedInstance] sendInvitation:uid content:@"yaoqing" success:^(NSString * _Nonnull invataionId) {
                            
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

#pragma mark - CollectionView Delegate & DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _seatlist.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SeatInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *seatKey = [NSString stringWithFormat:@"%zd",indexPath.row];
    RCVoiceUserInfo *user = self.seatUserMap[seatKey];
    [cell updateCell:self.seatlist[indexPath.row] withSeatUser:user seatIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RCVoiceSeatInfo *info = self.seatlist[indexPath.row];
    if (info) {
        [self showActionSheetWithSeatInfo:info seatIndex:indexPath.row];
    }
}

#pragma mark - VoiceRoomLib Delegate


// 任何麦位的变化都会触发此回调。
- (void)seatInfoDidUpdate:(NSArray<RCVoiceSeatInfo *> *)seatInfolist {
    self.seatlist = seatInfolist;
    [self.collectionView reloadData];
}

// 任何房间信息的修改都会触发此回调。
- (void)roomInfoDidUpdate:(RCVoiceRoomInfo *)roomInfo {
    self.roomInfo = roomInfo;
}


- (void)onSeatUserInfoDidUpdate:(NSArray<RCVoiceUserInfo *> *)seatUserlist {
    [self.seatUserMap removeAllObjects];
    for (RCVoiceUserInfo *user in seatUserlist) {
        NSString *seatIndexKey = [NSString stringWithFormat:@"%zd",user.index];
        [self.seatUserMap setObject:user forKey:seatIndexKey];
    }
    [self.collectionView reloadData];
}

- (void)requestSeatListDidChange {
    [[RCVoiceRoomEngine sharedInstance] getRequesterInfoList:^(NSArray<RCVoiceRequesterInfo *> * _Nonnull reqs) {
        if (reqs.count == 0) {
            [self.requestRoomUsers removeAllObjects];
            return;
        }
          
        NSMutableArray *uids = [NSMutableArray array];
        for (RCVoiceRequesterInfo *req in reqs) {
            [uids addObject:req.userId];
        }
        [WebService fetchUserInfoListWithUids:uids responseClass:[RoomUserListResponse class] success:^(id  _Nullable responseObject) {
            RoomUserListResponse *resObj = (RoomUserListResponse *)responseObject;
            if (resObj.code.integerValue == StatusCodeSuccess) {
                [self.requestRoomUsers removeAllObjects];
                [self.requestRoomUsers addObjectsFromArray:resObj.data];
            }
        } failure:^(NSError * _Nonnull error) {
            Log(@"fetchUserInfoListWithUids failed code: %ld",(long)error.code);
        }];
        
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        
    }];
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

- (void)requestSeatRespones:(BOOL)isAccept content:(NSString *)content {
    if (isAccept) {
        [[RCVoiceRoomEngine sharedInstance] enterSeat:self.requestSeatIndex success:^{
            [SVProgressHUD showSuccessWithStatus:@"上麦成功"];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"上麦失败 code: %ld",code]];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"主播拒绝上麦请求"];
    }
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
    NSString *status = [NSString stringWithFormat:@"%@进入", userId];
    [SVProgressHUD showSuccessWithStatus:status];
}

// 用户离开房间时触发此回调
- (void)userDidExit:(nonnull NSString *)userId {
    NSString *status = [NSString stringWithFormat:@"%@离开", userId];
    [SVProgressHUD showSuccessWithStatus:status];
}


// 用户上了某个麦位时会触发此回调
- (void)userDidEnterSeat:(NSInteger)seatIndex user:(nonnull NSString *)userId {
    
}

- (void)roomDidClosed {
    [SVProgressHUD showSuccessWithStatus:@"房间已经关闭"];
    [self.navigationController popViewControllerAnimated:true];
}

// 用户被踢出房间时触发此回调
- (void)userDidKickFromRoom:(nonnull NSString *)targetId byUserId:(nonnull NSString *)userId content:(nonnull NSString *)content {
    if (!self.currentUserIsRoomOwner) {
        NSString *status = [NSString stringWithFormat:@"被%@踢出房间",userId];
        [SVProgressHUD showSuccessWithStatus:status];
        [self quitRoom];
    }
}

// 用户下麦某个麦位触发此回调
- (void)userDidLeaveSeat:(NSInteger)seatIndex user:(nonnull NSString *)userId {
    
}

- (void)invitationDidReceive:(nonnull NSString *)invitationId from:(nonnull NSString *)userId content:(nonnull NSString *)content {
    NSString *title = [NSString stringWithFormat:@"%@邀请你上麦",userId];
    [self showAlertWithTitle:title completion:^(BOOL accept) {
        [[RCVoiceRoomEngine sharedInstance] responseInvitation:invitationId accept:accept content:@"" success:^{
            if (accept) {
                [SVProgressHUD showSuccessWithStatus:@"接受邀请"];
//                [[RCVoiceRoomEngine sharedInstance] enterSeat:index success:^{
//                    [SVProgressHUD showSuccessWithStatus:@"上麦成功"];
//                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
//                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"上麦失败 code: %ld",(long)code]];
//                }];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"已拒绝邀请"];
            }
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            
        }];
    }];
    
}


- (void)invitationDidRespones:(BOOL)isAccept invitationId:(NSString *)invitationId content:(NSString *)content {
    NSString *status = nil;
    if (isAccept) {
        status = [NSString stringWithFormat:@"对方接受邀请,Id: %@",invitationId];
    } else {
        status = [NSString stringWithFormat:@"对方拒绝邀请,Id: %@",invitationId];
    }
    [SVProgressHUD showSuccessWithStatus:status];
}

#pragma mark -Layout Subviews

- (void)buildLayout {
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8F9"];
    [self.view addSubview:self.backgroundImageView];
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.quitButton];
    [self.quitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.size.equalTo(@(CGSizeMake(44, 44)));
    }];
    
    self.userLabel.text = [NSString stringWithFormat:@"房主用户名：%@\n当前用户名：%@", self.roomResp.createUser.userName,UserManager.userName];
    [self.view addSubview:self.userLabel];
    [self.userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.right.equalTo(self.quitButton.mas_left);
        make.centerY.equalTo(self.quitButton);
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
    if (self.currentUserIsRoomOwner) {
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
        make.height.mas_equalTo(50);
    }];
    
    
    UIButton *pkButton = [self actionButtonFactory:@"随机邀请PK" withAction:@selector(pickOtherRoomOwnerToPk)];
    UIButton *cancelPkButton = [self actionButtonFactory:@"取消PK邀请" withAction:@selector(cancelInvitePk)];
    UIButton *mutePkButton = [self actionButtonFactory:@"静音对面PK房间" withAction:@selector(muteOtherPKRoom:)];
    [mutePkButton setTitle:@"取消静音" forState:UIControlStateSelected];
    UIButton *endPkButton = [self actionButtonFactory:@"结束PK" withAction:@selector(endPKWithOther)];
    
    NSArray *pkBtns = nil;
    if (self.currentUserIsRoomOwner) {
        pkBtns = @[pkButton, cancelPkButton, mutePkButton, endPkButton];
    }
    UIStackView *pkStackView = [self stackViewWithViews:pkBtns];
    [self.view addSubview:pkStackView];
    [pkStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20);
        make.top.mas_equalTo(stackView1.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    
    UIButton *muteAllButton = [self actionButtonFactory:@"全员静音" withAction:@selector(muteAll:)];
    UIButton *lockAllButton = [self actionButtonFactory:@"全员锁麦" withAction:@selector(lockAll:)];
    NSArray *container2;
    if (self.currentUserIsRoomOwner) {
        container2 = @[muteAllButton,lockAllButton];
    } else {
        container2 = @[speakerEnableButton,micDisableButton];
    }
    UIStackView *stackView2 = [self stackViewWithViews:container2];
    [self.view addSubview:stackView2];
    
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20);
        make.trailing.equalTo(self.view).offset(-20);
        make.top.mas_equalTo(pkStackView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    [self.view addSubview:self.listView];
}

- (UIButton *)actionButtonFactory:(NSString *)title withAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorFromHexString:@"#EF499A"];
    button.layer.cornerRadius = 6;
    button.titleLabel.font = [UIFont systemFontOfSize:12];
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
        UserListView *listView = [[UserListView alloc] initWithHost:self.currentUserIsRoomOwner];
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



- (void)pickOtherRoomOwnerToPk {
    [WebService roomListWithSize:20 page:0 type:RoomTypeVoice responseClass:[RoomListResponse class] success:^(id  _Nullable responseObject) {
        RoomListResponse *res = (RoomListResponse *)responseObject;
        if (res.code.integerValue == StatusCodeSuccess) {
            for (RCSceneRoom *room in res.data.rooms) {
                if ([room.roomName isEqualToString:@"meetYouOk"]) {
                    self.roomToPk = room;
                    break;
                }
            }
            [[RCVoiceRoomEngine sharedInstance] sendPKInvitation:self.roomToPk.roomId invitee:self.roomToPk.createUser.userId success:^{
                [SVProgressHUD showSuccessWithStatus:@"发起PK成功"];
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                
            }];
        }
    } failure:^(NSError * _Nonnull error) {
    }];
}


- (void)cancelInvitePk {
    [[RCVoiceRoomEngine sharedInstance] cancelPKInvitation:self.roomToPk.roomId invitee:self.roomToPk.createUser.userId success:^{
        self.roomToPk = nil;
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        
    }];
}

- (void)muteOtherPKRoom:(UIButton *)btn {
    BOOL isToMute = !btn.selected;
    [[RCVoiceRoomEngine sharedInstance] mutePKUser:isToMute success:^{
        btn.selected = !btn.selected;
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            
    }];
}

- (void)endPKWithOther {
    [[RCVoiceRoomEngine sharedInstance] quitPK:^{
        
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        
    }];
}


/// 被邀请者拒绝 接受PK
- (void)rejectPKInvitationDidReceiveFromRoom:(NSString *)inviteeRoomId byUser:(NSString *)initeeUserId {
    NSString *status = [NSString stringWithFormat:@"%@ 拒绝PK",initeeUserId];
    [SVProgressHUD showSuccessWithStatus:status];
}

- (void)pkOngoingWithInviterRoom:(NSString *)inviterRoomId
               withInviterUserId:(NSString *)inviterUserId
                 withInviteeRoom:(NSString *)inviteeRoomId
               withInviteeUserId:(NSString *)inviteeUserId {
    [SVProgressHUD showSuccessWithStatus:@"PK 进行中"];
}

/// 对方结束PK时会触发此回调
- (void)pkDidFinish {
    [SVProgressHUD showSuccessWithStatus:@"PK 结束"];
}

/// 收到邀请 PK 的回调
- (void)pkInvitationDidReceiveFromRoom:(NSString *)inviterRoomId byUser:(NSString *)inviterUserId {
    NSString *status = [NSString stringWithFormat:@"收到%@ PK邀请",inviterUserId];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:status message:@"请选择操作" preferredStyle:UIAlertControllerStyleActionSheet];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[RCVoiceRoomEngine sharedInstance] responsePKInvitation:inviterRoomId inviter:inviterUserId accept:YES success:^{
            [SVProgressHUD showSuccessWithStatus:@"接受邀请，开始PK"];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[RCVoiceRoomEngine sharedInstance] responsePKInvitation:inviterRoomId inviter:inviterUserId accept:NO success:^{
            [SVProgressHUD showSuccessWithStatus:@"已拒绝"];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

/// 收到 取消 PK 邀请回调
- (void)cancelPKInvitationDidReceiveFromRoom:(NSString *)inviterRoomId byUser:(NSString *)inviterUserId {
    NSString *status = [NSString stringWithFormat:@"收到%@ 取消PK邀请",inviterUserId];
    [SVProgressHUD showSuccessWithStatus:status];
}

@end

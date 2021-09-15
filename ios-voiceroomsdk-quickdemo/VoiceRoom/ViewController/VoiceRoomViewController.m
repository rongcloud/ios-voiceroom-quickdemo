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
@property (nonatomic, strong) UIImageView *backgroundImageView;

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
    if (self.isCreate) {
        [self createVoiceRoom:_roomId info:_roomInfo];
    } else {
        [self joinVoiceRoom:_roomId];
    }
    // 设置语聊房代理
    [RCVoiceRoomEngine.sharedInstance setDelegate:self];
    [self buildLayout];
}

#pragma mark - Private Method

- (void)buildLayout {
    self.title = @"语聊房";
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8F9"];
    [self.view addSubview:self.backgroundImageView];
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.equalTo(@(160));
    }];
}

#pragma mark - Create And Join Method

- (void)createVoiceRoom:(NSString *)roomId info:(RCVoiceRoomInfo *)roomInfo {
    // 关于roomId，真实环境中一般是调用自己的业务服务器接口，创建一个语聊房，业务服务器返回一个roomId
    // 这里便于演示使用一个固定的roomId
    [[RCVoiceRoomEngine sharedInstance] createAndJoinRoom:roomId room:roomInfo success:^{
        [SVProgressHUD showSuccessWithStatus:@"创建成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:@"创建失败"];
    }];
}

- (void)joinVoiceRoom:(NSString *)roomId {
    [[RCVoiceRoomEngine sharedInstance] joinRoom:roomId success:^{
        [SVProgressHUD showSuccessWithStatus:@"加入房间成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:@"加入房间失败"];
    }];
}

#pragma mark - lazy Init

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(70, 70);
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[SeatInfoCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
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

#pragma mark - CollectionView Delegate & DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _seatlist.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SeatInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
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

// 任何房间信息都会触发此回调。
- (void)roomInfoDidUpdate:(RCVoiceRoomInfo *)roomInfo {
    self.roomInfo = roomInfo;
}

// 被下麦的回调
- (void)kickSeatDidReceive:(NSUInteger)seatIndex {
    
}

// 聊天室消息回调
- (void)messageDidReceive:(nonnull RCMessage *)message {
    
}

// 被抱麦的回调，userId为邀请你上麦的用户id
- (void)pickSeatDidReceiveBy:(nonnull NSString *)userId {
    
}

// 你发出的连麦申请被接受了。这时可以调用上麦接口直接上麦
- (void)requestSeatDidAccept {
    
}

// 你发出的连麦申请被拒绝了。这时可以调用Hud显示被拒绝信息
- (void)requestSeatDidReject {
    
}

// 申请上麦的列表发生了变化，你可以调用getLatestRequestSeat接口获取最新的申请连麦的用户列表
- (void)requestSeatListDidChange {
    
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
    
}

- (void)invitationDidReject:(nonnull NSString *)invitationId {
    
}

@end

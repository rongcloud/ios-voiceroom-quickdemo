# 语聊房QuickDemo 

<p align="center">
<img src="https://img.shields.io/cocoapods/v/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
<img src="https://img.shields.io/cocoapods/p/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
<img src="https://img.shields.io/cocoapods/l/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
</p>


## 简介
> 语聊房SDK(RCVoiceRoomLib)为用户提供了一套便捷，有效的针对语聊房场景的SDK。可以让用户在短时间内搭建一套完整的语聊房系统。

语聊房 SDK 是基于融云即时通讯（IM）和实时音视频（RTC）优势能力封装的场景化 SDK，参考主流语聊房应用功能进行设计，贴近场景，提供精简、高度封装的核心 API 与回调，帮助您降低学习成本，提升开发效率。

语聊房 SDK 支持包括麦位管理、房间管理、多人连麦、跨房间 PK 与混音在内的功能。

#### 客户端RCVoiceRoomLib SDK
语聊房客户端 SDK 即 `RCVoiceRoomLib`，支持开箱即用。配合融云 IM 与 RTC 服务端 API 接口，可构建丰富的业务特性组合。

#### RCVoiceRoomLib 环境要求
* Xcode：确保与苹果官方同步更新
* CocoaPods：1.10.0 及以上
* iOS：11.0 及以上
* objc：2.0
## 集成 
> RCVoiceRoomLib SDK集成,cocoapods管理方式集成
1. 在项目的 Podfile 中添加
```
pod 'RCVoiceRoomLib', '2.0.4'
```
2. 终端运行
`pod install`
3. Pod 安装完成后，CocoaPods 会在您的工程根目录下生成一个 .xcworkspace 文件。您需要通过此文件打开您的工程，而不是之前的 .xcodeproj
#### 相关说明
 * 集成语聊房 SDK 后，iOS包增量大约4MB;
 * RCVoiceRoomLib 依赖IMLib和RTCLib ,依赖版本如下
    * IMLib , '~> 5.1.4'
    * RTCLib, '~> 5.1.8'

## 功能

语聊房客户端 SDK `RCVoiceRoomLib` 的主要功能包括麦位管理、房间管理、多人连麦、跨房间 PK 与混音。更多功能请参见下表（包括但不限于以下内容）：


| 功能         | 描述                                                           |
|------------|----------------------------|
| 房间管理       | 支持从客户端创建、加入、退出房间。                                                             |
| 用户上麦       | 支持房间内用户上指定麦位或自由上麦，最多支持 32 人同房间内连麦。                                            |
| 申请麦序       | 支持房间内用户上指定麦位或自由上麦，最多支持 32 人同房间内连麦。                                            |
| 静音麦位       | 支持房间内任何用户静音或取消静音任意指定麦位或所有麦位。                                                  |
| 锁定麦位       | 支持房间内任何用户锁定任意指定麦位或所有麦位，其他观众无法上麦。注意，锁麦仅锁定麦位状态，暂不支持将被锁麦位上用户自动下麦。                |
| 动态修改麦位数量   | 在直播过程中，可动态增加或减少麦位数量。注意，修改后所有连麦者自动下麦。                                          |
| 实时监听麦克风音量  | 监听不同麦位的麦克风音量。                                                                 |
| 混音支持       | 支持背景音，伴唱，特效声等混音效果。 注意，需要直接调用 RTCLib 接口。                                       |
| 控制音频质量     | 内置房间音频质量支持人声、标清音质、高清音质。内置房间场景支持普通通话、音乐聊天室、音乐教室。可动态切换质量与场景，满足教学，K 歌等不同场景需求。    |
| 跨房间 1v1 PK | 支持两个房间之间两个主播的跨房间 PK，可将对方主播在当前房间内静音。注意，PK 期间不支持房间内连麦。                          |
| 房间属性可扩展    | 支持自定义房间扩展属性。注意，该字段建议使用 JSON 格式字符串。                                            |
| 麦位属性可扩展    | 支持自定义麦位扩展属性。注意，该字段建议使用 JSON 格式字符串。App 开发者可根据狼人杀，相亲房等具体业务场景，自行定义扩展数据结构，用于区分角色等 |
## 使用
 1. RCVoiceRoomLib SDK初始化

> 在初始化前，请确保已完成以下操作：
> * 您已开通融云开发者账号，并申请了融云 App Key。
> * 您已为 App Key 开通音视频服务。使用语聊房业务要求开通「音视频直播」服务。
1. 在 `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions` 中执行下列方法初始化语聊房 SDK。
   
     ```objc
     /// 这里使用语聊房 SDK 初始化，所以不再需要 RCCoreClient 初始化融云相关 SDK。
    /// appkey 即您申请的 appkey，需要开通音视频直播服务
    /// token一般是您在登录自己的业务服务器之后，业务服务器返回给您的，可存在本地。
        [[RCVoiceRoomEngine sharedInstance] initWithAppkey:appKey];
        [[RCVoiceRoomEngine sharedInstance] connectWithToken:token success:^{
            NSLog(@"connect success");
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            NSLog(@"connect failed, %@", msg);
        }];
    ```
2. 注意事项  
   已集成 IMLib 或者 IMKit 的应用可继续使用原 SDK 的初始化，不需要再使用语聊房 SDK RCVoiceRoomLib 的初始化。但是，如果您的应用已设置消息代理，您需要进行以下设置。
   例如,您的app中有设置过代理
       
   ```objc
    [[RCCoreClient sharedCoreClient] setReceiveMessageDelegate:self object:nil];
    ```
   这里请调用语聊房的 `addMessageReceiveDelegate`，防止您的消息代理被替换，从而导致接收不到消息
   
    ```objc
    /// 增加其他消息监听Delegate
    /// @param delegate RCMicMessageHandleDelegate
    - (void)addMessageReceiveDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate;
    ```

# 使用示例
 1. 创建、加入和离开房间
    * 创建语聊房：取得房间 ID 后可创建房间。调用 `createAndJoinRoom` 接口创建并加入该房间。创建房间时需要设置语聊房的名称与麦位数量。
           
        ```objc
        /// 创建一个 RCVoiceRoomInfo 实例
        RCVoiceRoomInfo *roomInfo = [[RCVoiceRoomInfo alloc] init];
        /// 设置房间名称
        roomInfo.roomName = roomName;
        /// 设置麦位数量
        roomInfo.seatCount = 9;
        // roomId 是您的业务服务器返回的
        [[RCVoiceRoomEngine sharedInstance] createAndJoinRoom:roomId room:roomInfo success:^{
          /// 创建成功后会自动加入语聊房
             [SVProgressHUD showSuccessWithStatus:@"创建成功"];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
             [SVProgressHUD showSuccessWithStatus:@"创建失败"];
        }];
        ```
    
    * 加入语聊房：调用 JoinRoom 接口加入房间，该接口要求语聊房已存在。申请加入语聊房的用户需要提供房间 ID。
        ```objc
         /// 这里的roomId是通过您获取自己业务服务器接口拿到的。
        - (void)joinVoiceRoom:(NSString *)roomId {
            [[RCVoiceRoomEngine sharedInstance] joinRoom:roomId success:^{
                [SVProgressHUD showSuccessWithStatus:@"加入房间成功"];
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                [SVProgressHUD showSuccessWithStatus:@"加入房间失败"];
            }];
        }
        
        /// 在viewDidLoad里一般会这样设置
        - (void)viewDidLoad {
            [super viewDidLoad];
            // 如果是创建房间，那么调用创建方法，创建语聊房，否则调用加入房间
            if (self.isCreate) {
                [self createVoiceRoom:_roomId info:_roomInfo];
            } else {
                [self joinVoiceRoom:_roomId];
            }
            // 设置语聊房代理
            [RCVoiceRoomEngine.sharedInstance setDelegate:self];
            // 布局方法
            [self buildLayout];
        }       
         ```
    
    * 离开语聊房：调用 leaveRoom 接口离开房间。离开房间自动下麦。
        ```objc
        /// 离开房间
        /// @param successBlock 离开房间成功
        /// @param errorBlock 离开房间失败
        - (void)leaveRoom:(RCVoiceRoomSuccessBlock)successBlock
                            error:(RCVoiceRoomErrorBlock)errorBlock;
       /// 调用成功后，在回调里 popViewController 即可。
        ```    
        
 2. 加入房间回调顺序
 
  a. 在 viewDidLoad 方法中设置语聊房代理。
     
   ```objc
    - (void)viewDidLoad {
        [super viewDidLoad];
        /// 判断是创建还是加入语聊房
        if (self.isCreate) {
            [self createVoiceRoom:_roomId info:_roomInfo];
        } else {
            [self joinVoiceRoom:_roomId];
        }
        /// 设置语聊房代理
        [RCVoiceRoomEngine.sharedInstance setDelegate:self];
       /// UI布局
        [self buildLayout];
    }
   ```
    
  b. 加入或者创建成功后，会依次触发语聊房回调。

   ![mvxyFKIn12hYA5s](https://s2.loli.net/2022/04/08/mvxyFKIn12hYA5s.png)
   
  c. 不同回调的处理方法如下：
  * **roomInfoDidUpdate** ：房间更新回调会在任何人修改房间属性时触发。所以您应该在此回调处理房间属性相关的 UI。
  * **seatInfoDidUpdate** ：麦位变化回调会在任一麦位变化时触发。返回值为麦位数组，包含了当前最新的麦位信息。在此回调您应该处理所有有关麦位变化的UI。
  * **roomKVDidReady** ：该方法触发证明您的语聊房已经初始化完成，部分语聊房有房主加入房间自动上麦的逻辑，这种逻辑您应该在该回调中完成，例如在该回调触发时，房主调用上麦方法进行上麦。
  示例代码:
  ```objc
      /// 房间信息初始化完毕，可在此方法进行一些初始化操作，例如进入房间房主自动上麦等
    - (void)roomKVDidReady {
        // 如果需要进入房间自动上麦，可在此方法中调用enterSeat
    }
    
    /// 任何麦位的变化都会触发此回调。
    - (void)seatInfoDidUpdate:(NSArray<RCVoiceSeatInfo *> *)seatInfolist {
        // 保存最新麦位信息，并刷新UI。
        self.seatlist = seatInfolist;
        [self.collectionView reloadData];
    }
    
    /// 任何房间信息的修改都会触发此回调。
    - (void)roomInfoDidUpdate:(RCVoiceRoomInfo *)roomInfo {
        self.roomInfo = roomInfo;
        [self updateRoomInfoView];
    }
  ```

  
 2. 上麦和下麦

   * 锁麦：`lockSeat`
    
   锁定某个麦位。被锁上的麦位，任何人均不可使用。假设 1 号麦位被锁定，任何人调用 `enterSeat` 上 1 号麦时均会返回错误。
    
   * 闭麦：`muteSeat`
    
  处于闭麦状态的麦位任何人在麦位上说话都不会被任何人听到。
    
 锁麦在 UI 上可体现为麦位已锁定。下面我们使用语聊房 SDK QuickDemo 的 UI 演示 1 号麦位被锁定的界面。
 ![vbMTBQI6khR8Z3Y](https://s2.loli.net/2022/04/08/vbMTBQI6khR8Z3Y.png)
    
 3. 闭麦和锁卖
 4. 邀请上麦和强制下麦
 5. 跨房间PK
 6. 屏蔽主播和禁用麦克风
 7. 房间通知


 

## 功能示例代码 QuickDemo快速启动

1. 为了方便您快速运行quickdemo，我们为您预置了融云 appkey 和 对应的测试服务器url，您不需要自己部署测试服务器即可运行。
2. 申请  `BusinessToken`
   1. BusinessToken 主要是防止滥用 quickdemo 里的测试appKey，我们为接口做了限制，一个 BusinessToken 最多可以支持10个用户注册，20天使用时长。点击此处 [获取BusinessToken](https://rcrtc-api.rongcloud.net/code)
   2. 过期后您的注册用户会自动移除，想继续使用 quickdemo 需要您重新申请 BusinessToken
   3. 成功获取到 BusinessToken 后，替换 VRSDefine.h 中定义的 BusinessToken
 
![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/business_token.png)


## 运行Demo

## 登录

1. 登录
   - 手机号登录
   
![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/login.jpg)

## 房间创建

1. 创建房间
   * 点击视图右上角+号
   
   ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/create.jpg)
   
2. 加入房间
   * 点击首页列表
   
   ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/list.jpg)

## 进入房间

- 主播端
  - 申请列表（观众连麦申请）
    - 同意
    - 拒绝
  - 用户列表 （当前直播间的所有用户包括自己）
    - 邀请连麦
    - 踢出房间
  - 听筒模式
    - 听筒
    - 扬声器
  - 禁用麦克风
    - 禁用
    - 开启
  - 全员静音
    - 打开
    - 关闭
  - 全员锁麦
    - 打开
    - 关闭
- 观众端
  - 申请列表 （观众连麦申请，仅展示）
  - 用户列表（当前直播间的所有用户包括自己，仅展示）
  - 听筒模式
    - 听筒
    - 扬声器
  - 禁用麦克风
    - 禁用
    - 开启

   ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/host.jpg)
  
   ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/audience.jpg)

## 麦位管理

点击直播间的麦位弹出action sheet

- 主播端

  - 上麦
  - 下麦
  - 闭麦（关闭该麦位的声音） 
  - 锁麦（该麦位禁止申请上麦）
  - 踢出麦位（踢出该麦位的观众）

- 观众端

  - 上麦（向主播发出上麦申请）
  - 下麦
  - 闭麦  (关闭自己的声音)
  
  ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/host_sheet.jpg)
  
  ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/aduience_sheet.jpg)

更多细节可参照示例代码。

示例代码展示了基本的api调用

## 其他

如有任何疑问请提交 issue


## 常见问题

##### 连接融云服务器失败

通常有两个原因导致：

*   `initWithAppKey` 后立即执行 `connectWithToken` 方法。
    
    **解决方案**：`init` 一般在 `application` 中，`connect` 一般是在登录以后。如果 `init` 和 `connect` 必须依次执行，`connect` 建议延迟 200ms。
    
*   重复 `connect`，即 `connect` 以后没有执行 `disconnect`，又再次执行 `connect` 操作。
    
    **解决方案**：在 `connect` 执行前先调用 `disconnect`。
    

##### 加入语聊房返回失败

这通常是由于您没有开通 Appkey 的音视频直播功能，或者是免费时长用完时发生的错误。可以通过开发者后台查看您是否已经开通音视频服务。

##### 申请上麦时，谁有权限通过或拒绝申请？

在语聊房 SDK 中，并没有权限的概念，也就是说，当房间某个用户申请上麦时，任何人都可以接收申请麦位变化的回调，您需要根据自己业务的需求，确定哪些人可以处理申请。

##### 语聊房 SDK 是否有 Server 端？

首先，要区分「服务端」概念，如下：

*   您自己的**业务服务器，即为您自身的业务提供接口的后端**
*   **融云提供 IM 和 RTC 服务的后端**

而语聊房客户端 SDK 只依赖于融云的 IM 和 RTC 服务器。语聊房 SDK 只是基于融云 IM 和 RTC 能力的一层封装。

也就是说，如果您需要了解任何后端的支持，只需要查看融云的即时通讯（IM）和实时音视频（RTC）的服务端文档即可，融云并未提供专属的语聊房服务端和对应文档。

##### 语聊房 SDK 是否包含权限的概念？

语聊房 SDK 所包含的所有 API 接口，全都没有所谓权限的概念。

当我们说语聊房 SDK 只有角色划分，而没有没有权限划分，是什么意思呢?

即语聊房 SDK 内只定义主播和观众角色，而将具体的权限设计与控制交给 App 业务逻辑自行掌控。

*   **主播**：即在麦位上，能否发布音频流的人。
*   **观众**：即不在麦位上，只能听音频流的人。

语聊房 SDK 内没有权限划分，意味着所有 API 的调用对房间内的所有人一视同仁。所有人都可以调用。

在真实业务场景中，请您根据具体业务逻辑来判断调用权限，即哪些用户可以或不可以调用部分 API，并自行实现权限控制。

##### 语聊房在什么情况下需要保活？

从留存 / 销毁业务逻辑上划分，语聊房大致有两种设计：

1.  房主直播时创建语聊房，退播后销毁房间。
    
    这一种业务相对较简单。如果采用这一种设计，**不需要服务端做额外的保活措施**。
    
2.  创建语聊房后，无论主播在线与否，均保持房间留存，房主退播后不会销毁房间。
    
    如果采用这一种设计，您可能需要对房间进行保活处理。
    

融云语聊房的销毁行为与融云即时通讯（IM）聊天室的销毁机制相关。融云 IM 聊天室的销毁有两种机制：

1.  主动调用 IM Server API 提供的销毁聊天室接口，主动销毁聊天室。
2.  聊天室 1 个小时内没有人说话（时间可配置，最长 24 小时），且没有人加入聊天室时，会把聊天室内所有成员踢出聊天室，并触发自动销毁聊天室。

如果您的业务逻辑设计要求语聊房长时间持续存在，您可以参考我们的[语聊房保活最佳实践](https://doc.rongcloud.cn/sceneserver/-/-/bestcase/keepRidAlive) 进行实现。

##### 如果语聊房不保活会发生什么？

如果不保活，可能会导致您的聊天室已经被融云销毁，这样您就丢失了保存在聊天室属性里的所有麦位信息和房间信息。在下次直播时，可能会发现房间没有麦位。业务上出现错误。

所以请您按照自己的具体业务来判断是否需要进行房间保活。


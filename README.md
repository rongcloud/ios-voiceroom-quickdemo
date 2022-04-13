<h1 align="center"> 语聊房QuickDemo  </h>

<p align="center">
<img src="https://img.shields.io/cocoapods/v/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
<img src="https://img.shields.io/cocoapods/p/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
<img src="https://img.shields.io/cocoapods/l/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
</p>




##  RCVoiceRoomLib简介

 * 语聊房SDK(`RCVoiceRoomLib`)为用户提供了一套便捷，有效的针对语聊房场景的SDK。可以让用户在短时间内搭建**一套完整的语聊房系统**。

 * 语聊房客户端 SDK 即 `RCVoiceRoomLib`，支持开箱即用。配合融云 IM 与 RTC 服务端 API 接口，可构建丰富的业务特性组合。

 * 语聊房 SDK 是基于**融云即时通讯**（IM）和**实时音视频**（RTC）优势能力封装的场景化 SDK，参考主流语聊房应用功能进行设计，贴近场景，提供精简、高度封装的核心 API 与回调，帮助您降低学习成本，提升开发效率。

 * 语聊房 SDK 支持包括**麦位管理**、**房间管理**、**多人连麦**、**跨房间 PK** 与**混音在内**的功能。


## RCVoiceRoomLib 环境要求
 * Xcode：确保与苹果官方同步更新
 * CocoaPods：1.10.0 及以上
 * iOS：11.0 及以上
 * objc：2.0
## RCVoiceRoomLib依赖说明
 * 集成语聊房 SDK 后，iOS包增量大约4MB;
 * RCVoiceRoomLib 依赖IMLib和RTCLib ,依赖版本如下
    * IMLib , '~> 5.1.4'
    * RTCLib, '~> 5.1.8'


## 目录结构

![](./img/QuickDemo(VodiceRoom).png)
tip: 完整脑图请查看-> [^脚注1]

### 语聊房核心模块结构(VoiceRoomModule)

* 语聊房列表：`VoiceRoomList`实现语聊房列表展示
* 创建语聊房：`CreateVoiceRoom`实现语聊房创建
* 语聊房：`VoiceRoom`实现语聊房信息展示和控制中心
* 语聊房在线用户：`VoiceRoomUserList`实现当前在线观众列表和管理
* 语聊房背景：`VoiceRoomBackgroundSetting`实现语聊房背景更换
* 上麦邀请：`VoiceRoomInvite`实现邀请用户上麦和处理上麦请求
* 语聊房设置：`VoiceRoomSetting`实现语聊房设置：上锁和解锁、全麦管理等
* 麦位管理：`ManageSeat`座位上锁或禁麦，上麦邀请，下麦等


> 更多细节可具体参照示例代码。

## QuickDemo快速启动

1. 为了方便您快速运行quickdemo，我们为您预置了融云 appkey 和 对应的测试服务器url，您不需要自己部署测试服务器即可运行。
2. 申请  `BusinessToken`
   * BusinessToken 主要是防止滥用 quickdemo 里的测试appKey，我们为接口做了限制，一个 BusinessToken 最多可以支持10个用户注册，20天使用时长。点击此处 [获取BusinessToken](https://rcrtc-api.rongcloud.net/code)
   * 过期后您的注册用户会自动移除，想继续使用 quickdemo 需要您重新申请 BusinessToken
   * 成功获取到 BusinessToken 后，替换 VRSDefine.h 中定义的 BusinessToken

      1. cmd + shift + O (快速定位) ,弹出窗口输入`VRSDefine` 回车;即可快速定位 VRSDefine.h 文件
      2.  替换成功获取的BusinessToken宏定义
           
            ```objc
            static NSString *const LoginSuccessNotification = @"LoginSuccessNotificationIdentifier";
            
            //融云官网申请的 app key
            #define AppKey  @"pvxdm17jpw7ar"
            
            //请前往 https://rcrtc-api.rongcloud.net/code 获取 BusinessToken 替换宏定义
            #define BusinessToken  <#BusinessToken#> //这里替换成功获取到 BusinessToken
            ```
      3. 修改示意截图
        ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/raw/main/img/business_token.png)
 3. cmd+R 即可模拟器运行
 4. 输入手机号,点击登录;即可快捷登录;进入语音房列表房间,直接进入房间,或者点击右上角创建语音房间
 5. Enjoy yourself 😊
 
> 示例代码展示了基本的api调用

## 其他

如有任何疑问请提交 issue

[^脚注1]:ios-voiceroomsdk-quickdemo主目录思维导图-相关链接: [https://asunshine.yuque.com/docs/share/10992f95-a9a9-4c5c-9e0c-1c81b58a49de?# 《ios-voiceroomsdk-quickdemo主目录导图-3》](https://asunshine.yuque.com/docs/share/10992f95-a9a9-4c5c-9e0c-1c81b58a49de?#%20%E3%80%8Aios-voiceroomsdk-quickdemo%E4%B8%BB%E7%9B%AE%E5%BD%95%E5%AF%BC%E5%9B%BE-3%E3%80%8B)
<h1 align="center"> 语聊房QuickDemo  </h>

<p align="center">
<img src="https://img.shields.io/cocoapods/v/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
<img src="https://img.shields.io/cocoapods/p/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
<img src="https://img.shields.io/cocoapods/l/RCVoiceRoomLib.svg?style=flat" style="max-width: 100%;">
</p>

## 简介

语聊房QuickDemo,是对语聊房SDK(RCVoiceRoomLib)快速开箱应用示例,提供麦位管理、房间管理、多人连麦、跨房间 PK 与混音在内的等功能示例

## 环境要求
 * Xcode：确保与苹果官方同步更新
 * CocoaPods：1.10.0 及以上 [^脚注1]
 * iOS：11.0 及以上

## 目录结构

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h189gfl1m5j214o0tgq6p.jpg)
tip: 完整脑图请查看-> [^脚注2]

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


      1. `cmd + shift + o` (快速定位)[^脚注3] ,弹出窗口输入`VRSDefine` 回车;即可快速定位 VRSDefine.h 文件
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
 3. `Cmd+R` 即可模拟器运行
 4. 输入手机号,点击登录;即可快捷登录;进入语音房列表房间,直接进入房间,或者点击右上角创建语音房间
 5. Enjoy yourself 😊
 
> 示例代码展示了基本的api调用

## 其他

如有任何疑问请提交 issue


[^脚注1]:集成语聊房SDK后，iOS包增量大约**4MB**;
 RCVoiceRoomLib 依赖IMLib和RTCLib ,依赖版本如下
    * IMLib , '~> 5.1.4'
    * RTCLib, '~> 5.1.8'
[^脚注2]:ios-voiceroomsdk-quickdemo主目录思维导图-相关链接: [https://rongcloud.yuque.com/docs/share/6d9595fe-3be4-4039-a6fd-30a605050d6d?# 《ios-voiceroomsdk-quickdemo主目录导图》](https://rongcloud.yuque.com/docs/share/6d9595fe-3be4-4039-a6fd-30a605050d6d?#%20《ios-voiceroomsdk-quickdemo主目录导图》)
[^脚注3]:快捷键:Comand + Shift + O (字母O)


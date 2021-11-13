# README

## 前置条件

1. 为了方便您快速运行quickdemo，我们为您预置了融云 appkey 和 对应的测试服务器url，您不需要自己部署测试服务器即可运行。
2. 申请  `BusinessToken`
   1. BusinessToken 主要是防止滥用 quickdemo 里的测试appKey，我们为接口做了限制，一个 BusinessToken 最多可以支持10个用户注册，20天使用时长。
   2. 过期后您的注册用户会自动移除，想继续使用 quickdemo 需要您重新申请 BusinessToken
   3. 成功获取到 BusinessToken 后，替换 VRSDefine.h 中定义的 BusinessToken
   
![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/blob/main/img/business_token.png)


## 运行Demo

## 登录

1. 登录
   - 手机号登录
   
![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/blob/main/img/login.jpg)

## 房间创建

1. 创建房间
   * 点击视图右上角+号
   
   ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/blob/main/img/create.jpg)
   
2. 加入房间
   * 点击首页列表
   
   ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/blob/main/img/list.jpg)

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

   ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/blob/main/img/host.jpg)
   
   ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/blob/main/img/audience.jpg)

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

  <img src="/Users/xuefeng/Desktop/host_sheet.jpg" alt="host_sheet" style="zoom:25%;" />

  <img src="/Users/xuefeng/Desktop/aduience_sheet.jpg" alt="aduience_sheet" style="zoom:25%;" />
  
  ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/blob/main/img/host_sheet.jpg)
     
  ![image](https://github.com/rongcloud/ios-voiceroom-quickdemo/blob/main/img/aduience_sheet.jpg)

更多细节可参照示例代码。

示例代码展示了基本的api调用


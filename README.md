# README

## 前置条件

1. 申请融云AppKey

2. 在开发者后台开通 `音视频直播`

3. 在开发者后台按照如下顺序创建用户，获取token

   1. 进入`服务管理`

   2. 在左边`IM服务`中，点击`API调用`

      如图![](https://tva1.sinaimg.cn/large/008i3skNly1guhg4rn2xuj60aw0kiq3l02.jpg)

      3. 点击`获取用户token`
      4. 随后，你会看到如下界面

      ![](https://tva1.sinaimg.cn/large/008i3skNly1guhgfnvz4pj61yt0u0aev02.jpg)

   5. 点击提交之后，在HTTP Response 中你会得到如下数据

   ```
   {"code":200,"userId":"1631699003","token":"J7l5qEUFD2UOstvSmbkyTa0Oah91uycXlawyBR/l+NA=@4vsh.cn.rongnav.com;4vsh.cn.rongcfg.com"}
   ```

   记住token的value。

   6. 打开 iOS 工程文件，在 `AppDelegate` 文件中，找到 `setupThirdParty`方法，替换方法内的 `appKey` 和 `token` .运行程序即可。

## 运行Demo

1. 创建房间
   * 点击视图右上角+号
   * 输入房间id，点击确定
2. 加入房间
   * 点击视图右上角+号
   * 输入房间id，点击确定

如图所示![](https://tva1.sinaimg.cn/large/008i3skNly1guhhxfsw23j60u01ky76r02.jpg)



## 进入房间

进入房间后如图所示

![](https://tva1.sinaimg.cn/large/008i3skNly1guhhygvp8ij60u01kyjw702.jpg)

可参照示例代码。

示例代码展示了基本的api调用
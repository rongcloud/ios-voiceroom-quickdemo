//
//  Define.h
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/26.
//

static NSString *const LoginSuccessNotification = @"LoginSuccessNotificationIdentifier";

//融云官网申请的 app key
#define AppKey  @"pvxdm17jpw7ar"

//请前往 https://rcrtc-api.rongcloud.net/code 获取 BusinessToken
#define BusinessToken @""

//如果要是用第三方CDN，在这里填写申请好的 push/pull url
#define RCVO_PUSH_HOST @""
#define RCVO_PULL_HOST @""

//主色调
#define mainColor [UIColor colorFromHexString:@"#EF499A"]

//log
#define Log(fmt, ...) NSLog((@":" fmt), ##__VA_ARGS__);

//LocalizedString
#define LocalizedString(x) \
[[NSBundle mainBundle] localizedStringForKey:x value:@"" table:nil]


#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//weak strong

#define WeakSelf(type) __weak __typeof__(type) weakSelf = type;

#define StrongSelf(type) __strong __typeof__(type) strongSelf = type;

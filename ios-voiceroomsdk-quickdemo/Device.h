//
//  Device.h
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/25.
//

#import <UIKit/UIKit.h>

__attribute__((unused)) static NSString * _deviceID() {
    
    static NSString *did = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        did = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    });

    return did;
}

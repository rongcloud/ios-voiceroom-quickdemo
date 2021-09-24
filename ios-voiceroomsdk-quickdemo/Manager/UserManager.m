//
//  UserManager.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/24.
//

#import "UserManager.h"

@implementation UserManager

+ (UserManager *)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^
                  {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end

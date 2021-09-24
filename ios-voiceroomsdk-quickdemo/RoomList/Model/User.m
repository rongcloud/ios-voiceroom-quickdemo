//
//  User.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/24.
//

#import "User.h"

@implementation User

- (instancetype)initWithUserId:(NSString *)userId withToken:(NSString *)token {
    if (self = [super init]) {
        self.userId = userId;
        self.token = token;
    }
    return self;
}

@end

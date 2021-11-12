//
//  User.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/24.
//

#import "User.h"

@interface User ()<NSCoding>

@end

@implementation User

+ (instancetype)currentUser {
    
    static dispatch_once_t onceToken;
    static User *user;
    
    dispatch_once(&onceToken, ^{
        NSString *path = [[self class] path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            user = [NSKeyedUnarchiver unarchiveObjectWithData: [NSData dataWithContentsOfFile:path]];
        } else {
            user = [[User alloc] init];
        }
    });

    return user;
}

//持久化对象保存的沙河路径
+ (NSString *)path {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [paths objectAtIndex:0];
    NSString *path = [document stringByAppendingPathComponent:@"voice.user.data"];
    return path;
}

//持久化当前对象
- (BOOL)save {
    return [NSKeyedArchiver archiveRootObject:self toFile:[[self class] path]];
}

#pragma mark - NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeObject:self.userName forKey:@"userName"];
    [coder encodeObject:self.authorization forKey:@"authorization"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _userId = [[coder decodeObjectForKey:@"userId"] copy];
        _token = [[coder decodeObjectForKey:@"token"] copy];
        _userName = [[coder decodeObjectForKey:@"userName"] copy];
        _authorization = [[coder decodeObjectForKey:@"authorization"] copy];
    }
    return self;
}
@end

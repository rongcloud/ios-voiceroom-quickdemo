//
//  UserManager.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/24.
//

#import <Foundation/Foundation.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject

@property (nonatomic, strong) User *currentUser;

+ (UserManager *)sharedManager;

@end

NS_ASSUME_NONNULL_END

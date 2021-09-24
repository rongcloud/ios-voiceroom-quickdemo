//
//  User.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *token;

- (instancetype)initWithUserId:(NSString *)userId withToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END

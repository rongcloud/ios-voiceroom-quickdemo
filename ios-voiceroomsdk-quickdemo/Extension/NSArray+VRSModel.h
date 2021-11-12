//
//  NSArray+VRSModel.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by xuefeng on 2021/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (VRSModel)
- (NSArray *)vrs_jsonsToModelsWithClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END

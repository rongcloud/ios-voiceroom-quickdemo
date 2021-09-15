//
//  UIColor+Hex.h
//  ios-voiceroomsdk-quickdemo
//
//  Created by 叶孤城 on 2021/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END

//
//  NSArray+VRSModel.m
//  ios-voiceroomsdk-quickdemo
//
//  Created by xuefeng on 2021/11/2.
//

#import "NSArray+VRSModel.h"

@implementation NSArray (VRSModel)
- (NSArray *)vrs_jsonsToModelsWithClass:(Class)cls {
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *json in self) {
        id model = [cls yy_modelWithJSON:json];
        if (model) {
            [models addObject:model];
        }
    }
    return models;
}
@end

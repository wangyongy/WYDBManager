//
//  CopyObject.m
//  WYDBManager
//
//  Created by wangyong on 2018/5/21.
//  Copyright © 2018年 wangyong. All rights reserved.
//

#import "CopyObject.h"

@implementation CopyObject
// 解归档
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSMutableArray * propertyArr = [NSMutableArray arrayWithArray:[WYDBManager getPropertyList:NSStringFromClass([self class])]];
    for (NSString * key in propertyArr) {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        NSMutableArray * propertyArr = [NSMutableArray arrayWithArray:[WYDBManager getPropertyList:NSStringFromClass([self class])]];
        for (NSString * key in propertyArr) {
            if ([aDecoder decodeObjectForKey:key] != nil) {
                [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
            }
        }
    }
    return self;
}
//copy协议
- (id)copyWithZone:(NSZone *)zone {
    id copy = [[self class] allocWithZone:zone];
    NSMutableArray * propertyArr = [NSMutableArray arrayWithArray:[WYDBManager getPropertyList:NSStringFromClass([self class])]];
    for (NSString *property in propertyArr) {
        id value = [self valueForKey:property];
        [copy setValue:value forKey:property];
    }
    return copy;
}
@end

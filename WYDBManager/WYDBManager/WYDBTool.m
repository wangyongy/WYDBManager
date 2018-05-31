//
//  WYDBTool.m
//  WYDBManager
//
//  Created by wangyong on 2018/4/13.
//  Copyright © 2018年 ipanel. All rights reserved.
//

#import "WYDBTool.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "FMDB.h"
#import <UIKit/UIKit.h>
@implementation WYDBTool

+ (NSMutableArray *)getPropertyList:(NSString *)className
{
    
    NSArray *ignoreNames = nil;
    
    Class class = NSClassFromString(className);
    
    /**
     忽略字段，须实现该类方法
     */
    if ([class respondsToSelector:NSSelectorFromString(@"ignoreColumnNames")]) {
        
        ignoreNames = ((NSArray * (*)(id, SEL))objc_msgSend)(class,NSSelectorFromString(@"ignoreColumnNames"));
    }
    
    NSMutableArray *cachePropertyListArray = [[WYCache shareInstance] objectForKey:className];
    
    if (cachePropertyListArray) {
        
        return cachePropertyListArray;
    }
    
    unsigned int count;
    
    Ivar * vars = class_copyIvarList(NSClassFromString(className), &count);
    
    NSMutableArray * propertyArr = [NSMutableArray array];
    
    for (int i = 0; i < count; i++) {
        
        Ivar var = vars[i];
        
        // 获取成员变量名称
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(var)];
        
        // 忽略字段
        if ([ignoreNames containsObject:ivarName]) {
            continue;
        }
        
        [propertyArr addObject:ivarName];
    }
    
    free(vars);
    
    [[WYCache shareInstance] setObject:propertyArr forKey:className];
    
    return propertyArr;
}
+ (id)formatModelValue:(id)value key:(NSString *)key type:(NSString *)type set:(FMResultSet *) set isEncode:(BOOL)isEncode
{
    
    if ([type containsString:@"@\""]) {
        
        NSArray * arr = [type componentsSeparatedByString:@"@\""];
        
        NSString * temp = [arr lastObject];
        
        type = [temp substringToIndex:temp.length - 1];
    }
    
    if (isEncode && value == nil) { // 只有对象才能为nil，基本数据类型没值时为0
        
        return @"";
    }
    
    if (!isEncode && [value isKindOfClass:[NSString class]] && [value isEqualToString:@""]) {
        
        return [NSClassFromString(type) new];
    }
    
    if ([type containsString:@"String"]) {
        
        if (isEncode) {
            
            return value;
            
        }else{
            
            return [[NSClassFromString(type) alloc] initWithString:set ? [set stringForColumn:key] : value] ;
        }
    }
    
    if ([type containsString:@"NSData"] || [type containsString:@"NSMutableData"]) {
        
        if (isEncode) {
            
            return value;
            
        }else {
            
            return [[NSClassFromString(type) alloc] initWithData:set ? [set dataForColumn:key] : value];
        }
    }
    
    if ([type containsString:@"NSURL"]){
        
        if(isEncode){
            
            return [value isKindOfClass:[NSURL class]] ? [value absoluteString] : value;
            
        }else{
            
            return [NSURL URLWithString:set ? [set stringForColumn:key] : value];
        }
    }
    
    /*
     *  更多相关类型，用到时可以自行补充，如EdgeInsets等
     */
    if ([type containsString:@"NSRange"] || [type containsString:@"CGRect"] || [type containsString:@"CGPoint"] || [type containsString:@"CGSize"]){
        
        NSString * tempValue = set ? [set stringForColumn:key] : value;
        
        NSValue * returnValue;
        
        if ([type containsString:@"NSRange"]) {
            
            returnValue = [NSValue valueWithRange:NSRangeFromString(tempValue)];
            
        }else if ([type containsString:@"CGRect"]) {
            
            returnValue = [NSValue valueWithCGRect:CGRectFromString(tempValue)];
            
        }else if ([type containsString:@"CGSize"]) {
            
            returnValue = [NSValue valueWithCGSize:CGSizeFromString(tempValue)];
            
        }else if ([type containsString:@"CGPoint"]) {
            
            returnValue = [NSValue valueWithCGPoint:CGPointFromString(tempValue)];
            
        }else{
            
            returnValue = [NSValue valueWithPointer:(__bridge const void * _Nullable)(tempValue)];
        }
        
        return returnValue;
    }
    if ([type isEqualToString:@"UIImage"]) {
        
        if (isEncode) {
            
            return [value isKindOfClass:[UIImage class]] ? UIImageJPEGRepresentation(value, 1) : value;
            
        }else {
            
            return [UIImage imageWithData:set ? [set dataForColumn:key] : value];
        }
    }
    
    if ([type containsString:@"Array"]) {
        
        if (isEncode) {
            
            return [value isKindOfClass:[NSArray class]] ? [self dataWithArray:value key:key] : value;
            
        }else{
            
            return [self arrayWithData:value key:key type:type set:set];
        }
    }
    if ([type containsString:@"Dictionary"] && [type containsString:@"NS"]) {
        
        if (isEncode) {
            
            return [value isKindOfClass:[NSDictionary class]] ? [self dataWithDic:value key:key] : value;
            
        }else {
            
            return [self dicWithData:value key:key type:type set:set];
        }
    }
    
    @try {
        if (isEncode) {
            
            return [NSKeyedArchiver archivedDataWithRootObject:value];
            
        }else{
            
            return [NSKeyedUnarchiver unarchiveObjectWithData:set ? [set dataForColumn:key] : value];
        }
    }
    
    @catch (NSException *exception) {
        
        return [NSClassFromString(type) new];
    }
    
    return [NSClassFromString(type) new];
}
+ (NSString*)getSqlType:(NSString*)type
{
    if([type isEqualToString:@"i"]||[type isEqualToString:@"I"]||
       [type isEqualToString:@"s"]||[type isEqualToString:@"S"]||
       [type isEqualToString:@"q"]||[type isEqualToString:@"Q"]||
       [type isEqualToString:@"b"]||[type isEqualToString:@"B"]||
       [type isEqualToString:@"c"]||[type isEqualToString:@"C"]|
       [type isEqualToString:@"l"]||[type isEqualToString:@"L"]) {
        return @"integer";
    }else if([type isEqualToString:@"f"]||[type isEqualToString:@"F"]||
             [type isEqualToString:@"d"]||[type isEqualToString:@"D"]){
        return @"real";
    }else{
        return @"text";
    }
}
+ (BOOL)isObjectType:(NSString *)type
{
    return !([type isEqualToString:@"i"]||[type isEqualToString:@"I"]||
             [type isEqualToString:@"s"]||[type isEqualToString:@"S"]||
             [type isEqualToString:@"q"]||[type isEqualToString:@"Q"]||
             [type isEqualToString:@"b"]||[type isEqualToString:@"B"]||
             [type isEqualToString:@"c"]||[type isEqualToString:@"C"]||
             [type isEqualToString:@"l"]||[type isEqualToString:@"L"]||
             [type isEqualToString:@"f"]||[type isEqualToString:@"F"]||
             [type isEqualToString:@"d"]||[type isEqualToString:@"D"]
             );
}
#pragma mark -
+ (id)dataWithDic:(id)value key:(NSString *)key
{
    NSDictionary * dic = [NSDictionary dictionaryWithDictionary:value];
    
    for (NSString * tempKey in dic.allKeys) {
        
        id value = [dic valueForKey:tempKey];
        
        if ([value isKindOfClass:[NSData class]] || [value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            
            break;
        }
        
        if ([value respondsToSelector:@selector(encodeWithCoder:)]) {
            
            [key setValue:[self formatModelValue:value key:key type:NSStringFromClass([value class]) set:nil isEncode:YES] ? : value forKey:tempKey];
        }
    }
    
    value = dic;
    
    value = [NSKeyedArchiver archivedDataWithRootObject:value];
    
    return value;
}
+ (id)dicWithData:(id)value key:(NSString *)key type:(NSString *)type set:(FMResultSet *) set
{
    NSDictionary * dic = [NSKeyedUnarchiver unarchiveObjectWithData:[set dataForColumn:key]];
    
    for (NSString * tempKey in dic.allKeys) {
        
        id value = [dic valueForKey:tempKey];
        
        if ([value isKindOfClass:[NSData class]]) {
            
            id tempData = [self formatModelValue:value key:key type:NSStringFromClass([value class]) set:nil isEncode:NO];
            
            [key setValue:tempData ? : value forKey:tempKey];
        }
    }
    
    return [[NSClassFromString(type) alloc] initWithDictionary:dic];
}
+ (id)dataWithArray:(id)array key:(NSString *)key
{
    
    if (![array isKindOfClass:[NSArray class]]) {
        
        return [NSMutableArray array];
    }
    
    NSMutableArray * dataArray = [NSMutableArray arrayWithArray:array];
    
    for (id value in array) {
        
        if ([value isKindOfClass:[NSData class]] || [value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            
            break;
        }
        
        if ([value respondsToSelector:@selector(encodeWithCoder:)]) {
            
            [dataArray replaceObjectAtIndex:[array indexOfObject:value] withObject:[self formatModelValue:value key:key type:NSStringFromClass([value class]) set:nil isEncode:YES]];
        }
    }
    
    array = dataArray;
    
    array = [NSKeyedArchiver archivedDataWithRootObject:array];
    
    return array;
}
+ (id)arrayWithData:(id)value key:(NSString *)key type:(NSString *)type set:(FMResultSet *) set
{
    NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithData:[set dataForColumn:key]];
    
    NSMutableArray * dataArray = [array mutableCopy];
    
    for (id value in array) {
        
        if ([value isKindOfClass:[NSData class]]) {
            
            id tempData = [self formatModelValue:value key:key type:NSStringFromClass([value class]) set:nil isEncode:NO];
            
            [dataArray replaceObjectAtIndex:[array indexOfObject:value] withObject:tempData];
        }
    }
    
    return [[NSClassFromString(type) alloc] initWithArray:dataArray];
}
@end
@implementation WYCache

+ (instancetype)shareInstance {
    
    static WYCache *cache = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        cache = [[WYCache alloc] init];
    });
    
    return cache;
}
@end

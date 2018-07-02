//
//  WYDBTool.h
//  WYDBManager
//
//  Created by wangyong on 2018/4/13.
//  Copyright © 2018年 ipanel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;

@interface WYDBTool : NSObject

/**
 *  获取类的属性列表，会将已经获取过的属性列表缓存起来
 *
 *  @param className 需要获取模型列表的类名
 *  @return 类的属性字符串列表数组
 */
+ (NSMutableArray *)getPropertyList:(NSString *)className;
/**
 *  获取类的属性类型列表，会将已经获取过的属性类型列表缓存起来
 *
 *  @param className 需要获取模型列表的类名
 *  @return 类的属性类型列表数组
 */
+ (NSMutableArray *)getIvarTypeList:(NSString *)className;
/**
 *  转换读和存对应的数据类型
 
 *  @param value        属性值
 *  @param key          属性名
 *  @param set          FMResultSet
 *  @param isEncode     读或者取
 *  @return 对应类型的数据
 */
+ (id)formatModelValue:(id)value key:(NSString *)key type:(NSString *)type set:(FMResultSet *) set isEncode:(BOOL)isEncode;
/**
 *  通过属性类型对应字段获取数据库操作类型
 
 *  @param type         用runtime得到的属性类型对应字段
 *  @return             数据库操作类型
 */
+ (NSString*)getSqlType:(NSString*)type;
/**
 *  根据ivarName类型来判断是否是OC类型
 
 *  @param type  ivarName
 *  @return YES 属于OC类型， NO则不属于
 */
+ (BOOL)isObjectType:(NSString *)type;
@end

@protocol WYDBModelProtocol <NSObject>

@required
/**
 * 操作模型必须实现的方法，通过这个方法获取主键信息
 * @return 主键字符串
 */
+ (NSString *)primaryKey;

@end

@interface WYCache : NSCache

+ (instancetype)shareInstance;

@end

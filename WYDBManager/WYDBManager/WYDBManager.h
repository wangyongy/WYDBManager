//
//  WYDBManager.h
//  WYDBManager
//
//  Created by 王勇 on 2018/5/31.
//  Copyright © 2018年 wangyong. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN  NSString * const relationG;              //greater
FOUNDATION_EXTERN  NSString * const relationGE;             //greater or equal
FOUNDATION_EXTERN  NSString * const relationE;              //equal
FOUNDATION_EXTERN  NSString * const relationL;              //less
FOUNDATION_EXTERN  NSString * const relationLE;             //less or equal

@interface WYDBManager : NSObject
#pragma mark -
/**
 *  获取类的属性列表
 *
 *  @param className 需要获取模型列表的类名
 *  @return 类的属性字符串列表数组
 */
+ (NSMutableArray *)getPropertyList:(NSString *)className;

#pragma mark -  增
/**
 *  插入数据
 
 *  @param model        给定模型
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 */
+ (void)insertData:(id)model descName:(NSString *)descName;
/**
 *  写入数据
 
 *  @param arr          将该数组中的数据写入数据库
 *  @param tableClass   数组中模型的class
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 */
+ (void)initDataBaseWithArr:(NSArray *)arr tableClass:(Class)tableClass descName:(NSString *)descName;
#pragma mark - 删
/**
 *  删除给定表数据
 
 *  @param tableClass   模型的class
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 */
+ (void)deleteTable:(Class)tableClass descName:(NSString *)descName;
/**
 *  删除给定数据
 
 *  @param model        给定模型
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 */
+ (void)deleteData:(id)model descName:(NSString *)descName;
/**
 *  条件删除数据
 
 *  @param tableClass   模型的class
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 *  @param primaryValue 主键参考值
 *  @param relation     被删除的文件的主键与参考值之间的关系
 */
+ (void)deleteData:(Class)tableClass descName:(NSString *)descName primaryValue:(NSString *)primaryValue relation:(NSString *)relation;
#pragma mark - 改
/**
 
 *  @param model        给定模型
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 *  更改指定模型数据
 */
+ (void)updateWithModel:(id)model descName:(NSString *)descName;
/**
 *  更改指定表中所有数据某些属性的值
 
 *  @param tableClass   模型的class
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 *  @param keys         要更改的属性名数组
 *  @param values       要更改的属性值数组
 */
+ (void)updateWithTable:(Class)tableClass descName:(NSString *)descName keys:(NSArray *)keys values:(NSArray *)values;
/**
 *  更改指定模型某些属性的值
 
 *  @param model        给定模型
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 *  @param keys         要更改的属性名数组
 */
+ (void)updateWithModel:(id)model descName:(NSString *)descName keys:(NSArray *)keys;
#pragma mark - 查
/**
 *  查询数据
 
 *  @param tableClass   模型的class
 *  @return 指定表中要查询的的数据数组
 */
+ (NSMutableArray *)selectWithTableClass:(Class)tableClass;
/**
 *  查询数据
 
 *  @param tableClass   模型的class
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 *  @return 指定表中要查询的的数据数组
 */
+ (NSMutableArray *)selectWithTableClass:(Class)tableClass descName:(NSString *)descName;

/*
 *  条件查询数据
 
 *  @param tableClass   模型的class
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 *  @param primaryValue 主键参考值
 *  @param relation     查询文件的主键与参考值之间的关系   如>,<,>=,<=,==
 *  @return 指定表中要查询的的数据数组
 */
+ (NSMutableArray *)selectWithTableClass:(Class)tableClass descName:(NSString *)descName primaryValue:(NSString *)primaryValue relation:(NSString *)relation;

/*
 *  分页查询数据
 
 *  @param tableClass   模型的class
 *  @param descName     表名=className+descNameConnector+descName,如果为空，则表名为className
 *  @param pageIndex    分页索引，即第几页,取值从1开始
 *  @param pageSize     分页个数，即每页多少个 须>0
 *  @return 指定表中要查询的的数据数组
 */
+ (NSMutableArray *)selectWithTableClass:(Class)tableClass descName:(NSString *)descName pageIndex:(NSInteger)pageIndex pageSize:(NSInteger )pageSize;
@end

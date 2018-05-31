//
//  Person.h
//  WYDBManager
//
//  Created by wangyong on 2018/5/21.
//  Copyright © 2018年 wangyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CopyObject.h"
@class Dog;

/*
 *  示范model，如有其他类型的属性，可在WYDBTool里的+ (id)formatModelValue:(id)value key:(NSString *)key type:(NSString *)type set:(FMResultSet *) set isEncode:(BOOL)isEncode方法里同步添加一下
 */
@interface Person : CopyObject

@property (nonatomic, assign) NSInteger dataBaseIndex;          //主键

@property (nonatomic, copy) NSString * name;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, assign) CGFloat height;

@property(nonatomic, strong) NSDate * testDate;

@property (nonatomic, strong) Dog * dog;

@property (nonatomic, strong) NSMutableArray <Dog *>* dogArray;

@property (nonatomic, strong) UIImage * dogImage;

@property (nonatomic, strong) UIColor * dogColor;

@property (nonatomic, assign) NSRange range;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, strong) NSURL * personUrl;

@property (nonatomic, strong) NSData * personData;

@end

@interface Dog : CopyObject

@property (nonatomic, copy) NSString * dogID;

@property (nonatomic, copy) NSString * name;

@property (nonatomic, assign) NSInteger age;

@end

//
//  WYDBManager.m
//  WYDBManager
//
//  Created by 王勇 on 2018/5/31.
//  Copyright © 2018年 wangyong. All rights reserved.
//

#import "WYDBManager.h"
#import "FMDB.h"
#import "WYDBTool.h"
#import <objc/runtime.h>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

NSString * const relationG = @">";
NSString * const relationGE = @">=";
NSString * const relationE = @"=";
NSString * const relationL = @"<";
NSString * const relationLE = @"<=";

NSString * const descNameConnector = @"DescNameConnector";

@implementation WYDBManager
{
    FMDatabaseQueue * _queue;
}
#pragma mark - public
+ (NSMutableArray *)getPropertyList:(NSString *)className
{
    return [WYDBTool getPropertyList:className];
}
+ (void)initDataBaseWithArr:(NSArray *)arr tableClass:(Class)tableClass
{
    [self initDataBaseWithArr:arr tableClass:tableClass descName:nil];
}
+ (void)initDataBaseWithArr:(NSArray *)arr tableClass:(Class)tableClass descName:(NSString *)descName
{
    WYDBManager * manager = [WYDBManager shareInstance];
    
    if (arr.count > 0) {
        
        NSString * className = NSStringFromClass(tableClass);
        
        [manager createTabelWithClassName:className descName:descName];
        
        NSMutableArray * array = [NSMutableArray arrayWithArray:[self selectWithTableClass:tableClass descName:descName]];
        
        if (array.count > 0) {
            
            [manager deleteDBWithClassName:className descName:descName primaryValue:0 relation:nil];
        }
        
        for (NSInteger i = 0; i < arr.count; i++) {
            
            id model = arr[i];
            
            [manager insertDBWithModel:model descName:descName];
        }
    }
}
+ (void)insertData:(id)model
{
    [self insertData:model descName:nil];
}
+ (void)insertData:(id)model descName:(NSString *)descName
{
    WYDBManager * manager = [WYDBManager shareInstance];
    
    NSString * className = NSStringFromClass([model class]);
    
    [manager createTabelWithClassName:className descName:descName];
    
    [manager insertDBWithModel:model descName:descName];
}
+ (void)deleteTable:(Class)tableClass descName:(NSString *)descName
{
    [[WYDBManager shareInstance] deleteDBWithClassName:NSStringFromClass(tableClass) descName:descName primaryValue:0 relation:nil];
}
+ (void)deleteData:(id)model descName:(NSString *)descName
{
    [[WYDBManager shareInstance] deleteDBWithClassName:NSStringFromClass([model class]) descName:descName primaryValue:[[model valueForKey:[[model class] primaryKey]] integerValue] relation:relationE];
}
+ (void)deleteData:(Class)tableClass descName:(NSString *)descName primaryValue:(NSInteger)primaryValue relation:(NSString *)relation
{
    [[WYDBManager shareInstance] deleteDBWithClassName:NSStringFromClass(tableClass) descName:descName primaryValue:primaryValue relation:relation];
}
+ (void)updateWithModel:(id)model descName:(NSString *)descName
{
    [[WYDBManager shareInstance] updateDBWithModel:model descName:descName];
}
+ (void)updateWithTable:(Class)tableClass descName:(NSString *)descName keys:(NSArray *)keys values:(NSArray *)values
{
    [[WYDBManager shareInstance] updateWithTable:tableClass descName:descName keys:keys values:values];
}
+ (void)updateWithModel:(id)model descName:(NSString *)descName keys:(NSArray *)keys
{
    [[WYDBManager shareInstance] updateWithModel:model descName:descName keys:keys];
}
+ (NSMutableArray *)selectWithTableClass:(Class)tableClass
{
    return [self selectWithTableClass:tableClass descName:nil primaryValue:0 relation:nil];
}
+ (NSMutableArray *)selectWithTableClass:(Class)tableClass descName:(NSString *)descName
{
    return [self selectWithTableClass:tableClass descName:descName primaryValue:0 relation:nil];
}
+ (NSMutableArray *)selectWithTableClass:(Class)tableClass descName:(NSString *)descName primaryValue:(NSInteger)primaryValue relation:(NSString *)relation
{
    
    NSMutableArray * arr = [NSMutableArray array];
    
    NSString * className = NSStringFromClass(tableClass);
    
    WYDBManager * manager = [WYDBManager shareInstance];
    
    [arr removeAllObjects];
    
    NSArray * tempArray = [manager selectFromDBWithclassName:className descName:descName primaryValue:primaryValue relation:relation];
    
    if (tempArray.count > 0) {
        
        for (id model in tempArray) {
            
            [arr addObject:model];
        }
    }
    
    return arr;
}
+ (NSMutableArray *)selectWithTableClass:(Class)tableClass descName:(NSString *)descName pageIndex:(NSInteger)pageIndex pageSize:(NSInteger )pageSize
{
    NSMutableArray * arr = [NSMutableArray array];
    
    NSString * className = NSStringFromClass(tableClass);
    
    WYDBManager * manager = [WYDBManager shareInstance];
    
    [arr removeAllObjects];
    
    NSArray * tempArray = [manager selectFromDBWithclassName:className descName:descName pageIndex:pageIndex pageSize:pageSize];
    
    if (tempArray.count > 0) {
        
        for (id model in tempArray) {
            
            [arr addObject:model];
        }
    }
    
    return arr;
}
#pragma mark - private
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static WYDBManager * manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[WYDBManager alloc] init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/db.sqlite"];
        
        NSLog(@"table path:%@",path);
        
        _queue = [[FMDatabaseQueue alloc] initWithPath:path];
        
        /**
         *  这里是model有更新就删表，如果有数据库迁移方案就注释掉
         */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self syncClassesAndTables];
        });
    }
    return self;
}

- (void)syncClassesAndTables{
    
    NSString * getTablesSql = @"select * from sqlite_master where type = 'table'";
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *dropSqlArr = [[NSMutableArray alloc]init];
        
        FMResultSet * tableSet = [db executeQuery:getTablesSql];
        
        while ([tableSet next]) {
            
            NSString* tName = [tableSet stringForColumn:@"name"];
            
            NSString *getColumnsSql = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tName];
            
            FMResultSet *columnSet = [db executeQuery:getColumnsSql];
            
            NSMutableArray *columnNameArr = [[NSMutableArray alloc] init];
            
            while([columnSet next]){
                
                NSString *cname = [columnSet stringForColumn:@"name"];
                
                [columnNameArr addObject:cname];
            }
            
            NSString * className = [[tName componentsSeparatedByString:descNameConnector] firstObject];
            
            NSMutableArray *propertyArr = [[self class] getPropertyList:className];
            
            BOOL isSync = YES;
            
            /* 判断类的属性和表的列是否一致 */
            if(propertyArr.count != columnNameArr.count){
                
                isSync = NO;
            }else{
                
                NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
                
                NSArray *descriptors = [NSArray arrayWithObject:descriptor];
                
                NSArray *sortedPropertyArr = [propertyArr sortedArrayUsingDescriptors:descriptors];
                
                NSArray *sortedColumnArr = [columnNameArr sortedArrayUsingDescriptors:descriptors];
                
                NSInteger i = 0;
                
                for(NSString *pname in sortedPropertyArr){
                    
                    NSString *columnName = sortedColumnArr[i++];
                    
                    if([pname isEqualToString:columnName] == NO){
                        
                        isSync = NO;
                        
                        break;
                    }
                }
            }
            
            /* 试着选择一下，有错误也删除表 */
            if (isSync == YES){
                @try {
                    
                    NSString * trySql = [NSString stringWithFormat:@"select * from %@ limit 1",tName];
                    
                    NSArray * propertyArr = [[self class] getPropertyList:className];
                    
                    FMResultSet * set = [db executeQuery:trySql];
                    
                    unsigned int count;
                    
                    Ivar * vars = class_copyIvarList(NSClassFromString(className), &count);
                    
                    while ([set next]) {
                        
                        id obj = [[NSClassFromString(className) alloc] init];
                        
                        for (int i = 0; i < count; i++) {
                            
                            Ivar var = vars[i];
                            
                            NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
                            
                            if(![WYDBTool isObjectType:type]) {
                                
                                [obj setValue:[set stringForColumn:propertyArr[i]] forKey:propertyArr[i]];
                                
                                continue;
                            }
                            
                            id value = [WYDBTool formatModelValue:nil key:propertyArr[i] type:type set:set isEncode:NO];
                            
                            [obj setValue:value forKey:propertyArr[i]] ;
                        }
                    }
                }
                @catch (NSException *exception) {
                    isSync = NO;
                }
            }
            if(isSync == NO){
                
                NSString *dropTabelSql = [NSString stringWithFormat:@"drop table %@",tName];
                
                [dropSqlArr addObject:dropTabelSql];
            }
        }
        
        [db closeOpenResultSets];
        
        for(NSString *sql in dropSqlArr){
            
            [db executeUpdate:sql];
        }
    }];
}

/**
 *  将model的属性转化成可以存放到数据库中的属性
 */
- (id)dealModel:(id)model
{
    
    if (model == nil) return nil;
    
    id tempModel;
    
    if ([model respondsToSelector:@selector(copyWithZone:)]) {
        
        tempModel = [model copy];
        
    }else{
        
        tempModel = model;
    }
    
    NSString * className = NSStringFromClass(object_getClass(model));
    
    NSArray * propertyArr = [[self class] getPropertyList:className];
    
    unsigned int count;
    
    Ivar * vars = class_copyIvarList(NSClassFromString(className), &count);
    
    for (int i = 0; i < count; i++) {
        
        Ivar var = vars[i];
        
        NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
        
        if(![WYDBTool isObjectType:type] || [type containsString:@"NSRange"] || [type containsString:@"CGRect"] || [type containsString:@"CGPoint"] || [type containsString:@"CGSize"]) {
            
            continue;
        }
        
        id data = object_getIvar(model, var);
        
        id tempData = [WYDBTool formatModelValue:data key:[NSString stringWithUTF8String:ivar_getName(var)] type:type set:nil isEncode:YES];
        
        [tempModel setValue:tempData ? : @"" forKey:propertyArr[i]];
    }
    
    free(vars);
    
    return tempModel;
}
/**
 *  @return 表名
 */
- (NSString *)tableName:(NSString *)className descName:(NSString *)descName
{
    NSString * tableName = className;
    
    if (!([descName isEqualToString:@"*"] || descName.length == 0 || descName == nil)) {
        
        tableName = [NSString stringWithFormat:@"%@%@%@",className,descNameConnector,descName?:@""];
    }
    
    return tableName;
}
/**
 *  创建表
 */
- (void)createTabelWithClassName:(NSString *)className descName:(NSString *)descName
{
    if (![NSClassFromString(className) respondsToSelector:@selector(primaryKey)]) {
        
        NSLog(@"实现 + (NSString *)primaryKey;");
        
        return;
    }
    
    // 获取主键
    NSString *primaryKey = [NSClassFromString(className) primaryKey];
    
    if (!primaryKey) {
        
        NSLog(@"指定一个主键");
        
        return;
    }
    
    NSString * sql1 = [NSString stringWithFormat:@"create table if not exists %@",[self tableName:className descName:descName]];
    
    NSArray * propertyArr = [[self class] getPropertyList:className];
    
    NSMutableString * sql2 = [NSMutableString string];
    
    unsigned int count;
    
    Ivar * vars = class_copyIvarList(NSClassFromString(className), &count);
    
    for (NSInteger i = 0; i < count; i++) {
        
        Ivar var = vars[i];
        
        NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
        
        (i == 0)?[sql2 appendFormat:@"%@ %@",propertyArr[i],[WYDBTool getSqlType:type]]:[sql2 appendFormat:@",%@ %@",propertyArr[i],[WYDBTool getSqlType:type]];
    }
    
    NSString * sql = [NSString stringWithFormat:@"%@(%@ ,primary key(%@))",sql1,sql2,primaryKey];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        if (![db executeUpdate:sql]) {
            
            NSLog(@"create table%@ error",className);
        }
    }];
}

#pragma mark -  增删改查
- (void)insertDBWithModel:(id)model descName:(NSString *)descName
{
    if (model == nil) return;
    
    model = [self dealModel:model];
    
    NSString * className = NSStringFromClass(object_getClass(model));
    
    [self createTabelWithClassName:className descName:className];
    
    NSArray * propertyArr = [[self class] getPropertyList:className];
    
    NSString * sql1 = [NSString stringWithFormat:@"insert into %@",[self tableName:className descName:descName]];
    
    NSMutableString * key = [NSMutableString string];
    
    NSMutableString * value = [NSMutableString string];
    
    NSMutableArray * argumentArr = [NSMutableArray array];
    
    for (NSInteger i = 0 ; i < propertyArr.count; i++) {
        
        (i == 0)?[key appendFormat:@"%@",propertyArr[i]]:[key appendFormat:@",%@",propertyArr[i]];
        
        (i == 0)?[value appendFormat:@"?"]:[value appendFormat:@",?"];
        
        if ([model valueForKey:propertyArr[i]] == nil) {
            
            [argumentArr addObject:@"*"];
            
        }else
            
            [argumentArr addObject:[model valueForKey:propertyArr[i]]];
    }
    
    NSString * sql = [NSString stringWithFormat:@"%@(%@) values(%@)",sql1,key,value];
    
    [_queue inDatabase:^(FMDatabase *db) {
        if (db) {
            
            if (![db executeUpdate:sql withArgumentsInArray:argumentArr]) {
                
                NSLog(@"insert error");
            }
        }else{
            NSLog(@"db error");
        }
    }];
}
- (void)deleteDBWithClassName:(NSString *)className descName:(NSString *)descName primaryValue:(NSInteger)primaryValue relation:(NSString *)relation
{
    NSString * sql = [NSString stringWithFormat:@"delete from %@",[self tableName:className descName:descName]];
    
    if (!([relation isEqualToString:@"*"] || relation.length == 0 || relation == nil)) {
        
        sql = [NSString stringWithFormat:@"%@ where %@ %@ '%zd'",sql,[NSClassFromString(className) primaryKey],relation,primaryValue];
    }
    
    [_queue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql]) {
            NSLog(@"delete error");
        }
    }];
}
- (void)updateDBWithModel:(id)model descName:(NSString *)descName
{
    if (model == nil) return;
    
    model = [self dealModel:model];
    
    NSString * className = [NSString stringWithUTF8String:object_getClassName(model)];
    
    NSArray * propertyArr = [[self class] getPropertyList:className];
    
    NSString * sql1 = [NSString stringWithFormat:@"update %@ set ",[self tableName:className descName:descName]];;
    
    NSMutableString * key = [NSMutableString string];
    
    NSMutableArray * argumentArr = [NSMutableArray array];
    
    for (int i = 0; i < propertyArr.count; i++) {
        
        (i == 0)?[key appendFormat:@"%@=?",propertyArr[i]]:[key appendFormat:@",%@=?",propertyArr[i]];
        
        if ([model valueForKey:propertyArr[i]] == nil) {
            
            [argumentArr addObject:@"*"];
            
        }else
            
            [argumentArr addObject:[model valueForKey:propertyArr[i]]];
    }
    
    NSString * sql = [NSString stringWithFormat:@"%@%@ where %@=%zd",sql1,key,[[model class] primaryKey],[[model valueForKey:[[model class] primaryKey]] integerValue]];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        if (![db executeUpdate:sql withArgumentsInArray:argumentArr]) {
            NSLog(@"update error");
        }
    }];
}
- (void)updateWithTable:(Class)tableClass descName:(NSString *)descName keys:(NSArray *)keys values:(NSArray *)values
{
    NSString * className = NSStringFromClass(tableClass);
    
    NSString * sql1 = [NSString stringWithFormat:@"update %@ set ",[self tableName:className descName:descName]];
    
    NSMutableString * key = [NSMutableString string];
    
    NSMutableArray * argumentArr = [NSMutableArray array];
    
    for (int i = 0; i < keys.count; i++) {
        
        (i == 0)?[key appendFormat:@"%@=?",keys[i]]:[key appendFormat:@",%@=?",keys[i]];
        
        [argumentArr addObject:values[i]];
    }
    
    NSString * sql = [NSString stringWithFormat:@"%@%@",sql1,key];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        if (![db executeUpdate:sql withArgumentsInArray:argumentArr]) {
            NSLog(@"update error");
        }
    }];
}
- (void)updateWithModel:(id)model descName:(NSString *)descName keys:(NSArray *)keys
{
    if (model == nil) return;
    
    model = [self dealModel:model];
    
    NSString * className = [NSString stringWithUTF8String:object_getClassName(model)];
    
    NSString * sql1 = [NSString stringWithFormat:@"update %@ set ",[self tableName:className descName:descName]];;
    
    NSMutableString * key = [NSMutableString string];
    
    NSMutableArray * argumentArr = [NSMutableArray array];
    
    for (int i = 0; i < keys.count; i++) {
        
        (i == 0)?[key appendFormat:@"%@=?",keys[i]]:[key appendFormat:@",%@=?",keys[i]];
        
        if ([model valueForKey:keys[i]] == nil) {
            
            [argumentArr addObject:@"*"];
            
        }else
            
            [argumentArr addObject:keys[i]];
    }
    
    NSString * sql = [NSString stringWithFormat:@"%@%@ where %@=%zd",sql1,key,[[model class] primaryKey],[[model valueForKey:[[model class] primaryKey]] integerValue]];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        if (![db executeUpdate:sql withArgumentsInArray:argumentArr]) {
            NSLog(@"update error");
        }
    }];
}
- (NSMutableArray *)selectFromDBWithclassName:(NSString *)className descName:(NSString *)descName primaryValue:(NSInteger)primaryValue relation:(NSString *)relation
{
    
    NSString * sql = [NSString stringWithFormat:@"select * from %@",[self tableName:className descName:descName]];
    
    if (!([relation isEqualToString:@"*"] || relation.length == 0 || relation == nil)) {
        
        sql = [NSString stringWithFormat:@"%@ where %@ %@ '%zd'",sql,[NSClassFromString(className) primaryKey],relation,primaryValue];
    }
    
    NSArray * propertyArr = [[self class] getPropertyList:className];
    
    __block NSMutableArray * arr = [NSMutableArray array];
    
    unsigned int count;
    
    Ivar * vars = class_copyIvarList(NSClassFromString(className), &count);
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet * set = [db executeQuery:sql];
        
        while ([set next]) {
            
            id obj = [[NSClassFromString(className) alloc] init];
            
            for (int i = 0; i < count; i++) {
                
                Ivar var = vars[i];
                
                NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
                
                if(![WYDBTool isObjectType:type]) {
                    
                    [obj setValue:[set stringForColumn:propertyArr[i]] forKey:propertyArr[i]];
                    
                    continue;
                }
                
                id value = [WYDBTool formatModelValue:nil key:propertyArr[i] type:type set:set isEncode:NO];
                
                [obj setValue:value forKey:propertyArr[i]] ;
            }
            
            [arr addObject:obj];
        }
    }];
    
    return arr;
}
- (NSMutableArray *)selectFromDBWithclassName:(NSString *)className descName:(NSString *)descName pageIndex:(NSInteger)pageIndex pageSize:(NSInteger )pageSize
{
    NSString * sql = [NSString stringWithFormat:@"select * from %@",[self tableName:className descName:descName]];
    
    if (pageSize > 0) {
        
        sql = [NSString stringWithFormat:@"%@ LIMIT %zd OFFSET %zd",sql,pageSize,pageSize*pageIndex];
    }
    
    NSArray * propertyArr = [[self class] getPropertyList:className];
    
    __block NSMutableArray * arr = [NSMutableArray array];
    
    unsigned int count;
    
    Ivar * vars = class_copyIvarList(NSClassFromString(className), &count);
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet * set = [db executeQuery:sql];
        
        while ([set next]) {
            
            id obj = [[NSClassFromString(className) alloc] init];
            
            for (int i = 0; i < count; i++) {
                
                Ivar var = vars[i];
                
                NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
                
                if(![WYDBTool isObjectType:type]) {
                    
                    [obj setValue:[set stringForColumn:propertyArr[i]] forKey:propertyArr[i]];
                    
                    continue;
                }
                
                id value = [WYDBTool formatModelValue:nil key:propertyArr[i] type:type set:set isEncode:NO];
                
                [obj setValue:value forKey:propertyArr[i]] ;
            }
            
            [arr addObject:obj];
        }
    }];
    
    return arr;
}
@end
#pragma clang diagnostic pop

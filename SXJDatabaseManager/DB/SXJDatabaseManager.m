//
//  DatabaseManager.m
//
//  Created by xjshi on 15/7/23.
//  Copyright (c) 2015年 xjshi. All rights reserved.
//

#import "SXJDatabaseManager.h"
#import "FMDatabase.h"

@interface SXJDatabaseManager (DataTypeAffinity)

- (NSString *)affinityType:(NSString *)type;

@end

@implementation SXJDatabaseManager (DataTypeAffinity)

- (NSString *)affinityType:(NSString *)type {
    NSArray *textAffinityTypes = @[@"char",
                                   @"char *",
                                   @"NSString",
                                   @"NSNumber"];    //最好不在模型中使用NSNumber，如果存在，就存为"text"类型
    NSArray *integerAffinityTypes = @[@"bool",  //BOOL
                                      @"int",
                                      @"short",
                                      @"long",
                                      @"long long",
                                      @"unsigned char", //Boolean
                                      @"unsigned int",
                                      @"unsigned short",
                                      @"unsigned long",
                                      @"unsigned long long"];
    NSArray *numericAffinityTypes = @[@"NSDate"];
    NSArray *realAffinityType = @[@"double"];
    NSArray *blobAffinityType = @[@"NSData"];
    
    if ([textAffinityTypes containsObject:type]) {
        return @"text";
    } else if ([integerAffinityTypes containsObject:type]) {
        return @"integer";
    } else if ([numericAffinityTypes containsObject:type]) {
        return @"numeric";
    } else if ([realAffinityType containsObject:type]) {
        return @"real";
    } else if ([blobAffinityType containsObject:type]) {
        return @"blob";
    }
    return nil;
}

@end

@implementation SXJDatabaseManager

+ (SXJDatabaseManager *)sharedManager {
    static SXJDatabaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSString *dbName = [bundleName stringByAppendingPathExtension:@"sqlite"];
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:dbName];
        _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

#pragma mark - 接口
- (BOOL)createTable:(Class)aClass {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(%@)",
                     NSStringFromClass(aClass).lowercaseString,
                     [self sqlStringFromClass:aClass otherColumnNames:nil]];
    return [self executeUpdate:sql withArguments:nil];
}

//创建表，带主键
- (BOOL)createTableWithClass:(Class)aClass primaryKeyNameArray:(NSArray *)array {
    return [self createTableWithClass:aClass otherColumnNames:nil primaryKeyNameArray:array];
}

- (BOOL)createTableWithClass:(Class)aClass otherColumnNames:(NSArray *)names primaryKeyNameArray:(NSArray *)array {
    NSString *tmpStr = [NSString stringWithFormat:@"%@, constraint default_constraint primary key(%@)",[self sqlStringFromClass:aClass otherColumnNames:names],[array componentsJoinedByString:@","]];
    return [self createTableWithTableName:NSStringFromClass(aClass) detail:tmpStr];
}

- (BOOL)createTableWithTableName:(NSString *)tableName detail:(NSString *)detail {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(%@)",tableName,detail];
    return [self executeUpdate:sql withArguments:nil];
}

//插入一条数据
- (BOOL)insertModel:(id)model {
    NSDictionary *propertyDict = [model propertyListWithValue:YES];
    NSString *sql = [self insertSqlString:model propertyListWithValueDictionary:propertyDict];
    return [self executeUpdate:sql withArguments:[propertyDict allValues]];
}

- (BOOL)insertModel:(id)model withExtraCondition:(NSDictionary *)dict {
    NSDictionary *propertyDict = [model propertyListWithValue:YES];
    NSMutableArray *valuesArray = [[propertyDict allValues] mutableCopy];
    [valuesArray addObjectsFromArray:[dict allValues]];
    NSString *sql = [self insertSqlString:model propertyListWithValueDictionary:propertyDict extraDictionary:dict];
    return [self executeUpdate:sql withArguments:valuesArray];
}

//像表中插入一组数据
- (BOOL)insertModelArray:(NSArray *)array {
    __block BOOL retValue;
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (id model in array) {
            NSDictionary *propertyDict = [model propertyListWithValue:YES];
            NSString *sql = [self insertSqlString:model propertyListWithValueDictionary:propertyDict];
            retValue = [db executeUpdate:sql withArgumentsInArray:[propertyDict allValues]];
            if (!retValue) {
                [self logWithName:@"insert data error" description:db.lastError.localizedDescription];
                *rollback = YES;
                break;
            }
        }
    }];
    return retValue;
}

//查询表中所有记录
- (NSArray *)selectAllRecord:(Class)aClass {
    NSMutableArray *resultArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from %@",NSStringFromClass(aClass)];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            id model = [[aClass alloc] init];
            NSDictionary *dict = [rs resultDictionary];
            [model setValuesForKeysWithDictionary:dict];
            [resultArray addObject:model];
        }
        [rs close];
    }];
    return resultArray;
}

/*
 *  dict键值对为(表字段名，查询的值)
 */
- (NSArray *)selectRecordWithClass:(Class)aClass withCondition:(NSDictionary *)dict {
    NSString *sql = @"select * from %@ ";
    NSMutableString *conditionSql = [NSMutableString string];
    NSMutableArray *conditionValueArray = [NSMutableArray array];
    
    if (dict && dict.allKeys.count) {
        [conditionSql appendString:@"where "];
        NSArray *conditionKeyArray = [dict allKeys];
        NSInteger count = conditionKeyArray.count;
        for (NSInteger i = 0; i < count; ++i) {
            NSString *key = [conditionKeyArray objectAtIndex:i];
            if (i != count - 1) {
                [conditionSql appendFormat:@"%@=? and ",key];
            } else {
                [conditionSql appendFormat:@"%@=?",key];
            }
            [conditionValueArray addObject:[dict objectForKey:key]];
        }
    }
    sql = [sql stringByAppendingString:conditionSql];
    sql = [NSString stringWithFormat:sql,NSStringFromClass(aClass)];
    return [self executeQuery:sql withArguments:conditionValueArray elementClass:aClass];
}

- (NSArray *)selectRecordWithClass:(Class)aClass
                     withCondition:(NSDictionary *)dict
                           orderBy:(NSString *)columnName
                       orderOption:(BOOL)desc
{
    NSString *sql = @"select * from %@ ";
    NSString *orderSql = @"order by %@ %@";
    NSString *orderOption = desc ? @"desc " : @"asc " ;
    NSMutableString *conditionSql = [NSMutableString string];
    NSMutableArray *conditionValueArray = [NSMutableArray array];
    
    if (dict && dict.allKeys.count) {
        [conditionSql appendString:@"where "];
        NSArray *conditionKeyArray = [dict allKeys];
        NSInteger count = conditionKeyArray.count;
        for (NSInteger i = 0; i < count; ++i) {
            NSString *key = [conditionKeyArray objectAtIndex:i];
            if (i != count - 1) {
                [conditionSql appendFormat:@"%@=? and ",key];
            } else {
                [conditionSql appendFormat:@"%@=? ",key];
            }
            [conditionValueArray addObject:[dict objectForKey:key]];
        }
    }
    sql = [sql stringByAppendingString:conditionSql];
    sql = [sql stringByAppendingString:orderSql];
    sql = [NSString stringWithFormat:sql,NSStringFromClass(aClass),columnName,orderOption];
    return [self executeQuery:sql withArguments:conditionValueArray elementClass:aClass];
}

- (BOOL)dropTableWithClass:(Class)aClass {
    NSString *sql = [NSString stringWithFormat:@"drop table %@",NSStringFromClass(aClass)];
    __block BOOL retValue;
    [_queue inDatabase:^(FMDatabase *db) {
        retValue = [db executeUpdate:sql];
        if (!retValue) {
            [self logWithName:@"delete table error" description:db.lastError.localizedDescription];
        }
    }];
    return retValue;
}

- (BOOL)updateTableWithClass:(Class)aClass
                     setDict:(NSDictionary *)dict
               withCondition:(NSDictionary *)conditionDict
{
    NSString *sql = @"update %@ set %@ where %@";
    NSString *setSql = [self dictionary2StrigWithComma:dict];
    NSString *conditionSql = [self dictionary2StrigWithComma:conditionDict];
    sql = [NSString stringWithFormat:sql,NSStringFromClass(aClass),setSql,conditionSql];
    __block BOOL retValue;
    [_queue inDatabase:^(FMDatabase *db) {
        retValue = [db executeUpdate:sql];
        if (!retValue) {
            [self logWithName:@"update table error" description:db.lastError.localizedDescription];
        }
    }];
    return retValue;
}

- (BOOL)updateTableWithModel:(id)model condition:(NSDictionary *)conditionDict {
    NSDictionary *setDict = [model propertyListWithValue:YES];
    return [self updateTableWithClass:[model class] setDict:setDict withCondition:conditionDict];
}

- (BOOL)deleteAllRecord:(Class)aClass {
    NSString *sql = [NSString stringWithFormat:@"delete from %@",NSStringFromClass(aClass)];
    __block BOOL retValue;
    [_queue inDatabase:^(FMDatabase *db) {
        retValue = [db executeUpdate:sql];
        if (retValue) {
            [self logWithName:@"clear table record error" description:db.lastError.localizedDescription];
        }
    }];
    return retValue;
}

- (BOOL)deleteRecordFromTable:(Class)aClass condition:(NSDictionary *)conditionDict {
    NSString *sql = @"delete from %@ where %@";
    NSString *conditionSql = [self dictionary2StringWithAnd:conditionDict];
    sql = [NSString stringWithFormat:sql,NSStringFromClass(aClass),conditionSql];
    __block BOOL retValue;
    [_queue inDatabase:^(FMDatabase *db) {
        retValue = [db executeUpdate:sql];
        if (!retValue) {
            [self logWithName:@"delete table error" description:db.lastError.localizedDescription];
        }
    }];
    return retValue;
}

/*  给aClass对应的表添加约束，约束让表中一直存在count条记录，根据columnName排序
 *  @param orderOption  YES时，根据columnName降序排列；NO时，根据columnName升序排列。
 */
- (BOOL)addKeepNewTriggerToTable:(Class)aClass
                           count:(NSInteger)count
                       orderedBy:(NSString *)columnName
                  orderedDescend:(BOOL)orderOption
{
    NSString *tableName = NSStringFromClass(aClass);
    NSString *order = orderOption ? @"desc" : @"asc";
    NSString *sql = [NSString stringWithFormat:@"create trigger keepNew after insert on %@ \
                     begin \
                     delete from %@ where %@ not in (select %@ from %@ order by %@ %@ limit 0,%@); \
                     end",tableName ,tableName,columnName,columnName,tableName,columnName,order, [NSString stringWithFormat:@"%ld",(long)count]];
    __block BOOL retValue;
    [_queue inDatabase:^(FMDatabase *db) {
        retValue = [db executeUpdate:sql];
        if (!retValue) {
            [self logWithName:@"add trigger error" description:db.lastError.localizedDescription];
        }
    }];
    return retValue;
}

- (BOOL)executeUpdate:(NSString *)sql withArguments:(NSArray *)arguments {
    __block BOOL retValue;
    [self.queue inDatabase:^(FMDatabase *db) {
        retValue = [db executeUpdate:sql withArgumentsInArray:arguments];
        if (!retValue) {
            [self logWithName:@"executeUpdate error" description:db.lastError.localizedDescription];
        }
    }];
    return retValue;
}

- (NSArray *)executeQuery:(NSString *)sql withArguments:(NSArray *)args {
    NSMutableArray *resultArray = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:args];
        while ([rs next]) {
            NSDictionary *dict = [rs resultDictionary];
            [resultArray addObject:dict];
        }
        [rs close];
    }];
    return resultArray;
}

- (NSArray *)executeQuery:(NSString *)sql withArguments:(NSArray *)arguments elementClass:(Class)aClass {
    NSMutableArray *resultArray = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:arguments];
        while ([rs next]) {
            id model = [[aClass alloc] init];
            NSDictionary *resultDict = [rs resultDictionary];
            [model setValuesForKeysWithDictionary:resultDict];
            [resultArray addObject:model];
        }
        [rs close];
    }];
    return resultArray;
}

- (BOOL)isTableExist:(NSString *)tableName {
    NSString *sql = @"SELECT name FROM sqlite_master WHERE type='table' AND name=%@";
    __block BOOL result = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql,tableName];
        if ([rs next]) {
            result = YES;
        }
    }];
    return result;
}

#pragma mark - Inner Method
- (NSString *)sqlStringFromClass:(id)model {
    return [self sqlStringFromClass:model otherColumnNames:nil];
}

//- (NSString *)sqlStringFromClass:(id)model otherColumnNames:(NSArray *)namesArray
//{
//    NSDictionary *propertyDict = [model propertyListWithValue:NO];
//    NSArray *propertyNameArray = [propertyDict allKeys];
//    NSMutableArray *tmpArr = [propertyNameArray mutableCopy];
//    if (namesArray != nil && namesArray.count) {
//        [tmpArr addObjectsFromArray:namesArray];
//    }
//    
//    NSString *sql = [tmpArr componentsJoinedByString:@" text,"];
//    sql = [sql stringByAppendingString:@" text"];
//    return sql;
//}

- (NSString *)sqlStringFromClass:(id)model otherColumnNames:(NSArray *)namesArray {
    NSDictionary *propertyDict = [model propertyListWithType];
    NSArray *propertyNameArray = [propertyDict allKeys];
    NSMutableArray *tmpArr = [propertyNameArray mutableCopy];
    if (namesArray != nil && namesArray.count) {
        [tmpArr addObjectsFromArray:namesArray];
    }
    
    NSMutableString *str = [NSMutableString string];
    for (NSInteger index = 0; index < tmpArr.count; index++) {
        NSString *key = tmpArr[index];
        [str appendString:key];
        if ([propertyNameArray containsObject:key]) {
            //key是模型中的字段
            NSString *type = propertyDict[key]; //原始类型
            NSString *affinityType = [self affinityType:type];
            [str appendString:[NSString stringWithFormat:@" %@",affinityType]];
        } else {
            //key是额外指定的字段
            [str appendString:@" text"];
        }
        
        if (index != tmpArr.count - 1) {
            //不是数组中的最后一个元素
            [str appendString:@","];
        }
    }
    
    return str;
}

- (NSString *)dictionary2StrigWithComma:(NSDictionary *)dict {
    return [self dictionary2StringWithSeparatorString:@"," dict:dict];
}

- (NSString *)dictionary2StringWithAnd:(NSDictionary *)dict {
    return [self dictionary2StringWithSeparatorString:@" and " dict:dict];
}

- (NSString *)dictionary2StringWithSeparatorString:(NSString *)separator dict:(NSDictionary *)dict {
    NSMutableArray *setArray = [NSMutableArray array];
    NSArray *setKeyArray = [dict allKeys];
    for (NSInteger i = 0; i < setKeyArray.count; ++i) {
        NSString *key = setKeyArray[i];
        NSString *setStr = [NSString stringWithFormat:@"%@='%@'",key,[dict objectForKey:key]];
        [setArray addObject:setStr];
    }
    return [setArray componentsJoinedByString:separator];
}

//生成这样的语句:  insert into tablename(column1,column2,column3) values(?,?,?)
- (NSString *)insertSqlString:(id)model propertyListWithValueDictionary:(NSDictionary *)propertyDict {
    NSString *sql = @"insert into %@(%@) values(%@)";
    NSArray *propertyNameArray = [propertyDict allKeys];
    NSMutableString *valueStr = [NSMutableString string];
    NSMutableString *columnNameStr = [NSMutableString string];
    
    for (NSInteger i = 0; i < propertyNameArray.count; ++i) {
        NSString *tmpStr = [propertyNameArray objectAtIndex:i];
        [columnNameStr appendString:tmpStr];
        if (i != propertyNameArray.count - 1) {
            [valueStr appendString:@"?,"];
            [columnNameStr appendString:@","];
        } else {
            [valueStr appendString:@"?"];
        }
    }
    return  [NSString stringWithFormat:sql,NSStringFromClass([model class]),columnNameStr,valueStr];
}

/*  生成insert语句：insert into tablename(column1,column2,column3) values(?,?,?)
 *  @param  model 要插入的数据模型
 *  @param  propertyDict model的属性列表字典，键值对内容是(属性名，属性值）
 *  @param  表中存在，但model的属性不存在的字段，通过extraDictionary来指定 (字段名，值)
 */
- (NSString *)insertSqlString:(id)model
propertyListWithValueDictionary:(NSDictionary *)propertyDict
              extraDictionary:(NSDictionary *)extraDictionary
{
    NSString *sql = @"insert into %@(%@) values(%@)";
    NSArray *propertyNameArray = [propertyDict allKeys];
    NSArray *extraPropertyNameArray = [extraDictionary allKeys];
    
    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:propertyNameArray];
    [nameArray addObjectsFromArray:extraPropertyNameArray];
    NSMutableString *valueStr = [NSMutableString string];
    NSMutableString *columnNameStr = [NSMutableString string];
    
    for (NSInteger i = 0; i < nameArray.count; ++i) {
        NSString *tmpStr = [nameArray objectAtIndex:i];
        [columnNameStr appendString:tmpStr];
        if (i != nameArray.count - 1) {
            [valueStr appendString:@"?,"];
            [columnNameStr appendString:@","];
        } else {
            [valueStr appendString:@"?"];
        }
    }
    return  [NSString stringWithFormat:sql,NSStringFromClass([model class]),columnNameStr,valueStr];
}

/**
 *  打印错误信息
 */
- (void)logWithName:(NSString *)name description:(NSString *)description {
    if (_isDebugModeEnabled) {
        NSLog(@"%@:%@",name,description);
    }
}

@end

//
//  Created by xjshi on 15/7/23.
//  Copyright (c) 2015年 xjshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "NSObject+SXJ.h"

@interface SXJDatabaseManager : NSObject

+ (SXJDatabaseManager *)sharedManager;

@property (nonatomic,strong,readonly) FMDatabaseQueue *queue;

@property (nonatomic,assign) BOOL isDebugModeEnabled;

/**
 *  根据aClass创建表
 *  
 *  @return 表创建成功返回YES，否则返回NO。
 */
- (BOOL)createTable:(Class)aClass;

/**
 *  根据aClass创建表
 *
 *  @param array  数组元素应该为NSString类型，array中的所有元素作为主键
 */
- (BOOL)createTableWithClass:(Class)aClass primaryKeyNameArray:(NSArray *)array;

/**
 *  根据aClass创建表
 *
 *  @param names  如果要创建的表要包含除了aClass包含的其他属性，就放在names中
 *  @param array  主键数组
 */
- (BOOL)createTableWithClass:(Class)aClass otherColumnNames:(NSArray *)names primaryKeyNameArray:(NSArray *)array;

/**
 *  插入一条记录
 *
 *  @param model 要插入的数据模型
 *
 *  @return 插入成功，则返回YES；否则，返回NO。
 */
- (BOOL)insertModel:(id)model;
/**
 *  插入一组数据
 *
 *  @return 插入成功，则返回YES；否则，返回NO。
 *  @note   如果array中包含表中已经存在的数据（主键冲突等），会导致array中的数据全部插入失败。
 */
- (BOOL)insertModelArray:(NSArray *)array;

/**
 *  插入一条记录
 *
 *  @param model 要插入的数据模型
 *  @param dict  除数据模型类包含的属性外，需要插入额外的字段数据。
 */
- (BOOL)insertModel:(id)model withExtraCondition:(NSDictionary *)dict;

/**
 *  查询一个表中所有的数据
 *
 *  @param aClass 与要查询的表对应的数据模型
 *
 *  @return 返回查询到数据，其类型为aClass
 */
- (NSArray *)selectAllRecord:(Class)aClass;

/**
 *  查询符合条件的数据
 *
 *  @param dict   查询条件，目前仅支持相等条件的查询
 */
- (NSArray *)selectRecordWithClass:(Class)aClass withCondition:(NSDictionary *)dict;

/**
 *  查询符合条件的数据
 *
 *  @param columnName 排序依据的字段
 *  @param desc       YES：降序排列；NO：升序排列
 */
- (NSArray *)selectRecordWithClass:(Class)aClass withCondition:(NSDictionary *)dict orderBy:(NSString *)columnName orderOption:(BOOL)desc;

/**
 *  删除表
 */
- (BOOL)dropTableWithClass:(Class)aClass;

/**
 *  更新表中记录
 *
 *  @param dict          更新数据
 *  @param conditionDict 要更新的记录需要符合的条件
 */
- (BOOL)updateTableWithClass:(Class)aClass setDict:(NSDictionary *)dict withCondition:(NSDictionary *)conditionDict;

/**
 *  根据model来更新表
 */
- (BOOL)updateTableWithModel:(id)model condition:(NSDictionary *)conditionDict;

/**
 *  清空表里所有记录
 */
- (BOOL)deleteAllRecord:(Class)aClass;

/**
 *  删除表中符合条件的记录
 */
- (BOOL)deleteRecordFromTable:(Class)aClass condition:(NSDictionary *)conditionDict;

/**
 *  给指定的表添加只保存最新count条记录的触发器
 *
 *  @param orderOption YES：降序；NO：升序。
 */
- (BOOL)addKeepNewTriggerToTable:(Class)aClass count:(NSInteger)count orderedBy:(NSString *)columnName orderedDescend:(BOOL)orderOption;

/**
 *  执行update操作
 */
- (BOOL)executeUpdate:(NSString *)sql withArguments:(NSArray *)arguments;

/**
 *  执行query操作
 *
 *  @return 查询结果转化为字典，存放在数组中
 */
- (NSArray *)executeQuery:(NSString *)sql withArguments:(NSArray *)args;

/**
 *  判断表是否存在
 *
 *  @param tableName 表明
 */
- (BOOL)isTableExist:(NSString *)tableName;

- (NSString *)sqlStringFromClass:(id)model otherColumnNames:(NSArray *)namesArray;
- (NSString *)insertSqlString:(id)model propertyListWithValueDictionary:(NSDictionary *)propertyDict;

@end

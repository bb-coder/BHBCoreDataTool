//
//  BHBCoreDataTool.h
//  BHBCoreDataTool
//
//  Created by 毕洪博 on 14-12-12.
//  Copyright (c) 2014年 毕洪博. All rights reserved.
//
/**
 
 本工具是基于coredata的数据库访问工具，主要功能是执行增删改差操作
 使用本工具的步骤：
 1.创建coredata数据库，建立实体和关系（此处为coredata可视化操作的基本知识，不会的可以百度）。
 2.将本工具导入到工程中。
 3.设置数据库名和数据库保存类型两个宏，注意数据库名要与创建的momd文件名一致
 4.执行增删改差操作，可以直接给实体名字和约束进行查询，修改和新增需要跟上一个属性字典
 
 例如：类A有2个属性name（string类型）sex(nsnumber类型),
则传dict = @{@"name":@"xxx",@"sex":,@1}
 
 仅供大家的学习和使用，如果因为使用本工具造成的一切后果与本人无关，欢迎与我交流
 qq:403154749
 github:https://github.com/bb-coder
 blog:http://www.cnblogs.com/q403154749/
 
 */

#import <Foundation/Foundation.h>

#define KDBNAME @"MotionModel"//数据库名
#define KDBTYPE @"sqlite"//数据库类型

@interface BHBCoreDataTool : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

singletonInterface(BHBCoreDataTool)

/**
 *  新增
 *
 *  @param entityName 实体名
 *  @param dict       属性字典，实体属性名对应key，值对应value
 *
 *  @return 新增是否成功，yes为成功，no为失败
 */
- (BOOL)addWithEntity:(NSString *)entityName withDict:(NSDictionary *)dict;

/**
 *  查询
 *
 *  @param entityName 实体名
 *  @param predicate  约束
 *
 *  @return 查询结果
 */
- (NSArray *)selectWithEntity:(NSString *)entityName Predicate:(NSString *)predicate;

/**
 *  删除
 *
 *  @param entityName 实体名
 *  @param predicate  查询约束，如果为nil，删除所有记录
 *
 *  @return 删除是否成功，yes成功，no不成功
 */
- (BOOL)deleteWithEntity:(NSString *)entityName Predicate:(NSString *)predicate;

/**
 *  更新
 *
 *  @param entityName 实体名
 *  @param predicate  查询约束，如果为nil，为修改全部
 *
 *  @return 修改是否成功
 */
- (BOOL)updateWithEntity:(NSString *)entityName Predicate:(NSString *)predicate withDict:(NSDictionary *) dict;
@end
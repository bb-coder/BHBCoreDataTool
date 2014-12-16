//
//  BHBCoreDataTool.h
//  BHBCoreDataTool
//
//  Created by 毕洪博 on 14-12-12.
//  Copyright (c) 2014年 毕洪博. All rights reserved.
//

#import "BHBCoreDataTool.h"

#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@implementation BHBCoreDataTool

singletonImplementation(BHBCoreDataTool)

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark - 增删改查
/**
 *  查询
 *
 *  @param entityName 实体名
 *  @param predicate  约束
 *
 *  @return 查询结果
 */
- (NSArray *)selectWithEntity:(NSString *)entityName Predicate:(NSString *)predicate
{
    if(!entityName || [entityName isEqualToString:@""])
        assert("实体名字不能为空！");
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if(predicate)
        request.predicate = [NSPredicate predicateWithFormat:predicate];
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
        return array;
}

/**
 *  新增
 *
 *  @param entityName 实体名
 *  @param dict       属性字典，实体属性名对应key，值对应value
 *
 *  @return 新增是否成功，yes为成功，no为失败
 */
- (BOOL)addWithEntity:(NSString *)entityName withDict:(NSDictionary *)dict
{
    if(!entityName || [entityName isEqualToString:@""])
        assert("实体名字不能为空！");
    
        NSManagedObject * p = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [self setPropertyListWithClassString:entityName andDict:dict andObj:p];
    if ([self.managedObjectContext save:nil])
        return YES;
        return NO;
}

/**
 *  删除
 *
 *  @param entityName 实体名
 *  @param predicate  查询约束，如果为nil，删除所有记录
 *
 *  @return 删除是否成功，yes成功，no不成功
 */
- (BOOL)deleteWithEntity:(NSString *)entityName Predicate:(NSString *)predicate
{
    NSArray *result = [self selectWithEntity:entityName Predicate:predicate];
    for (id obj in result) {
        [_managedObjectContext deleteObject:obj];
    }
    if ([_managedObjectContext save:nil])
        return YES;
        return NO;
}

/**
 *  更新
 *
 *  @param entityName 实体名
 *  @param predicate  查询约束，如果为nil，为修改全部
 *
 *  @return 修改是否成功
 */
- (BOOL)updateWithEntity:(NSString *)entityName Predicate:(NSString *)predicate withDict:(NSDictionary *) dict
{
    return [self updateWithEntity:entityName Predicate:predicate withDict:dict withBlock:nil];
}

/**
 *  自定义操作的更新
 *
 *  @param entityName 实体名
 *  @param predicate  约束
 *  @param dict       属性字典
 *  @param enumblock  自定义操作，操作完毕后将会自动保存
 *
 *  @return 是否修改成功
 */
- (BOOL)updateWithEntity:(NSString *)entityName Predicate:(NSString *)predicate withDict:(NSDictionary *) dict withBlock:(ENUMBLOCK)enumblock
{
    NSArray *result = [self selectWithEntity:entityName Predicate:predicate];
    for (id obj in result) {
        if (enumblock) {
            enumblock(obj,result);
        }
        [self setPropertyListWithClassString:entityName andDict:dict andObj:obj];
    }
    if( [_managedObjectContext save:nil])
        return YES;
    return NO;
}

#pragma mark 设置属性

- (void) setPropertyListWithClassString:(NSString *) className andDict:(NSDictionary *)dict andObj:(id) obj
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        assert("你传的这个不是字典！");
        return;
    }
    u_int count;
    objc_property_t * property = class_copyPropertyList(NSClassFromString(className), &count);
    for(int i = 0; i < count; i++)
    {
        const char * propertyName = property_getName(property[i]);
        NSString * strName = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        if(dict[strName])
            [obj setValue:dict[strName] forKey:strName];
    }

}

#pragma mark - Core Data 栈

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:KDBNAME withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",KDBNAME,KDBTYPE]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    NSURL *url=[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    return url;
}


@end

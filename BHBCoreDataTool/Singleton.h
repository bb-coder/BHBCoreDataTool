//
//  BHBCoreDataTool.h
//  BHBCoreDataTool
//
//  Created by 毕洪博 on 14-12-12.
//  Copyright (c) 2014年 毕洪博. All rights reserved.
//
//单例宏

//@interface
#define singletonInterface(className)\
+(className *) share##className;

//@implementation
#define singletonImplementation(className) \
static className * _instance;\
+(id)allocWithZone:(struct _NSZone *)zone\
{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [super allocWithZone:zone];\
});\
return _instance;\
}\
+(className *)share##className\
{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [[self alloc]init];\
});\
return _instance;\
}

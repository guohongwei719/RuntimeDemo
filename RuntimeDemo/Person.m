//
//  Person.m
//  RuntimeDemo
//
//  Created by 郭宏伟 on 2017/7/5.
//  Copyright © 2017年 郭宏伟. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>
@interface Person ()

@property (nonatomic, copy) NSString *name;

@end

@implementation Person {
    NSString *instanceName;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"Tom";
        instanceName = @"Jim";
        _age = 12;
    }
    return self;
}

// 需要归档哪些属性！ 常规方法
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:_name forKey:@"name"];
//    [aCoder encodeInt:_age forKey:@"age"];
//}
// 解档
//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self) {
//        _name = [aDecoder decodeObjectForKey:@"name"];
//        _age = [aDecoder decodeIntForKey:@"age"];
//    }
//    return self;
//}

// 使用runtime来归档、解档
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([Person class], &count);
    for (int i = 0; i < count; i++) {
        // 拿到每个成员变量
        Ivar ivar = ivars[i];
        // 拿名称
        const char *name = ivar_getName(ivar);
        NSString *key = [NSString stringWithUTF8String:name];
        
        // 归档 -- 利用KVC
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([Person class], &count);
        for (int i = 0; i < count; i++) {
            // 拿到每一个成员变量
            Ivar ivar = ivars[i];
            // 拿名称
            const char * name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            
            // 解档
            id value = [aDecoder decodeObjectForKey:key];
            // 利用KVC设置值
            [self setValue:value forKey:key];
        }
    }
    return self;
}




- (void)func1
{
    NSLog(@"执行了func1方法");
}

- (void)func2
{
    NSLog(@"执行了func2方法");
}

// 测试消息转发
- (void)sayHello1:(NSString *)name
{
    NSLog(@"Hello, I am a person");
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"name:%@ age:%d", self.name, self.age];
}

@end

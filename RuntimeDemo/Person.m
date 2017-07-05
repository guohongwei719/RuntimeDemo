//
//  Person.m
//  RuntimeDemo
//
//  Created by 郭宏伟 on 2017/7/5.
//  Copyright © 2017年 郭宏伟. All rights reserved.
//

#import "Person.h"

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

- (void)func1
{
    NSLog(@"执行了func1方法");
}

- (void)func2
{
    NSLog(@"执行了func2方法");
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name:%@ age:%d", self.name, self.age];
}

@end

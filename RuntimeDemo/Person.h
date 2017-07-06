//
//  Person.h
//  RuntimeDemo
//
//  Created by 郭宏伟 on 2017/7/5.
//  Copyright © 2017年 郭宏伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject <NSCoding>

@property (nonatomic, assign) int age; // 属性变量

- (void)func1;
- (void)func2;

- (void)sayHello1:(NSString *)name;

@end

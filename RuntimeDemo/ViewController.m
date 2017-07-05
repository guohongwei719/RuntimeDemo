//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 郭宏伟 on 2017/7/5.
//  Copyright © 2017年 郭宏伟. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Person+PersonCategory.h"
#import <objc/runtime.h>

@interface ViewController ()

@property (nonatomic, strong) Person *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [[Person alloc] init];
}


// 获取person所有的成员变量
- (IBAction)getAllVariable:(id)sender
{
    unsigned int count = 0;
    // 获取类的一个包含所有变量的列表，Ivar是runtime声明的一个宏，是实例变量的意思
    Ivar *allVariables = class_copyIvarList([Person class], &count);
    
    for (int i  = 0; i < count; i++) {
        // 遍历每一个变量，包括名称和类型 （此处没有星号"*"），
        Ivar ivar = allVariables[i];
        const char *variablename = ivar_getName(ivar); // 获取成员变量名称
        const char *variableType = ivar_getTypeEncoding(ivar); // 获取成员变量类型
        NSLog(@"(Name: %s)----(Type:%s)", variablename, variableType);
        
        /*
         2017-07-05 13:07:00.735 RuntimeDemo[3353:127039] (Name: instanceName)----(Type:@"NSString")
         2017-07-05 13:07:00.735 RuntimeDemo[3353:127039] (Name: _age)----(Type:i)
         2017-07-05 13:07:00.736 RuntimeDemo[3353:127039] (Name: _name)----(Type:@"NSString")
         
         Ivar，一个指向objc_ivar结构体指针，包含了变量名、变量类型等信息。可以看到私有属性_name instanceName都能够访问到了。在有些项目中，为了对某些私有属性进行隐藏，某些.h文件中没有出现相应的显式创建，而是如上面的person类中，在.m中进行私有创建，但是我们可以通过runtime这个有效的方法，访问到所有包括这些隐藏的私有变量。
         */
    }
    
    NSLog(@"测试一下class_copyPropertyList的区别");
    
    objc_property_t *allProperties = class_copyPropertyList([Person class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = allProperties[i];
        const char *char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        NSLog(@"property = %@", propertyName);
    }
    /*
    2017-07-05 11:55:16.961 RuntimeDemo[3187:98751] property = name
    2017-07-05 11:55:16.961 RuntimeDemo[3187:98751] property = age
     
     如果单单需要获取属性列表，可以使用函数:class_copyPropertyList()，instanceName作为实例变量是不被获取的，而class_copyIvarList()函数则能够返回实例变量和属性变量的所有成员变量。
    */
    
    free(allVariables);
    free(allProperties);
    
}

// 获取person所有方法
- (IBAction)getAllMethod:(id)sender
{
    unsigned int count;
    // 获取方法列表，所有在.m文件显式实现的方法都会被找到，包括setter+getter方法；
    Method *allMethods = class_copyMethodList([Person class], &count);
    for (int i = 0; i < count; i++) {
        // Method,为runtime声明的一个宏，表示对一个方法的描述
        Method md = allMethods[i];
        // 获取SEL：SEL类型，即获取方法选择器@selector()
        SEL sel = method_getName(md);
        // 得到sel的方法名：以字符串格式获取sel的name，也即@selector()中的方法名称
        const char *methodname = sel_getName(sel);
        NSLog(@"(Method:%s)", methodname);
    }
}

/*
 控制台输出：
 2017-07-05 13:17:13.380 RuntimeDemo[3392:134673] (Method:age)
 2017-07-05 13:17:13.381 RuntimeDemo[3392:134673] (Method:func1)
 2017-07-05 13:17:13.386 RuntimeDemo[3392:134673] (Method:func2)
 2017-07-05 13:17:13.386 RuntimeDemo[3392:134673] (Method:setAge:)
 2017-07-05 13:17:13.386 RuntimeDemo[3392:134673] (Method:.cxx_destruct)
 2017-07-05 13:17:13.386 RuntimeDemo[3392:134673] (Method:description)
 2017-07-05 13:17:13.386 RuntimeDemo[3392:134673] (Method:name)
 2017-07-05 13:17:13.386 RuntimeDemo[3392:134673] (Method:setName:)
 2017-07-05 13:17:13.387 RuntimeDemo[3392:134673] (Method:init)
 
 
 控制台输出了包括set和get等方法名。
 分析：Method是一个指向objc_method结构体指针，表示对类中的某个方法的描述。
 在api中的定义typedef struct objc_method *Method;
而objc_method结构体如下：
 struct objc_method {
 SEL method_name                                          OBJC2_UNAVAILABLE;
 char *method_types                                       OBJC2_UNAVAILABLE;
 IMP method_imp                                           OBJC2_UNAVAILABLE;
 }
method_name:方法选择器@selector()，类型为SEL。相同名字的方法下，即使在不同类中定义，它们的方法选择器也相同。
 method_types：方法类型，是个char指针，存储着方法的参数类型和返回值类型。
 method_imp: 指向方法的具体实现的指针，数据类型为IMP，本质上是一个函数指针。
 
 SEL:数据类型，表示方法选择器，可以理解为对方法的一种包装。在每个方法都有一个与之对应的SEL类型的数据，根据一个SEL数据"@selector(方法名)"就可以找到对应的方法地址，进而调用方法。
 因此可以通过：获取Method结构体->得到SEL选择器的名称->得到对应的方法名，这样的方式认识OC中关于方法的定义。
 
 
 */



// 3.改变person的_name变量属性
- (IBAction)changeVariable:(id)sender {
    NSLog(@"改变前的person：%@", self.person);
    unsigned int count = 0;
    Ivar *allList = class_copyIvarList([Person class], &count);
    Ivar ivv = allList[2];
    object_setIvar(self.person, ivv, @"Mike"); // name属性Tom被强制改为Mike。
    NSLog(@"改变之后的person: %@", self.person);
}

- (IBAction)addVariable:(id)sender {
    self.person.height = 12;    // 给新属性height赋值
    NSLog(@"%f", [self.person height]); // 访问新属性
    
}

/*
 点击按钮四、再点击按钮一、二获取类的属性、方法
 2017-07-05 14:14:23.648 RuntimeDemo[3640:165606] 12.000000
 2017-07-05 14:14:28.026 RuntimeDemo[3640:165606] (Name: instanceName)----(Type:@"NSString")
 2017-07-05 14:14:28.026 RuntimeDemo[3640:165606] (Name: _age)----(Type:i)
 2017-07-05 14:14:28.026 RuntimeDemo[3640:165606] (Name: _name)----(Type:@"NSString")
 2017-07-05 14:14:28.027 RuntimeDemo[3640:165606] 测试一下class_copyPropertyList的区别
 2017-07-05 14:14:28.027 RuntimeDemo[3640:165606] property = height
 2017-07-05 14:14:28.027 RuntimeDemo[3640:165606] property = name
 2017-07-05 14:14:28.027 RuntimeDemo[3640:165606] property = age
 2017-07-05 14:14:28.886 RuntimeDemo[3640:165606] (Method:age)
 2017-07-05 14:14:28.886 RuntimeDemo[3640:165606] (Method:func1)
 2017-07-05 14:14:28.886 RuntimeDemo[3640:165606] (Method:func2)
 2017-07-05 14:14:28.887 RuntimeDemo[3640:165606] (Method:setAge:)
 2017-07-05 14:14:28.887 RuntimeDemo[3640:165606] (Method:.cxx_destruct)
 2017-07-05 14:14:28.887 RuntimeDemo[3640:165606] (Method:description)
 2017-07-05 14:14:28.887 RuntimeDemo[3640:165606] (Method:name)
 2017-07-05 14:14:28.887 RuntimeDemo[3640:165606] (Method:setName:)
 2017-07-05 14:14:28.888 RuntimeDemo[3640:165606] (Method:init)
 2017-07-05 14:14:28.888 RuntimeDemo[3640:165606] (Method:height)
 2017-07-05 14:14:28.888 RuntimeDemo[3640:165606] (Method:setHeight:)
 
 
 可以看到分类的新属性可以在person对象中对新属性height进行访问赋值。
 获取person类属性时，依然没有height的存在，但是却有height和setHeight这两个方法；因为在分类中，即使使用@property定义了，也只是生产set+get方法，而不会生成_变量名，分类中是不允许定义变量的。
 使用runtime中objc_setAssociatedObject()和objc_getAssociatedObject()方法，本质上只是为对象person添加了对height的属性关联，但是达到了新属性的作用；
 使用场景：假设imageCategory是UIImage类的分类，在实际开发中，我们使用UIImage下载图片或者操作过程需要增加一个URL保存一段地址，以备后期使用。这时可以尝试在分类中动态添加新属性MyURL进行存储。
 
 */


// 5.添加新的方法试试（这种方法等价于对person类添加Category对方法进行扩展）
- (IBAction)addMethod:(id)sender {
    /* 动态添加方法：
     第一个参数表示 Class cls 类型；
     第二个参数表示待调用的方法名称；
     第三个参数 (IMP)myAddingFunction，IMP一个函数指针，这里表示指定具体实现方法myAddingFunction;
     第四个参数表示方法的参数，0代表没有参数；
     
     */
    class_addMethod([Person class], @selector(NewMethod), (IMP)myAddingFunction, 0);
    [self.person performSelector:@selector(NewMethod)];
}

// 具体的实现（方法的内部都默认包含两个参数Class和SEL方法，被称为隐式参数。）
int myAddingFunction(id self, SEL _cmd) {
    NSLog(@"已新增方法：NewMethod");
    return 1;
}


// 6.交换两种方法之后（功能对调）
- (IBAction)replaceMethod:(id)sender {
    Method method1 = class_getInstanceMethod([self.person class], @selector(func1));
    Method method2 = class_getInstanceMethod([self.person class], @selector(func2));
    
    // 交换方法
    method_exchangeImplementations(method1, method2);
    [self.person func1];
}

/*
 交换方法的使用场景：项目中的某个功能，在项目中需要多次被引用，当项目的需求发生改变时，要使用另一种功能代替这个功能，且要求不改变旧的项目，也就是不改变原来方法实现的前提下。那么，我们可以在分类中，再写一个新的方法，符合新的需求的方法，然后交换两个方法的实现。这样，在不改变项目的代码，而只是增加了新的代码的情况下，就完成了项目的改进，很好地体现了该项目的封装性与利用率。
 注：交换两个方法的实现一般写在类的load方法里面，因为load方法会在程序运行前家在一次。
 
 */







@end




































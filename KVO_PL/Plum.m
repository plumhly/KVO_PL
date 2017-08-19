//
//  Plum.m
//  KVO_PL
//
//  Created by Plum on 2017/8/19.
//  Copyright © 2017年 Plum. All rights reserved.
//

#import "Plum.h"

/*
 当调用setValue：属性值 forKey：@”name“的代码时，底层的执行机制如下：
 
 程序优先调用set<Key>:属性值方法，代码通过setter方法完成设置。注意，这里的<key>是指成员变量名，首字母大清写要符合KVC的全名规则，下同
 如果没有找到setName：方法，KVC机制会检查+ (BOOL)accessInstanceVariablesDirectly方法有没有返回YES，默认该方法会返回YES，如果你重写了该方法让其返回NO的话，那么在这一步KVC会执行setValue：forUNdefinedKey：方法，不过一般开发者不会这么做。所以KVC机制会搜索该类里面有没有名为_<key>的成员变量，无论该变量是在类接口部分定义，还是在类实现部分定义，也无论用了什么样的访问修饰符，只在存在以_<key>命名的变量，KVC都可以对该成员变量赋值。
 如果该类即没有set<Key>：方法，也没有_<key>成员变量，KVC机制会搜索_is<Key>的成员变量，
 和上面一样，如果该类即没有set<Key>：方法，也没有_<key>和_is<Key>成员变量，KVC机制再会继续搜索<key>和is<Key>的成员变量。再给它们赋值。
 如果上面列出的方法或者成员变量都不存在，系统将会执行该对象的setValue：forUNdefinedKey：方法，默认是抛出异常。

 */

/*
 当调用ValueForKey：@”name“的代码时，KVC对key的搜索方式不同于setValue：属性值 forKey：@”name“，其搜索方式如下
 
 首先按get<Key>,<key>,is<Key>的顺序方法查找getter方法，找到的话会直接调用。如果是BOOL或者int等值类型， 会做NSNumber转换
 如果上面的getter没有找到，KVC则会查找countOf<Key>,objectIn<Key>AtIndex,<Key>AtIndex格式的方法。如果countOf<Key>和另外两个方法中的要个被找到，那么就会返回一个可以响应NSArray所的方法的代理集合(它是NSKeyValueArray，是NSArray的子类)，调用这个代理集合的方法，或者说给这个代理集合发送NSArray的方法，就会以countOf<Key>,objectIn<Key>AtIndex,<Key>AtIndex这几个方法组合的形式调用。还有一个可选的get<Ket>:range:方法。所以你想重新定义KVC的一些功能，你可以添加这些方法，需要注意的是你的方法名要符合KVC的标准命名方法，包括方法签名。
 如果上面的方法没有找到，那么会查找countOf<Key>，enumeratorOf<Key>,memberOf<Key>格式的方法。如果这三个方法都找到，那么就返回一个可以响应NSSet所的方法的代理集合，以送给这个代理集合消息方法，就会以countOf<Key>，enumeratorOf<Key>,memberOf<Key>组合的形式调用。
 如果还没有找到，再检查类方法+ (BOOL)accessInstanceVariablesDirectly,如果返回YES(默认行为)，那么和先前的设值一样，会按_<key>,_is<Key>,<key>,is<Key>的顺序搜索成员变量名，这里不推荐这么做，因为这样直接访问实例变量破坏了封装性，使代码更脆弱。如果重写了类方法+ (BOOL)accessInstanceVariablesDirectly返回NO的话，那么会直接调用valueForUndefinedKey:
 还没有找到的话，调用valueForUndefinedKey:
 
 */

/*
 KVC与容器类
 
 该方法返回一个可变有序数组，如果调用该方法，KVC的搜索顺序如下
 
 搜索insertObject:in<Key>AtIndex: , removeObjectFrom<Key>AtIndex: 或者 insert<Key>AdIndexes , remove<Key>AtIndexes 格式的方法
 如果至少找到一个insert方法和一个remove方法，那么同样返回一个可以响应NSMutableArray所有方法代理集合(类名是NSKeyValueFastMutableArray2)，那么给这个代理集合发送NSMutableArray的方法，以insertObject:in<Key>AtIndex: , removeObjectFrom<Key>AtIndex: 或者 insert<Key>AdIndexes , remove<Key>AtIndexes组合的形式调用。还有两个可选实现的接口：replaceOnjectAtIndex:withObject: , replace<Key>AtIndexes:with<Key>: 。
 如果上步的方法没有找到，则搜索set<Key>: 格式的方法，如果找到，那么发送给代理集合的NSMutableArray最终都会调用set<Key>:方法。 也就是说，mutableArrayValueForKey:取出的代理集合修改后，用·set<Key>:· 重新赋值回去去。这样做效率会低很多。所以推荐实现上面的方法。
 如果上一步的方法还还没有找到，再检查类方法+ (BOOL)accessInstanceVariablesDirectly,如果返回YES(默认行为)，会按_<key>,<key>,的顺序搜索成员变量名，如果找到，那么发送的NSMutableArray消息方法直接交给这个成员变量处理。
 如果还是找不到，调用valueForUndefinedKey:
 关于mutableArrayValueForKey:的适用场景，我在网上找了很多，发现其一般是用在对NSMutableArray添加Observer上。
 如果对象属性是个NSMutableArray、NSMutableSet、NSMutableDictionary等集合类型时，你给它添加KVO时，你会发现当你添加或者移除元素时并不能接收到变化。因为KVO的本质是系统监测到某个属性的内存地址或常量改变时，会添加上- (void)willChangeValueForKey:(NSString *)key
 和- (void)didChangeValueForKey:(NSString *)key方法来发送通知，所以一种解决方法是手动调用者两个方法，但是并不推荐，你永远无法像系统一样真正知道这个元素什么时候被改变。另一种便是利用使用mutableArrayValueForKey:了。

 */

@interface Plum ()

@property (nonatomic, strong) NSMutableArray *names;

@end

@implementation Plum

@dynamic numbers; //根据规则，不能找到get方法
//@dynamic names;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.names = [NSMutableArray array];
    }
    return self;
}

- (void)addName {
    [self.names addObject:@"libo"];
}

- (void)addNameWithKVO {
    [[self mutableArrayValueForKey:@"names"] addObject:@"plum"];
}

- (void)removeName {
    [self.names removeObject:@"libo"];
}

- (void)removeNameWithKVO {
    [[self mutableArrayValueForKey:@"names"] removeObject:@"plum"];
}








static int32_t const primes[] = {
    2, 101, 233, 383, 3, 103, 239, 389, 5, 107
};



- (NSUInteger)countOfNumbers {
    return (sizeof(primes) / sizeof(*primes));
}

/*objectInNumbersAtIndex和numbersAtIndexes 二选一*/
- (id)objectInNumbersAtIndex:(NSUInteger)index {
    return @(primes[index]);
}

- (NSArray *)numbersAtIndexes:(NSIndexSet *)indexes {
    return @[@(primes[indexes.firstIndex])];
}

//实现这个方法后，numbersAtIndexes将不会调用，这个方法有增强性能
- (void)getNumbers:(NSNumber **)buffer range:(NSRange)inRange {
    for (int i = (int)inRange.location; i < inRange.location + inRange.length; i++) {
        *(buffer + i) = @(primes[i]);
    }
    NSLog(@"");
}

//*****************容器类************************/

//(1)优先执行
/*
- (void)insertObject:(NSString *)object inNamesAtIndex:(NSUInteger)index {
    [self.names insertObject:object atIndex:index];
}

- (void)removeObjectFromNamesAtIndex:(NSUInteger)index {
    [self.names removeObjectAtIndex:index];
}
*/

//(2)
- (void)insertNames:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [self.names insertObjects:array atIndexes:indexes];
}

- (void)removeNamesAtIndexes:(NSIndexSet *)indexes {
    [self.names removeObjectsAtIndexes:indexes];
}


//KVV
- (BOOL)validateID:(inout id  _Nullable __autoreleasing *)ioValue  error:(out NSError * _Nullable __autoreleasing *)outError {
    return YES;
}







@end

//
//  ViewController.m
//  KVO_PL
//
//  Created by Plum on 2017/8/19.
//  Copyright © 2017年 Plum. All rights reserved.
//

#import "ViewController.h"
#import "Plum.h"

@interface ViewController ()
@property (nonatomic, strong) Plum *p;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     _p = [[Plum alloc] init];
    _p.ID = @"1223";
    _p.age = 20;
    [_p addObserver:self forKeyPath:@"names" options:NSKeyValueObservingOptionNew context:nil];
    [_p addName];
    [_p addNameWithKVO];
    
    [_p removeName];
    [_p removeNameWithKVO];
    
    
    /*
     dictionaryWithValuesForKeys:是指输入一组key，返回这组key对应的属性，再组成一个字典。
     setValuesForKeysWithDictionary是用来修改Model中对应key的属性。下面直接用代码会更直观一点
     */
    NSDictionary *dic = [_p dictionaryWithValuesForKeys:@[@"ID", @"age"]];
    [_p setValuesForKeysWithDictionary:@{@"ID": @"666", @"age":@(27)}];
    
    /* 
     当对NSDictionary对象使用KVC时，valueForKey:的表现行为和objectForKey:一样。所以使用valueForKeyPath:用来访问多层嵌套的字典是比较方便的
     */
    NSDictionary *diction = @{@"name": @{@"age": @{@"libo": @"plum"}}};
    id value = [diction valueForKeyPath:@"name.age.libo"];
    
    //KVV
    id newID = @"777";
    NSError* error;
    [_p validateValue:&newID forKey:@"ID" error:&error];//将会调用 - (BOOL)validateID:(inout id  _Nullable __autoreleasing *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable __autoreleasing *)outError
    
    NSArray *countries = @[@"libo", @"plum"];
    NSArray *newC = [countries valueForKey:@"capitalizedString"];
    NSLog(@"");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", change);
}

- (void)dealloc {
    [_p removeObserver:self forKeyPath:@"names"];
}


@end

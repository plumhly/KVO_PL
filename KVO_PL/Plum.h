//
//  Plum.h
//  KVO_PL
//
//  Created by Plum on 2017/8/19.
//  Copyright © 2017年 Plum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Plum : NSObject

@property (nonatomic, strong) NSArray *numbers;

@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, strong) NSString *ID;



- (void)addName;

- (void)addNameWithKVO;

- (void)removeName;

- (void)removeNameWithKVO;


@end

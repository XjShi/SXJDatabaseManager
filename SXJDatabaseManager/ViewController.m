//
//  ViewController.m
//  SXJDatabaseManager
//
//  Created by xjshi on 15/12/16.
//  Copyright © 2015年 xjshi. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Method method = class_getClassMethod([self class], @selector(testWithStr:integerValue:));
    unsigned int numberOfArguments = method_getNumberOfArguments(method);
    for (NSInteger i = 0; i < numberOfArguments; i++) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)testWithStr:(NSString *)str integerValue:(NSInteger)integerValue {
    
}

@end

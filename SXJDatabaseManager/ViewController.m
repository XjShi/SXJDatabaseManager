//
//  ViewController.m
//  SXJDatabaseManager
//
//  Created by xjshi on 15/12/16.
//  Copyright © 2015年 xjshi. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Rectangle.h"
#import "SXJDatabaseManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    Method method = class_getClassMethod([self class], @selector(testWithStr:integerValue:));
//    unsigned int numberOfArguments = method_getNumberOfArguments(method);
//    for (NSInteger i = 0; i < numberOfArguments; i++) {
//        
//    }
    
    SXJDatabaseManager *manager = [SXJDatabaseManager sharedManager];
    [manager createTable:[Rectangle class]];
    [manager createTableWithClass:[Rectangle class] primaryKeyNameArray:@[@"name"]];
    
    Rectangle *rect = [Rectangle new];
    rect.name = @"rectangle1";
    rect.width = 10;
    rect.length = 25;
    [manager insertModel:rect];
    
    NSDictionary *cond = @{@"name": @"rectangle1"};
    [manager deleteRecordFromTable:[Rectangle class] condition:cond];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)testWithStr:(NSString *)str integerValue:(NSInteger)integerValue {
    
}

@end

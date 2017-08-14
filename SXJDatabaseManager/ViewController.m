//
//  ViewController.m
//  SXJDatabaseManager
//
//  Created by xjshi on 15/12/16.
//  Copyright © 2015年 xjshi. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "SXJDatabaseManager.h"
#import "Jumble.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dbTest];
}

- (void)logTypeEncoding {
    [self log:@encode(BOOL) type:@"BOOL"];
    [self log:@encode(bool) type:@"bool"];
    [self log:@encode(signed char) type:@"signed char"];
    [self log:@encode(char) type:@"char"];
    [self log:@encode(char *) type:@"char *"];
    [self log:@encode(NSString *) type:@"NSString *"];
//    [self log:@encode(NSString) type:@"NSString"];
    [self log:@encode(NSNumber *) type:@"NSNumber *"];
//    [self log:@encode(NSNumber) type:@"NSNumber"];
    [self log:@encode(int) type:@"int"];
    [self log:@encode(short) type:@"short"];
    [self log:@encode(long) type:@"long"];
    [self log:@encode(long long) type:@"long long"];
    [self log:@encode(unsigned char) type:@"unsigned char"];
    [self log:@encode(unsigned int) type:@"unsigned int"];
    [self log:@encode(unsigned short) type:@"unsigned short"];
    [self log:@encode(unsigned long) type:@"unsigned long"];
    [self log:@encode(unsigned long long) type:@"unsigned long long"];
    [self log:@encode(double) type:@"double"];
    [self log:@encode(float) type:@"float"];
    [self log:@encode(Class) type:@"Class"];
    [self log:@encode(id) type:@"id"];
//    [self log:@encode(NSDate) type:@"NSDate"];
    [self log:@encode(NSDate *) type:@"NSDate *"];
    
}

- (void)validateTypeEncoding {
    Jumble *jumble = [Jumble getAnRandomJumble];
    NSDictionary *propList = [jumble propertyListWithType];
    NSLog(@"propList--------:\n%@", propList);
}

- (void)log:(char *)str type:(NSString *)type {
    NSString *uft8Str = [[NSString alloc] initWithCString:str encoding:NSUTF8StringEncoding];
    NSLog(@"%@  :   %@", type, uft8Str);
}

- (void)dbTest {
    SXJDatabaseManager *manager = [SXJDatabaseManager sharedManager];
    [manager createTable:[Jumble class]];
    Jumble *jumble = [Jumble getAnRandomJumble];
    [manager insertModel:jumble];
    
    NSArray<Jumble *> *arr = [manager selectAllRecord:[Jumble class]];
    if (arr.count != 0) {
        Jumble *jumble = arr.firstObject;
        UIImage *image = [[UIImage alloc] initWithData:jumble.pic];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
        imageview.image = image;
        [self.view addSubview:imageview];
    }
}

@end

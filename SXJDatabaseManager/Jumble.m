//
//  Jumble.m
//  SXJDatabaseManager
//
//  Created by xjshi on 14/08/2017.
//  Copyright © 2017 jzkj. All rights reserved.
//

#import "Jumble.h"

/*
 @property (nonatomic) BOOL BOOL_value;
 @property (nonatomic) bool bool_value;
 @property (nonatomic) signed char signed_char_value;
 @property (nonatomic) char char_value;
 @property (nonatomic) char *char_ptr_value;
 @property (nonatomic) NSString *NSString_value;
 @property (nonatomic) NSNumber *NSNumber_value;
 @property (nonatomic) int int_value;
 @property (nonatomic) short short_value;
 @property (nonatomic) long long_value;
 @property (nonatomic) long long long_long_value;
 @property (nonatomic) unsigned char unsigned_char_value;
 @property (nonatomic) unsigned int unsigned_int_value;
 @property (nonatomic) unsigned short unsigned_short_value;
 @property (nonatomic) unsigned long unsigned_long_value;
 @property (nonatomic) unsigned long long unsigned_long_long_value;
 @property (nonatomic) double double_value;
 @property (nonatomic) float float_value;
 @property (nonatomic) NSDate *NSDate_value;
 */
@implementation Jumble

+ (Jumble *)getAnRandomJumble {
    Jumble *jumble = [[self alloc] init];
    jumble.BOOL_value = YES;
//    jumble.cplusplus_bool_value = true;
//    jumble.signed_char_value = 'c';
//    jumble.char_value = 'b';
//    jumble.char_ptr_value = "abc";
    jumble.NSString_value = @"zzz";
    jumble.NSNumber_value = @123;
    jumble.int_value = 1024;
    jumble.short_value = 66;
    jumble.long_value = -(2 << 30);
    jumble.long_long_value = -(2 << 30) + 100;
//    jumble.unsigned_char_value = 'x';
    jumble.unsigned_int_value = 4096;
    jumble.unsigned_short_value = 23;
    jumble.unsigned_long_value = 999;
    jumble.unsigned_long_long_value = (2 << 30) + 100;
    jumble.double_value = 3.1415;
    jumble.float_value = 3.1415;
//    jumble.NSDate_value = [NSDate new];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"insidewall" withExtension:@"jpg"];
    NSError *error = nil;
    NSData *pic = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    if (!error) {
        jumble.pic = pic;
    }
    return jumble;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end

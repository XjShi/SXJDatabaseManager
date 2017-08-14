//
//  Jumble.h
//  SXJDatabaseManager
//
//  Created by xjshi on 14/08/2017.
//  Copyright © 2017 jzkj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Jumble : NSObject

@property (nonatomic) BOOL BOOL_value;
//@property (nonatomic) bool cplusplus_bool_value;  //
//@property (nonatomic) signed char signed_char_value;  //
//@property (nonatomic) char char_value;    //
//@property (nonatomic) char *char_ptr_value;   //
@property (nonatomic) NSString *NSString_value;
@property (nonatomic) NSNumber *NSNumber_value;
@property (nonatomic) int int_value;
@property (nonatomic) short short_value;
@property (nonatomic) long long_value;
@property (nonatomic) long long long_long_value;
//@property (nonatomic) unsigned char unsigned_char_value;  //
@property (nonatomic) unsigned int unsigned_int_value;
@property (nonatomic) unsigned short unsigned_short_value;
@property (nonatomic) unsigned long unsigned_long_value;
@property (nonatomic) unsigned long long unsigned_long_long_value;
@property (nonatomic) double double_value;
@property (nonatomic) float float_value;
//@property (nonatomic) NSDate *NSDate_value;
@property (nonatomic) NSData *pic;

//@property (nonatomic) id id_value;
//@property (nonatomic) Class class_value;

+ (Jumble *)getAnRandomJumble;

@end

//
//  Created by xjshi on 15/7/23.
//  Copyright (c) 2015年 xjshi. All rights reserved.
//

#import "NSObject+SXJ.h"
#import <objc/runtime.h>

@implementation NSObject (SXJ)

/**
 *  得到对象的属性列表
 *
 *  @param withValue YES时，返回的属性列表包括值；NO时，返回的属性列表值为[NSNull null]
 */
- (NSDictionary *)propertyListWithValue:(BOOL)withValue {
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    u_int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (u_int i = 0; i < count; ++i) {
        NSString *propertyName = [NSString stringWithCString:property_getName(propertyList[i])
                                                    encoding:NSUTF8StringEncoding];
        if (withValue) {
            id propertyValue = [self valueForKey:propertyName];
            if (propertyName) {
                if (propertyValue == nil) {
                    [resultDict setObject:[NSNull null] forKey:propertyName];
                } else {
                    [resultDict setObject:propertyValue forKey:propertyName];
                }
            }
        } else {
            [resultDict setObject:[NSNull null] forKey:propertyName];
        }
    }
    return resultDict;
}

/**
 *  得到对象的属性列表 <属性名，属性数据类型>
 */
- (NSDictionary *)propertyListWithType {
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    u_int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (u_int i = 0; i < count; ++i) {
        objc_property_t property = propertyList[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *propertyType = [self typeOfProperty:property];
        [resultDict setObject:propertyType forKey:propertyName];
    }
    return resultDict;
}

#pragma mark - Inner Method
/**
 *  从属性的类型编码得到人们容易理解的类型
 */
- (NSString *)typeOfProperty:(objc_property_t)property {
    NSString *propertyAttribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    if ([propertyAttribute hasPrefix:@"T@,"]) {
        return @"id";
    }
    if ([propertyAttribute hasPrefix:@"T@"]) {
        NSRange range = [propertyAttribute rangeOfString:@"\"" options:NSBackwardsSearch];
        NSRange typeStringRange = NSMakeRange(3, range.location - 3);
        return [propertyAttribute substringWithRange:typeStringRange];
    } else if ([propertyAttribute hasPrefix:@"T#"]) {
        return @"Class";
    } else {
        NSString *tmpStr = [propertyAttribute substringWithRange:NSMakeRange(1, 1)];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"typeEncoding" ofType:@"plist"];
        NSAssert(path, @"typeEncoding.plist doesn't exists!");
        if (path) {
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
            return [dict objectForKey:tmpStr];
        }
    }
    return nil;
}

@end

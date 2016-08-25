//
//  Created by xjshi on 15/7/23.
//  Copyright (c) 2015年 xjshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SXJ)

/**
 *  得到对象的属性列表
 *
 *  @param withValue YES时，返回的属性列表包括值；NO时，返回的属性列表值为[NSNull null]
 */
- (NSDictionary *)propertyListWithValue:(BOOL)withValue;

/**
 *  得到对象的属性列表 <属性名，属性数据类型>
 */
- (NSDictionary *)propertyListWithType;

@end

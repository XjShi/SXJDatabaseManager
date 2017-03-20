# SXJDatabaseManager
结合objc的runtime，对[FMDB](https://github.com/ccgus/fmdb)的进一步封装，可方便快捷的对单个模型进行CRUD操作。如：	

~~~objc
@interface Rectangle : NSObject

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, copy) NSString *name;

@end

@implementation Rectangle

@end
~~~
获取`SXJDatabaseManager`对象：

~~~objc
SXJDatabaseManager *manager = [SXJDatabaseManager sharedManager];
~~~
创建`Rectange`对应的表：

~~~objc
[manager createTable:[Rectangle class]];
~~~
创建`Rectange`对应的表，并指定主键：

~~~objc
[manager createTableWithClass:[Rectangle class] primaryKeyNameArray:@[@"name"]];
~~~
向表中插入数据：

~~~objc
Rectangle *rect = [Rectangle new];
rect.name = @"rectangle1";
rect.width = 10;
rect.length = 25;
[manager insertModel:rect];
~~~
删除数据：

~~~objc
NSDictionary *cond = @{@"name": @"rectangle1"};
[manager deleteRecordFromTable:[Rectangle class] condition:cond];
~~~

更多用法，请直接参考`SXJDatabaseManager.h`中的api。


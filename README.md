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

##存在的问题
由于目前只考虑单表操作，且不考虑把某种类型的属性序列化后存储，所以不支持属性中为集合类型，如`NSDictionary`，`NSArray`，`NSSet`。后续，如果要支持的话，优先考虑多表方案。

**欢迎使用、交流^_^**
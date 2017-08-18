# SXJDatabaseManager
结合 objc 的 runtime ，对 [FMDB](https://github.com/ccgus/fmdb) 的进一步封装，实现的 ORM 工具库。

## 开发背景
在开发一个社交类项目的时候，项目有由大量实体需要使用数据库缓存。为避免编写大量的样板代码，开发该 ORM 工具。该工具在此项目中工作良好，并在公司其它项目中得到广泛使用。

## 细节
### 支持的架构
当前版本仅支持 amr64 架构的设备。

### 支持的数据类型及 type affinity
type | type affinity |
--- | --- |
int | integer
short | integer
long | integer
long long | integer
unsigned int | integer
unsigned short | integer
unsigned long | integer
unsigned long long | integer
float | real
double | real
BOOL | integer
NSString | text
NSNumber | text
NSData | blob

> 注意：`NSInteger`、`NSTimeInterval` 等实际都是通过 typedef 定义的原声数据类型，这样的类型也是支持的。
> 
> 目前不支持`bool`（C++ 的 bool）、`signed char`、`char`、原生数据类型的指针(`int *`、`char *`等)、`unsigned char`、`id`、`Class`及不在上边列表里的类类型。

## 安装
下载该工程，把 DB 目录及其下的四个文件添加进你的工程中即可。

## 用法
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

如果您有任何建议，可以通过任何方式联系我。
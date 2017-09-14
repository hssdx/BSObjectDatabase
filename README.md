# 【废弃，请使用 XQ_DAO】

# BSObjectDatabase

## BSObjectDatabase 是一种基于 fbdb 的简单对象存储模型，支持面向对象的增删改查、批量增加数据、数据模型升级等特性
### 使用方法
首先你得创建一个 BSModelBase 派生 Model 类

@interface CellModel : BSModelBase
@property (nonatomic, copy) NSString *title;
@end

然后在安装数据库时，传入此类的 class :

    [[BSModelManager sharedManager] setupForClasses:@[CellModel.class]];

添加一份数据：

    CellModel *model = [CellModel new];
    model.title = [NSString stringWithFormat:@"model - %@", @(self.datasource.count+1)];
    [model save];
    
查询这份数据：

    self.datasource = [CellModel queryModels];

批量增加数据：


    NSMutableArray *models = [@[] mutableCopy];
    for (NSUInteger idx = 0; idx < 5; ++idx) {
        CellModel *model = [CellModel new];
        model.title = [NSString stringWithFormat:@"model - %@", @(self.datasource.count+1+idx)];
        [models addObject:model];
    }
    [CellModel addObjectsInTransaction:models updateIfExist:YES];
    
删除和修改操作类似，其中修改操作和增加数据操作'几乎完全一样'

## SQLCondition 是增加 SQL 查询条件的辅助类，对 SQL 语句的简单抽象

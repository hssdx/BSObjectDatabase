//
//  ModelBase.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/12/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSModelBase.h"
#import "BS_SQLCondition.h"
#import "BSModelManager.h"
//#import "ReactiveCocoa.h"
#import <objc/runtime.h>
#import "FMDBCode.h"
#import "BSODUtilities.h"

/**
 *  model表信息，包括字段名集合，字段类型集合，表名
 *  @{@"fieldNames": NSArray, @"fieldTypes":NSArray, @"tableName":NSString}
 */
typedef NSArray<NSString *> WCModelDescribtion;
typedef NSDictionary<NSString *, id> WCModelTableDescribtion;
typedef NSCache<NSString *, WCModelTableDescribtion *> WCModelCacheType;

static WCModelCacheType *g_ModelBaseCache;

NSString *const kFieldNames = @"fieldNames";
NSString *const kFieldTypes = @"fieldTypes";
NSString *const kTableName = @"tableName";

@implementation BSModelBase
@end

@implementation BSModelBase(Access)
- (void)setModelDirty:(BOOL)dirty {
}

- (BOOL)modelDirty {
    return NO;
}
@end

@implementation BSModelBase(Database)
+(void)load {
    g_ModelBaseCache = [[NSCache alloc]init];
}

/**
 *  获取表信息，包括字段名集合，字段类型集合，表名
 *
 *  @return @{@"fieldNames": NSArray, @"fieldTypes":NSArray, @"tableName":NSString}
 */

+ (WCModelTableDescribtion *)tableDescribtion {
    Class _class = [self class];
    NSString *tableName = NSStringFromClass(_class);
    NSString *cacheKey = [NSString stringWithFormat:@"%@_Describtion", tableName];
    
    if ([g_ModelBaseCache objectForKey:cacheKey]) {
        return [g_ModelBaseCache objectForKey:cacheKey];
    } else {
        NSMutableArray<NSString *> *fieldNames = [NSMutableArray array];
        NSMutableArray<NSString *> *fieldTypes = [NSMutableArray array];
        
        unsigned int outCount = 0;
        while (NO == [NSStringFromClass(_class) isEqualToString:@"NSObject"]) {
            objc_property_t *props = class_copyPropertyList(_class, &outCount);
            [self getFieldNames:fieldNames fieldTypes:fieldTypes props:props propsCount:outCount];
            
            _class = class_getSuperclass(_class);
        }
        WCModelTableDescribtion *result = @{kFieldNames:fieldNames,
                                            kFieldTypes:fieldTypes,
                                            kTableName:tableName};
        [g_ModelBaseCache setObject:result forKey:cacheKey];
        return result;
    }
}

+ (void)getFieldTypes:(char (*)[64])fieldTypes attrStr:(const char *)attrStr {
    char *start = strstr(attrStr, "T@\"");
    if (start) {
        strcpy(*fieldTypes, start + strlen("T@\""));
        char *end = strstr(*fieldTypes, "\",");
        *end = '\0';
    } else {
        (*fieldTypes)[0] = '\0';
    }
}

+ (void)getFieldNames:(NSMutableArray<NSString *> *)fieldNames
           fieldTypes:(NSMutableArray<NSString *> *)fieldTypes
                props:(objc_property_t *)props
           propsCount:(unsigned int)propsCount{
    for (int i = 0; i < propsCount; i++) {
        objc_property_t prop = props[i];
        const char *attrStr = property_getAttributes(prop);
        char cpyDes[64];
        [self getFieldTypes:&cpyDes attrStr:attrStr];
        if (strlen(cpyDes) > 0) {
            NSString *type = [NSString stringWithUTF8String:cpyDes];
            NSString *propType = KSRequiredCast([self propTypeMapping][type], NSString);
            if (propType) {
                [fieldTypes addObject:propType];
                [fieldNames addObject:[NSString stringWithUTF8String:property_getName(prop)]];
            }
        }
    }
}

#pragma mark - prop helper
+ (NSDictionary *)propTypeMapping {
    return @{@"NSString":@"TEXT",
             @"NSNumber":@"INTEGER",};
}

+ (NSDictionary *)expandPropFieldTypeMap {
    return @{@"localID":@"PRIMARY KEY AUTOINCREMENT NOT NULL",
             @"serverID":@"default null",
             @"deleted":@"default 0",
             @"dirty":@"default 0"};
}

+ (NSString *)expandPropFieldType:(NSString *)fieldName {
    NSDictionary *mapping = [self expandPropFieldTypeMap];
    NSString *result = mapping[fieldName];
    if ([result length] > 0) {
        return result;
    } else {
        return @"";
    }
}

+ (NSString *)orderSQL {
    return @"localID DESC";
}

+ (NSDictionary<NSString *, NSNumber *> *)startValueForAutoIncrement {
    return @{@"localID":@100};
}

+ (BS_SQLCondition *)defaultExistCondition:(id)modelObj {
    BS_SQLCondition *condition = [BS_SQLCondition new];
    BSModelBase *model = KSRequiredCast(modelObj, BSModelBase);
    [condition addWhereField:PROP_TO_STRING(localID) compare:SQLCompareEqual value:model.localID logicCode:LogicCodeNone];
    [condition addWhereField:PROP_TO_STRING(serverID) compare:SQLCompareEqual value:model.serverID logicCode:LogicCodeOr];
    return condition;
}

#pragma mark - public func
+ (BSModelBase *)existObject:(BSModelBase *)modelObj {
    BS_SQLCondition *condition = [self defaultExistCondition:modelObj];
    if ([condition.condition count] == 0) {
        return nil;
    }
    BSModelBase *result = [self queryModelsWithCondition:condition].firstObject;
    return result;
}

+ (BOOL)isUniqueID:(NSString *)uid {
    if ([uid isEqualToString:PROP_TO_STRING(localID)]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isNoNeedUpdate:(NSString *)uid {
    if ([uid isEqualToString:PROP_TO_STRING(localID)]) {
        return YES;
    } if ([uid isEqualToString:PROP_TO_STRING(UUID)]) {
        return YES;
    } if ([uid isEqualToString:PROP_TO_STRING(serverID)]) {
        return YES;
    }
    return NO;
}

/**
 *  如果是需要更新的字段，或数据库中不存在，则需要更新
 */
- (BOOL)shouldUpdatedbModel:(BSModelBase *)dbModel withFieldName:(NSString *)fieldName{
    id value = [self valueForKey:fieldName];
    if (!value) {
        return NO;
    }
    id dbValue = [dbModel valueForKey:fieldName];
    if (!dbValue) {
        return YES;
    }
    if ([BSModelBase isNoNeedUpdate:fieldName]) {
        return NO;
    }
    if (([value isKindOfClass:[NSString class]] && [value isEqualToString:dbValue]) ||
        ([value isKindOfClass:[NSNumber class]] && [(NSNumber*)value compare:dbValue] == NSOrderedSame)) {
        return NO;
    }
    return YES;
}

+ (NSString*)rawUUID {
    KSAssert(false);
    return nil;
}

+ (void)copyFromObject:(BSModelBase *)fromObject toObject:(BSModelBase *)toObject {
    WCModelTableDescribtion *tableDescribtion = [self tableDescribtion];
    WCModelDescribtion *fieldNames = tableDescribtion[kFieldNames];
    [fieldNames enumerateObjectsUsingBlock:^(NSString * _Nonnull fieldName, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [fromObject valueForKey:fieldName];
        if (value) {
            [toObject setValue:value forKey:fieldName];
        }
    }];
}

+ (void)addObjectsInTransaction:(NSArray<__kindof BSModelBase *> *)objects updateIfExist:(BOOL)updateIfExist {
    __block NSMutableArray<FmdbBlock> *blocks = [@[] mutableCopy];
    [objects enumerateObjectsUsingBlock:^(__kindof BSModelBase * _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
        FmdbBlock block = [self dbBlockForAddObject:^(id model) {
            [self copyFromObject:object toObject:model];
        } updateIfExist:updateIfExist];
        if (block) {
            [blocks addObject:block];
        }
    }];
    [[BSModelManager sharedManager] executeOperationInTransaction:blocks];
}

+ (void)addObject:(__kindof BSModelBase *)object {
    [self addObject:object updateIfExist:YES];
}

+ (void)addObject:(__kindof BSModelBase *)object updateIfExist:(BOOL)updateIfExist {
    [self addObjectWithBlock:^(id model) {
        [self copyFromObject:object toObject:model];
    } updateIfExist:updateIfExist];
}

+ (void)addObjectWithBlock:(InitModelBlock)initModelBlock updateIfExist:(BOOL)updateIfExist {
    [self addObjectWithBlock:initModelBlock updateIfExist:updateIfExist optType:nil];
}

+ (void)addObjectWithBlock:(InitModelBlock)initModelBlock updateIfExist:(BOOL)updateIfExist optType:(DBOptType *)optType {
    FmdbBlock block = [self dbBlockForAddObject:initModelBlock updateIfExist:updateIfExist optType:optType];
    if (block) {
        [[BSModelManager sharedManager] executeOperationWithBlock:block];
    }
}

- (void)save {
    [self.class addObject:self];
}

+ (BOOL)deleteModel:(InitModelBlock)initModelBlock {
    BSModelBase *model = [[self alloc]init];
    if (initModelBlock) {
        initModelBlock(model);
    }
    if (![self existObject:model]) {
        return NO;
    }
    return [self deleteModelCondition:[self defaultExistCondition:model]];
}

+ (BOOL)deleteModelCondition:(BS_SQLCondition *)condition {
    if (nil == condition) {
        return [self clean];
    }
    
    __block BOOL res = NO;
    __block NSError *error;
    
    FmdbBlock block = ^BOOL(FMDatabase *db){
        WCModelTableDescribtion *tableDescribtion = [self tableDescribtion];
        NSString *tableName = tableDescribtion[kTableName];
        NSString *whereSql = [condition whereAndLimitSQL];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@", tableName, whereSql];
        
        res = [db executeUpdate:sql withErrorAndBindings:&error];
        if (!res)
            KSLog(@"db failure when delete '%@', (%@)", NSStringFromClass(self), error);
        return res;
    };
    [[BSModelManager sharedManager] executeOperationWithBlock:block];
    return res;
}

+ (BOOL)clean {
    __block BOOL res = NO;
    __block NSError *error;
    
    FmdbBlock block = ^BOOL(FMDatabase *db){
        WCModelTableDescribtion *tableDescribtion = [self tableDescribtion];
        NSString *tableName = tableDescribtion[kTableName];
        NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
        res = [db executeUpdate:sql withErrorAndBindings:&error];
        if (res) {
            res = [db executeUpdate:[self createSQL] withErrorAndBindings:&error];
            KSLog(@"Model '%@' clean success", NSStringFromClass(self));
        }
        return res;
    };
    
    [[BSModelManager sharedManager] executeOperationWithBlock:block];
    
    if (!res)
        KSLog(@"db open failure when delete '%@', (%@)", NSStringFromClass(self), error);
    return res;
}

+ (NSArray *)queryModels {
    return [self queryModelsAtIndex:0 limitCount:0];
}

+ (NSArray *)queryModelsWithCondition:(BS_SQLCondition *)condition {
    __block NSMutableArray *queryResult = [NSMutableArray array];
    [self queryModelsWithBlock:^(id model) {
        [queryResult addObject:model];
    } condition:condition];
    return queryResult;
}

+ (void)queryModelsWithBlock:(QueryModelBlock)queryModelBlock
                     atIndex:(NSUInteger)index
                  limitCount:(NSUInteger)limitCount {
    BS_SQLCondition *condition = [BS_SQLCondition new];
    [condition setLimitFrom:index limitCount:limitCount];
    [self queryModelsWithBlock:queryModelBlock
                     condition:condition];
}

+ (NSArray *)queryModelsAtIndex:(NSUInteger)index limitCount:(NSUInteger)limitCount {
    BS_SQLCondition *condition = [BS_SQLCondition new];
    [condition setLimitFrom:index limitCount:limitCount];
    return [self queryModelsWithCondition:condition];
}

+ (NSMutableDictionary *)queryBySection:(NSString *)sectionKeyPath
                              condition:(BS_SQLCondition *)condition {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self queryModelsWithBlock:^(id model) {
        id section = nil;
        if ([section isKindOfClass:[NSNull class]]
            || [sectionKeyPath length] == 0) {
            section = @0;
        } else {
            section = [model valueForKey:sectionKeyPath];
        }
        NSMutableArray *array = dictionary[section];
        if (!array) {
            array = [NSMutableArray array];
            dictionary[section] = array;
        }
        [array addObject:model];
    } condition:condition];
    return dictionary;
}

+ (instancetype)queryModelWithUUID:(NSString *)UUID {
    BS_SQLCondition *condition = [BS_SQLCondition new];
    [condition addWhereField:PROP_TO_STRING(UUID) compare:SQLCompareEqual value:UUID logicCode:LogicCodeNone];
    __block BSModelBase *result = nil;
    [self queryModelsWithBlock:^(id model) {
        result = KSRequiredCast(model, BSModelBase);
    } condition:condition];
    return result;
}

+ (instancetype)queryModelWithLocalID:(NSNumber *)localID {
    BS_SQLCondition *condition = [BS_SQLCondition new];
    [condition addWhereField:PROP_TO_STRING(localID) compare:SQLCompareEqual value:localID logicCode:LogicCodeNone];
    __block BSModelBase *result = nil;
    [self queryModelsWithBlock:^(id model) {
        result = KSRequiredCast(model, BSModelBase);
    } condition:condition];
    return result;
}

+ (instancetype)queryModelWithServerID:(NSNumber *)serverID {
    if (!serverID || serverID.intValue <= 0) {
        return nil;
    }
    BS_SQLCondition *condition = [BS_SQLCondition new];
    [condition addWhereField:PROP_TO_STRING(serverID) compare:SQLCompareEqual value:serverID logicCode:LogicCodeNone];
    __block BSModelBase *result = nil;
    [self queryModelsWithBlock:^(id model) {
        result = KSRequiredCast(model, BSModelBase);
    } condition:condition];
#if DEBUG
    if (result == nil) {
        KSLog(@"查询结果为空![%@]", serverID);
    }
#endif
    return result;
}

+ (void)queryModelsWithBlock:(QueryModelBlock)queryModelBlock condition:(BS_SQLCondition *)condition {
    WCModelTableDescribtion *tableDescribtion = [self tableDescribtion];
    WCModelDescribtion *fieldNames = tableDescribtion[kFieldNames];
    NSString *tableName = tableDescribtion[kTableName];
    
    WeakSelf
    FmdbBlock block = ^BOOL(FMDatabase *db){
        /*select * from user where localID=1 order by xx DESC limit 0,1*/
        NSMutableString *sql = [NSMutableString stringWithString:@"select "];
        for (NSUInteger index = 0; index < fieldNames.count; ++index) {
            NSString *name = fieldNames[index];
            [sql appendString:name];
            if (index != fieldNames.count - 1) {
                [sql appendString:@","];
            }
        }
        [sql appendFormat:@" from %@ ", tableName];
        if (!condition.orderSQL){
            [condition setOrderSQL:[weakSelf orderSQL]];
        }
        
        NSString *conditionSQL = [condition conditionSQL];
        if ([conditionSQL length] > 0) {
            [sql appendString:conditionSQL];
        }
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            id object = [[weakSelf alloc] init];
            
            for (NSString *name in fieldNames) {
                id value = [rs objectForColumnName:name];
                if (value && NO == [value isKindOfClass:[NSNull class]]) {
                    [object setValue:value forKey:name];
                }
            }
            if (queryModelBlock) {
                queryModelBlock(object);
            }
        }
        if (!rs) {
            NSError *error = [db lastError];
            if (error.code != 0) {
                return NO;
            }
        }
        return YES;
    };
    [[BSModelManager sharedManager] executeOperationWithBlock:block];
}

+ (NSString *)createSQL {
    WCModelTableDescribtion *tableDescribtion = [self tableDescribtion];
    WCModelDescribtion *fieldNames = tableDescribtion[kFieldNames];
    WCModelDescribtion *fieldTypes = tableDescribtion[kFieldTypes];
    NSString *tableName = tableDescribtion[kTableName];
    
    NSMutableString *resultSQL =
    [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS `%@` (\n", tableName];
    KSAssert(fieldNames.count == fieldTypes.count);
    [fieldNames enumerateObjectsUsingBlock:^(NSString * _Nonnull fieldName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fieldType = [fieldTypes objectAtIndex:idx];
        NSString *formatString = @" `%@` %@ %@,\n";
        if (idx == fieldNames.count - 1) {
            formatString = @" `%@` %@ %@\n";
        }
        [resultSQL appendFormat:formatString, fieldName, fieldType, [self expandPropFieldType:fieldName]];
    }];
    [resultSQL appendString:@");"];
    NSDictionary<NSString *, NSNumber *> *startDict = self.startValueForAutoIncrement;
    if (startDict.count > 0) {
        [startDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull fieldName, NSNumber * _Nonnull startValue, BOOL * _Nonnull stop) {
            [resultSQL appendFormat:@"\n\
             insert into %@ (%@) values (%@);\n\
             delete from %@ where %@ = %@;"
             , tableName, fieldName, startValue
             , tableName, fieldName, startValue];
        }];
    }
    return resultSQL;
}

#pragma mark - mapping
+ (NSDictionary *)keyMap {
    return nil;
}

- (void)mappingByDictionary:(NSDictionary *)dictionary {
    NSDictionary *keyMap = [self.class keyMap];
    NSDictionary *tableDescribtion = [self.class tableDescribtion];
    NSArray *fieldNames = tableDescribtion[kFieldNames];
    
    [fieldNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fieldName = KSRequiredCast(obj, NSString);
        NSString *key = [keyMap objectForKey:fieldName];
        if (nil == key) {
            key = fieldName;
        }
        if ([key length] > 0) {
            id value = [dictionary objectForKey:key];
            if (value && [NSNull null] != value) {
                [self setValue:value forKey:fieldName];
            }
        }
    }];
}

- (NSDictionary *)mappingToDictionary {
    NSDictionary *keyMap = [self.class keyMap];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSDictionary *tableDescribtion = [self.class tableDescribtion];
    NSArray *fieldNames = tableDescribtion[kFieldNames];
    
    [fieldNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fieldName = KSRequiredCast(obj, NSString);
        NSString *key = [keyMap objectForKey:fieldName];
        if (nil == key) {
            key = fieldName;
        }
        if ([key length] > 0) {
            id value = [self valueForKey:fieldName];
            if (value) {
                [result setObject:value forKey:key];
            }
        }
    }];
    return result;
}

#pragma mark - helper
+ (FmdbBlock)dbBlockForInsertObject:(BSModelBase *)model {
    WCModelTableDescribtion *tableDescribtion = [self tableDescribtion];
    WCModelDescribtion *fieldNames = tableDescribtion[kFieldNames];
    NSString *tableName = tableDescribtion[kTableName];
    
    __weak id weakSelf = self;
    return ^BOOL(FMDatabase *db) {
        id strongSelf = weakSelf;
        NSMutableString *sql = [NSMutableString stringWithString:@"insert into "];
        [sql appendString:tableName];
        NSMutableArray *columnArray = [NSMutableArray array];
        NSMutableArray *valuesArray = [NSMutableArray array];
        NSMutableArray *sympleArray = [NSMutableArray array];
        [fieldNames enumerateObjectsUsingBlock:
         ^(NSString *_Nonnull fieldName, NSUInteger idx, BOOL * _Nonnull stop) {
             if (![self isUniqueID:fieldName]) {
                 id value = [model valueForKey:fieldName];
                 if (!value && [fieldName isEqualToString:PROP_TO_STRING(UUID)]) {
                     //确保有uuid
                     value = [strongSelf rawUUID];
                 }
                 if (value && ![value isKindOfClass:[NSNull class]]) {
                     [columnArray addObject:fieldName];
                     [valuesArray addObject:value];
                     [sympleArray addObject:@"?"];
                 }
             }
         }];
        NSString *columnSql = [[columnArray valueForKey:@"description"] componentsJoinedByString:@","];
        NSString *sympleSql = [[sympleArray valueForKey:@"description"] componentsJoinedByString:@","];
        [sql appendFormat:@" (%@) values (%@)", columnSql, sympleSql];
        BOOL res = [db executeUpdate:sql withArgumentsInArray:valuesArray];
        KSAssert(res);
        return res;
    };
}

+ (FmdbBlock)dbBlockForUpdateObject:(BSModelBase *)model dbModel:(BSModelBase *)dbModel condition:(BS_SQLCondition *)condition {
    WCModelTableDescribtion *tableDescribtion = [self tableDescribtion];
    WCModelDescribtion *fieldNames = tableDescribtion[kFieldNames];
    NSString *tableName = tableDescribtion[kTableName];
    
    __weak id weakSelf = self;
    return ^BOOL(FMDatabase *db){
        id strongSelf = weakSelf;
        NSMutableArray *columnArray = [NSMutableArray array];
        NSMutableArray *valuesArray = [NSMutableArray array];
        [fieldNames enumerateObjectsUsingBlock:
         ^(NSString *_Nonnull fieldName, NSUInteger idx, BOOL * _Nonnull stop) {
             if (![strongSelf isUniqueID:fieldName]) {
                 
                 if ([model shouldUpdatedbModel:dbModel withFieldName:fieldName]) {
                     [columnArray addObject:[NSString stringWithFormat:@" %@=? ", fieldName]];
                     [valuesArray addObject:[model valueForKey:fieldName]];
                     [dbModel setValue:[model valueForKey:fieldName] forKey:fieldName];
                 }
             }
         }];
        if (valuesArray.count != 0) {
            NSString *columnSql = [[columnArray valueForKey:@"description"] componentsJoinedByString:@","];
            NSString *whereSql = [condition conditionSQL];
            NSMutableString *sql = [NSMutableString stringWithString:@""];
            [sql appendFormat:@"UPDATE %@ SET %@ ", tableName, columnSql];
            if (whereSql) {
                [sql appendString:whereSql];
            }
            BOOL res = [db executeUpdate:sql withArgumentsInArray:valuesArray];
            KSAssert(res);
            return res;
        }
        return YES;
    };
}

+ (FmdbBlock)dbBlockForAddObject:(InitModelBlock)initModelBlock updateIfExist:(BOOL)updateIfExist {
    return [self dbBlockForAddObject:initModelBlock updateIfExist:updateIfExist optType:nil];
}

+ (FmdbBlock)dbBlockForAddObject:(InitModelBlock)initModelBlock updateIfExist:(BOOL)updateIfExist optType:(DBOptType *)optType {
    FmdbBlock block;
    BSModelBase *model = [[self alloc]init];
    if (initModelBlock) {
        initModelBlock(model);
    }
    if (optType) {
        *optType = DBOptTypeUpdate;
    }
    BSModelBase *dbExistModel = [self existObject:model];
    if (dbExistModel) {
        if (updateIfExist) {
            //delete opt
            if (optType) {
                static NSString *deletedSelectStr = @"deleted";
                if ([model respondsToSelector:NSSelectorFromString(deletedSelectStr)]) {
                    NSNumber *deleted = [model valueForKey:deletedSelectStr];
                    if (deleted.boolValue) {
                        *optType = DBOptTypeDelete;
                    }
                }
            }
            block = [self dbBlockForUpdateObject:model dbModel:dbExistModel condition:[self defaultExistCondition:model]];
        }
    } else {
        if (optType) {
            *optType = DBOptTypeAdd;
        }
        block = [self dbBlockForInsertObject:model];
    }
    return block;
}

@end

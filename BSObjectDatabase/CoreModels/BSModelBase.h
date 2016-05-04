//
//  ModelBase.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/12/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSModelBlocks.h"

typedef NS_ENUM(NSInteger, DBOptType) {
    DBOptTypeNone,
    DBOptTypeDelete,
    DBOptTypeAdd,
    DBOptTypeUpdate,
};

@class BS_SQLCondition;

@interface BSModelBase : NSObject

@property (copy, nonatomic) NSNumber *serverID;
@property (copy, nonatomic) NSNumber *localID;

@end

@interface BSModelBase(Access)

- (void)setModelDirty:(BOOL)dirty;
- (BOOL)modelDirty;

@end

@interface BSModelBase(Database)

+ (NSString *)expandPropFieldType:(NSString *)fieldName;
+ (NSString *)createSQL;
+ (NSString *)orderSQL;

+ (NSArray *)queryModels;
+ (NSArray *)queryModelsWithCondition:(BS_SQLCondition *)condition;
+ (NSArray *)queryModelsAtIndex:(NSUInteger)index limitCount:(NSUInteger)limitCount;
+ (void)queryModelsWithBlock:(QueryModelBlock)queryModelBlock
                     atIndex:(NSUInteger)index
                  limitCount:(NSUInteger)limitCount;
+ (void)queryModelsWithBlock:(QueryModelBlock)queryModelBlock
                   condition:(BS_SQLCondition *)condition;
+ (NSMutableDictionary *)queryBySection:(NSString *)sectionKeyPath
                              condition:(BS_SQLCondition *)condition;
+ (instancetype)queryModelWithUUID:(NSString *)UUID;
+ (instancetype)queryModelWithLocalID:(NSNumber *)localID;
+ (instancetype)queryModelWithServerID:(NSNumber *)serverID;

+ (void)addObjectWithBlock:(InitModelBlock)initModelBlock updateIfExist:(BOOL)updateIfExist;
+ (void)addObjectWithBlock:(InitModelBlock)initModelBlock updateIfExist:(BOOL)updateIfExist optType:(DBOptType *)optType;
/**
 *  直接添加一个 model
 *
 *  @param object         目标 model
 *  @param updateIfExist  如果存在，是否自动更新
 *
 *  注意此方法会吧 object 所有不为 nil 的属性添加/更新到数据库，如果给定的 object 在数据库存在，但是没有给定 unique id (localID/UUID/serverID) 将会直接添加而不是更新数据库中内容
 */
+ (void)addObject:(__kindof BSModelBase *)object;
+ (void)addObject:(__kindof BSModelBase *)object updateIfExist:(BOOL)updateIfExist;
+ (void)addObjectsInTransaction:(NSArray<__kindof BSModelBase *> *)objects updateIfExist:(BOOL)updateIfExist;
- (void)save;

+ (BOOL)deleteModel:(InitModelBlock)initModelBlock;
+ (BOOL)deleteModelCondition:(BS_SQLCondition *)condition;
+ (BOOL)clean;

+ (NSDictionary *)expandPropFieldTypeMap;
/**
 *  class mapping key
 *  if `JsonKey` is @"", it will ignore this prop
 *
 *  @return @{`PropName`:`JsonKey`}
 */
+ (NSDictionary *)keyMap;
/**
 *  json dict transform to model
 *
 *  @param dictionary: json dict
 */
- (void)mappingByDictionary:(NSDictionary *)dictionary;
/**
 *  model to json dict
 *
 *  @return json dict
 */
- (NSDictionary *)mappingToDictionary;
/**
 *  this function for just set once prop in database, such as `localID/UUID/serverID...`
 *
 *  @param dbModel   model in database
 *  @param fieldName prop name
 *
 *  @return will update this prop about prop name if YES, or else NO
 *
 */
- (BOOL)shouldUpdatedbModel:(BSModelBase *)dbModel withFieldName:(NSString *)fieldName;
@end

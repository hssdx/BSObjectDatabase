//
//  MigrationItemBase.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 11/2/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MigrationOperationType) {
    MOTDeleteTable,
    MOTDeleteField,
    MOTModifyField,
    MOTAddField,
};

typedef NS_ENUM(NSInteger, FieldType) {
    FieldTypeNumber,
    FieldTypeString,
};

@interface BSMigrationOperationItem : NSObject

@property(assign, nonatomic) MigrationOperationType optType;
@property(assign, nonatomic) FieldType fieldTypeNew;
@property(copy, nonatomic) NSString *table;
@property(copy, nonatomic) NSString *fieldOld;
@property(copy, nonatomic) NSString *fieldNew;

@end

@interface BSMigrationItemBase : NSObject

/**
 *  迁移版本
 *
 *  @return 迁移版本号,对应db中databaseVersion字段.
 *  @如果返回17,表示当前迁移是版本16迁往版本17,每次只允许迁移一个版本编号,即不允许跨版本迁移.
 */
- (NSUInteger)version;

@property (strong, nonatomic) NSMutableArray *optArray;

@end

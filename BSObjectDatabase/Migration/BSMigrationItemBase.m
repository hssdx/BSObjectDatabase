//
//  MigrationItemBase.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 11/2/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSMigrationItemBase+Protect.h"
#import "BSODUtilities.h"

@implementation BSMigrationOperationItem

@end

@implementation BSMigrationItemBase

- (instancetype)init {
    if (self = [super init]) {
        [self loadOperationItem];
    }
    return self;
}

- (void)loadOperationItem {
    KSAssert(false);
}

- (NSUInteger)version {
    KSAssert(false);
    return 0;
}

- (NSMutableArray *)optArray {
    if (_optArray == nil) {
        _optArray = [NSMutableArray array];
    }
    return _optArray;
}

- (void)addOperationWithType:(MigrationOperationType)optType
                       table:(NSString *)table
                    oldField:(NSString *)fieldOld
                    newField:(NSString *)fieldNew
                   fieldType:(FieldType)fieldTypeNew {
    BSMigrationOperationItem *item = [BSMigrationOperationItem new];
    item.optType = optType;
    item.table  = table;
    item.fieldOld = fieldOld;
    item.fieldNew = fieldNew;
    item.fieldTypeNew = fieldTypeNew;
    [self.optArray addObject:item];
}

- (void)addField:(NSString *)field forTable:(NSString *)table fieldType:(FieldType)fieldType {
    [self addOperationWithType:MOTAddField table:table oldField:nil newField:field fieldType:fieldType];
}

@end

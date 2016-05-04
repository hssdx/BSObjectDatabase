//
//  MigrationItemBase+Protect.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 11/2/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSMigrationItemBase.h"

@interface BSMigrationItemBase()

- (void)addOperationWithType:(MigrationOperationType)optType
                       table:(NSString *)table
                    oldField:(NSString *)fieldOld
                    newField:(NSString *)fieldNew
                   fieldType:(FieldType)fieldTypeNew;

- (void)addField:(NSString *)field forTable:(NSString *)table fieldType:(FieldType)fieldType;

@end

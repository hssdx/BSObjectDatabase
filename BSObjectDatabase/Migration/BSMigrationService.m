//
//  MigrationService.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 11/2/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSMigrationService.h"
#import "BSMigrationItemBase+Protect.h"
#import "BSDatabaseVersion.h"
#import "BSModelManager.h"
#import "FMDBCode.h"
#import "BSODUtilities.h"

@interface BSMigrationService()

@property (strong, nonatomic) NSDictionary *migrationOptDict;

@end

@implementation BSMigrationService

- (instancetype)init {
    if (self = [super init]) {
        self.migrationOptDict = @{};
    }
    return self;
}

- (NSString *)showTable:(NSString *)tableName {
    __block NSString *result;
    FmdbBlock block = ^BOOL(FMDatabase *db){
        NSString *sql = [NSString stringWithFormat:@"SELECT `sql` FROM `sqlite_master` WHERE `tbl_name` = `%@`", tableName];
        /*
         TODO: DB Error: 1 "no such column: User"
         */
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            result = [result objectForColumnName:@"sql"];
            KSLog(@"[%@]", result);
        }
        return result != nil;
    };
    [[BSModelManager sharedManager] executeOperationWithBlock:block];
    return result;
}

- (void)startMigration {
    /*
     sqllite 只支持删除表，重命名表，添加额外的列，除此之外，不支持其他alter命令
     */
    NSDictionary *fieldTypeMap = @{@(FieldTypeNumber):@"INTEGER",
                                   @(FieldTypeString):@"TEXT"};
    
    BSDatabaseVersion *dbVersion = [[BSDatabaseVersion queryModels] firstObject];
    NSInteger currentDBVersion = dbVersion.version.integerValue;
    NSInteger targetDBVersion = DATABASE_VERSION;
    while (currentDBVersion < targetDBVersion) {
        ++currentDBVersion;
        BSMigrationItemBase *item = [self.migrationOptDict objectForKey:@(currentDBVersion)];
        for (BSMigrationOperationItem *optItem in item.optArray) {
            NSString *optSql;
            switch (optItem.optType) {
                case MOTDeleteTable:
                    optSql = [NSString stringWithFormat:@"DROP TABLE %@", optItem.table];
                    break;
                case MOTDeleteField:
                    //TODO: delete field
                    KSAssert(false);
                    break;
                case MOTModifyField:
                    //TODO: modeify field
                    KSAssert(false);
                    break;
                case MOTAddField:
                {
                    //Default value
                    NSString *fieldType = fieldTypeMap[@(optItem.fieldTypeNew)];
                    optSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", optItem.table, optItem.fieldNew, fieldType];
                }
                    break;
            }
            KSLog(@"opt sql:(%@)", optSql);
            FmdbBlock block = ^BOOL(FMDatabase *db){
                NSError *error;
                BOOL res = [db executeUpdate:optSql withErrorAndBindings:&error];
                if (!res) {
                    KSLog(@"db update error:(%@)", error);
                }
                return res;
            };
            [[BSModelManager sharedManager] executeOperationWithBlock:block];
#if DEBUG
            //[self showTable:optItem.table];
#endif
        }
        KSLog(@"DB migration (%d)to(%d) success!", (int)currentDBVersion-1, (int)currentDBVersion);
    }
    [BSDatabaseVersion addObjectWithBlock:^(id model) {
        BSDatabaseVersion *dv = KSRequiredCast(model, BSDatabaseVersion);
        dv.localID = dbVersion.localID;
        dv.version = @(DATABASE_VERSION);
    } updateIfExist:YES];
}

@end

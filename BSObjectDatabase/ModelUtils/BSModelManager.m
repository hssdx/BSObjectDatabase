//
//  ModelManager.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/14/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSModelManager.h"
#import "BSUserDefaultsModel.h"
#import "BSMigrationService.h"
#import "FMDBCode.h"
#import "BSODUtilities.h"
#import "BSModel.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface BSModelManager()
@property (strong, nonatomic, readwrite) FMDBModelManager *dbManager;
@end

@implementation BSModelManager

+ (instancetype)sharedManager {
    static BSModelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
        manager.dbManager = [FMDBModelManager dbManager];
    });
    return manager;
}

- (void)setupForClasses:(NSArray<Class> *)classes {
    [self executeOperationWithBlock:^BOOL(FMDatabase *db) {
        __block BOOL res = NO;
        res = [db executeStatements:[BSDatabaseVersion createSQL]];
        KSAssert(res);
        BSDatabaseVersion *dbVersion = [[BSDatabaseVersion queryModels] firstObject];
        if (!dbVersion) {
            dbVersion = [BSDatabaseVersion new];
            dbVersion.version = [NSNumber numberWithInt:DATABASE_VERSION];
            [BSDatabaseVersion addObject:dbVersion];
        }
        dbVersion = [[BSDatabaseVersion queryModels] firstObject];
        if (dbVersion.version.longLongValue != DATABASE_VERSION) {
            //TODO: 目前仅支持增加字段和删除表，不支持删除字段和修改字段
            BSMigrationService *migration = [BSMigrationService new];
            [migration startMigration];
            KSLog(@"database migration!");
        } else {
            KSLog(@"database version:%@", dbVersion.version);
        }
        
        [classes enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *statement =((NSString * (*)(id, SEL))(void *)objc_msgSend)(obj, @selector(createSQL));
            res = [db executeStatements:statement];
            KSAssert(res);
        }];
        return res;
    }];
}

+ (BOOL)isDBFileExist{
    return [FMDBModelManager isDBFileExist];
}

- (void)executeOperationWithBlock:(FmdbBlock)block{
    [self.dbManager executeOperationWithBlock:block];
}

- (void)executeOperationInTransaction:(NSArray<FmdbBlock> *)blocks{
    [self.dbManager executeOperationWithBlockInTransaction:blocks];
}

@end

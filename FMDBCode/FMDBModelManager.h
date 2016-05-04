//
//  FMDBModelManager.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 1/13/16.
//  Copyright © 2016 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>

//a db manager for Beach_Sun;

@class FMDatabase;
@class FMDatabaseQueue;

typedef BOOL (^FmdbBlock)(FMDatabase *db);

extern NSString *const kBSDBFileName;
extern NSString *const kBSDBFileNameSpace;

@interface FMDBModelManager : NSObject
@property (copy, nonatomic, readonly) NSString *dbPath;

+ (instancetype)sharedManager;
+ (instancetype)dbManager;

+ (BOOL)isDBFileExist;
- (void)executeOperationWithBlock:(FmdbBlock)block; //use this method sync do the db operation
- (void)executeOperationWithBlockInTransaction:(NSArray<FmdbBlock> *)blocks;
- (void)setup;
@end

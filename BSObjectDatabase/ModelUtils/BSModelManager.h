//
//  ModelManager.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/14/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSModelBlocks.h"

@class FMDatabase;
@class FMDatabaseQueue;
@class FMDBModelManager;

@interface BSModelManager : NSObject

@property (strong, nonatomic, readonly) FMDBModelManager *dbManager;
+ (instancetype)sharedManager;
+ (BOOL)isDBFileExist;

- (void)setupForClasses:(NSArray<Class> *)classes;
- (void)executeOperationWithBlock:(FmdbBlock)block; //use this method sync do the db operation
- (void)executeOperationInTransaction:(NSArray<FmdbBlock> *)blocks;
@end

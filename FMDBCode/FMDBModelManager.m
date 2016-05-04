//
//  FMDBModelManager.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 1/13/16.
//  Copyright © 2016 Beach Sun Team. All rights reserved.
//

#import "FMDBCode.h"

NSString *const kBSDBFileName = @"Beach_Sun.sqlite";
NSString *const kBSDBFileNameSpace = @"Beach_Sun_Object_Database";


@interface FMDBModelManager()
@property (strong, nonatomic) FMDatabaseQueue *fmdatabaseQueue;
@property (strong, nonatomic) FMDatabase *fmdatabase;
@property (copy, nonatomic, readwrite) NSString *dbPath;
@end

@implementation FMDBModelManager

+ (instancetype)sharedManager {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
        [manager setup];
    });
    return manager;
}

+ (instancetype)dbManager{
    FMDBModelManager *manager = [FMDBModelManager new];
    [manager setup];
    return manager;
}

- (void)setup {
    [self moveOldDBFileToGroupSpaceIfNeeded];
    
    self.dbPath = [self.class dbFilePath];
    NSLog(@"db:%@",self.dbPath);
    //init fmdb components
    self.fmdatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    __weak FMDBModelManager *weakSelf = self;
    [self.fmdatabaseQueue inDatabase:^(FMDatabase *db) {
        weakSelf.fmdatabase = db;
    }];
    [self.fmdatabaseQueue close];
}

- (void)moveOldDBFileToGroupSpaceIfNeeded{
    NSString *oldDBPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    oldDBPath = [oldDBPath stringByAppendingPathComponent:kBSDBFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:oldDBPath]
        && ![self.class isDBFileExist]){ //when update app
        BOOL re = [fileManager moveItemAtPath:oldDBPath toPath:[self.class dbFilePath] error:nil];
        if (re){
            NSLog(@"move db file success!");
        }else{
            NSLog(@"move db file failed! fatal error!!");
        }
    }
}

+ (NSString *)dbFilePath{
    /**
     *  存在 group :
     NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:AppGroupID];
     return [[groupURL URLByAppendingPathComponent:Beach_SunDBName] path];
     
     */
    return [self filePath];
}

+ (NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:kBSDBFileNameSpace];
}

+ (BOOL)isDBFileExist{
    NSString *path = [self dbFilePath];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void)executeOperationWithBlock:(FmdbBlock)block{
    if ([self.fmdatabaseQueue isNestedQueue]){
        if ([self.fmdatabase open])
            block(self.fmdatabase);
        else
            NSLog(@"can't open");
    }
    else{
        [self.fmdatabaseQueue inDatabase:^(FMDatabase *db){
            block(db);
        }];
        [self.fmdatabaseQueue close];
    }
}

- (void)executeOperationWithBlockInTransaction:(NSArray<FmdbBlock> *)blocks {
    if ([self.fmdatabaseQueue isNestedQueue]){
        NSLog(@"在一个自身的 db queue 里未退出，无法启动事务操作模式");
        if ([self.fmdatabase open]) {
            [blocks enumerateObjectsUsingBlock:^(FmdbBlock  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
                block(self.fmdatabase);
            }];
        }
        else {
            NSLog(@"can't open");
        }
    }
    else {
        [self.fmdatabaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [blocks enumerateObjectsUsingBlock:^(FmdbBlock  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL res = block(db);
                if (!res) {
                    *rollback = YES;
                    *stop = YES;
                }
            }];
        }];
        [self.fmdatabaseQueue close];
    }
}

@end

//
//  GroupSharedStore.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 1/15/16.
//  Copyright © 2016 Beach Sun Team. All rights reserved.
//

#import "GroupSharedStore.h"
#import "FMDBModelManager.h"

static NSString *const kTaskKey = @"task";
static NSString *const kAccountID = @"kAccountID";

@interface GroupSharedStore()
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@end

@implementation GroupSharedStore
+ (instancetype)sharedStore {
    static id store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[self alloc]init];
    });
    return store;
}

- (instancetype)init{
    self = [super init];
    if (!self)
        return self;
    self.userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kBSDBFileNameSpace];
    return self;
}

- (void)setCurrentAccountID:(NSNumber *)ID{
    [self.userDefaults setObject:ID forKey:kAccountID];
}

- (NSNumber *)currentAccountID{
    NSNumber *ID = [self.userDefaults objectForKey:kAccountID];
    return ID?ID:@(0);
}

@end

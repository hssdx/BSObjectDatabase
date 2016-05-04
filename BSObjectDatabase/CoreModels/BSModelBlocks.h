//
//  ModelBlocks.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/14/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#ifndef ModelBlocks_h
#define ModelBlocks_h
@class FMDatabase;
@class BSModelBase;

typedef void (^success)();
typedef void (^failure)(NSError *error);
typedef void (^FirstWechatOauth)(NSString *token);
typedef void (^FetchSuccess)(NSArray *objects);
typedef void (^RequestSuccess)(id responseObject);
typedef void (^InitModelBlock)(__kindof BSModelBase* model);
typedef void (^QueryModelBlock)(__kindof BSModelBase* model);
typedef BOOL (^FmdbBlock)(FMDatabase *db);

//weakSelf
#define WeakSelf  __weak __typeof__(self) weakSelf = self;

#endif /* ModelBlocks_h */

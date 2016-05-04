//
//  GroupSharedStore.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 1/15/16.
//  Copyright © 2016 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kTaskContentKey;
extern NSString *const kTaskRemindDateKey;
/**
 *  这个类用于存储共享数据，针对 iOS 8 新增的一些 extension 功能
 *  要求 FBDatabase 打包成动态库
 */
@interface GroupSharedStore : NSObject
+ (instancetype)sharedStore;

- (void)setCurrentAccountID:(NSNumber *)ID;
- (NSNumber *)currentAccountID;
@end

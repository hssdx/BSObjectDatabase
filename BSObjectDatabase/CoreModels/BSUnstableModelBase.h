//
//  UnstableModelBase.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/21/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSModelBase+Protect.h"

@interface BSUnstableModelBase : BSModelBase

@property (copy, nonatomic) NSNumber *dirty;
@property (copy, nonatomic) NSNumber *deleted;
@property (copy, nonatomic) NSString *UUID;

@end

@interface BSUnstableModelBase(Database)

+ (NSString*)rawUUID;
+ (void)markDeleteObjectLocalID:(NSNumber *)localID;
@end

@interface BSUnstableModelBase(Access)

- (void)setModelDirty:(BOOL)dirty;
- (BOOL)modelDirty;
- (void)setModelDeleted:(BOOL)deleted;
- (BOOL)modelDeleted;

@end

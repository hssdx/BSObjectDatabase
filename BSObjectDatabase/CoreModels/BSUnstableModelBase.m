//
//  UnstableModelBase.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/21/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSUnstableModelBase.h"

@implementation BSUnstableModelBase
@end

@implementation BSUnstableModelBase(Database)

+ (NSString*)rawUUID {
    NSString *uuid = nil;
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    uuid = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return uuid;
}

+ (NSDictionary *)keyMap {
    NSDictionary *sKeyMap = [super keyMap];
    NSMutableDictionary *result =
    [NSMutableDictionary dictionaryWithDictionary:@{@"dirty":@"",
                                                    @"deleted":@"",
                                                    @"UUID":@""}];
    [result addEntriesFromDictionary:sKeyMap];
    return result;
}

+ (void)markDeleteObjectLocalID:(NSNumber *)localID {
    BSUnstableModelBase *obj = [self queryModelWithLocalID:localID];
    if (obj) {
        [obj setModelDeleted:YES];
        [self addObject:obj];
    }
}
@end

@implementation BSUnstableModelBase(Access)

- (void)setModelDirty:(BOOL)dirty {
    self.dirty = [NSNumber numberWithBool:dirty];
}

- (BOOL)modelDirty {
    return self.dirty.boolValue;
}

- (void)setModelDeleted:(BOOL)deleted {
    self.deleted = [NSNumber numberWithBool:deleted];
}

- (BOOL)modelDeleted {
    return self.deleted.boolValue;
}

@end
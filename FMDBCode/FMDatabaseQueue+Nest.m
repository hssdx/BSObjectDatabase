//
//  FMDatabaseQueue+Nest.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 11/10/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "FMDatabaseQueue+Nest.h"

@implementation FMDatabaseQueue (Nest)

- (BOOL)isNestedQueue{
    FMDatabaseQueue *currentSyncQueue = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
    return currentSyncQueue == self;
}

@end

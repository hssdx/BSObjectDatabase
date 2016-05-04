//
//  FMDatabaseQueue+Nest.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 11/10/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "FMDatabaseQueue.h"

// use to judge if queue is nested

@interface FMDatabaseQueue (Nest)
- (BOOL)isNestedQueue;
@end

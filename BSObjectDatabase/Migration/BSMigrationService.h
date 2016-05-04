//
//  MigrationService.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 11/2/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATABASE_VERSION 1

@interface BSMigrationService : NSObject

- (void)startMigration;

@end

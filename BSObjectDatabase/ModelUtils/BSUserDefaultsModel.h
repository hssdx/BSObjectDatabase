//
//  KeyChainModel.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/18/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSUserDefaultsModel : NSObject

+ (instancetype)sharedModel;
/**
 *  temp
 */
/**
 *  defaults
 */
/**
 *  archive
 */
+ (void)archiveObject:(id)object withKey:(NSString *)key;
+ (id)unarchiveObjectWithKey:(NSString *)key;
@end

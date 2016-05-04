//
//  ModelBase+Protect.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 10/23/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSModelBase.h"

extern NSString *const kFieldNames;

@interface BSModelBase()
+ (NSDictionary *)tableDescribtion;
+ (BS_SQLCondition *)defaultExistCondition:(id)modelObj;
@end

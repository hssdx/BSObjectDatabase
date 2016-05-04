//
//  KeyChainModel.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/18/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BSUserDefaultsModel.h"
#import "FMDBCode.h"
#import "BSODUtilities.h"

#define UD_PROP_TO_STRING(PROP_NAME) [NSString stringWithFormat:@"WCUserDefault %@", PROP_TO_STRING(PROP_NAME)]

#define IMP_GETTER_SETTER(GETTER, SETTER) IMP_GETTER_SETTER_SETTER_EXTENSION(GETTER, SETTER, ;)

#define IMP_GETTER_SETTER_SETTER_EXTENSION(GETTER, SETTER, SETTER_EXTENSION) \
- (void)SETTER:(id)GETTER { \
_##GETTER = GETTER; \
[self.userDefaults setObject:_##GETTER forKey:UD_PROP_TO_STRING(GETTER)]; \
SETTER_EXTENSION \
} \
\
- (id)GETTER { \
if (!_##GETTER) { \
_##GETTER = [self.userDefaults objectForKey:UD_PROP_TO_STRING(GETTER)]; \
} \
return _##GETTER; \
}

@interface BSUserDefaultsModel()
@property (strong, nonatomic) NSDate *lastQueryEventsTimeForRollBack;
@end

@implementation BSUserDefaultsModel

+ (instancetype)sharedModel {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - archive
+ (void)archiveObject:(id)object withKey:(NSString *)key {
    NSString *documentPath = [self documentPathWithKey:key];
    [NSKeyedArchiver archiveRootObject:object toFile:documentPath];
}

+ (id)unarchiveObjectWithKey:(NSString *)key {
    NSString *documentPath = [self documentPathWithKey:key];
    id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:documentPath];
    return obj;
}

/* 获取Documents文件夹路径 */
+ (NSString *)documentPathWithKey:(NSString *)key {
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documents[0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:key];
    return filePath;
}

@end

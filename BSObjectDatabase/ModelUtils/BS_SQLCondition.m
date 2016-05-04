//
//  SQLCondition.m
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/23/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import "BS_SQLCondition.h"
#import "BSODUtilities.h"

/**
 *  条件查询允许传入一个dictionary,格式如下：
 {
 limit:{limitAt:idxV, limitCount:cntV}
 where:{[@{logicCode:$AND/$OR field:fname, value:vvalue}, ...]}
 }
 */
NSString *const kLimitKey = @"limit";
NSString *const kLimitAtKey = @"limitAt";
NSString *const kLimitCountKey = @"limitCount";
NSString *const kWhereKey = @"where";
NSString *const kWhereFieldKey = @"field";
NSString *const kWhereValueKey = @"value";
NSString *const kLogicCodeKey = @"logicCode";
NSString *const kOperationKey = @"operation";

NSString *const kAnd = @"AND";
NSString *const kOr = @"OR";
NSString *const kLeftBracket = @"(";
NSString *const kRightBracket = @")";
NSString *const kEqual = @"=";
NSString *const kNotEqual = @"<>";
NSString *const kGreater = @">";
NSString *const kLesser = @"<";
NSString *const kEqualOrGreater = @">=";
NSString *const kEqualOrLesser = @"<=";
NSString *const kBetween = @"BETWEEN";
NSString *const kLike = @"LIKE";
NSString *const kIs = @"IS";

@interface BS_SQLCondition()

@property (readwrite, strong, nonatomic) NSMutableDictionary *condition;

@end

@implementation BS_SQLCondition

- (instancetype)init {
    if (self = [super init]) {
        _condition = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)stringWithCompare:(SQLCompare)compare {
    NSString *cmpString;
    switch (compare) {
        case SQLCompareEqual:
            cmpString = kEqual;
            break;
        case SQLCompareNotEqual:
            cmpString = kNotEqual;
            break;
        case SQLCompareGreater:
            cmpString = kGreater;
            break;
        case SQLCompareLesser:
            cmpString = kLesser;
            break;
        case SQLCompareEqualOrGreater:
            cmpString = kEqualOrGreater;
            break;
        case SQLCompareEqualOrLesser:
            cmpString = kEqualOrLesser;
            break;
        case SQLCompareBetween:
            cmpString = kBetween;
            break;
        case SQLCompareLike:
            cmpString = kLike;
            break;
        case SQLCompareIs:
            cmpString = kIs;
            break;
    }
    return cmpString;
}

- (NSString *)stringWithLogic:(LogicCode)logic {
    NSString *logicString;
    switch (logic) {
        case LogicCodeNone:
            logicString = @"";
            break;
        case LogicCodeOr:
            logicString = kOr;
            break;
        case LogicCodeAnd:
            logicString = kAnd;
            break;
        case LogicCodeLeftBracket:
            logicString = kLeftBracket;
            break;
        case LogicCodeRightBracket:
            logicString = kRightBracket;
            break;
    }
    return logicString;
}

- (NSString *)getLimitSql {
    NSDictionary *limitDict = [self.condition objectForKey:kLimitKey];
    if ([limitDict count] == 0) {
        return @"";
    }
    NSString *limitSql = @"";
    NSNumber *atIndexNumber = [limitDict objectForKey:kLimitAtKey];
    NSNumber *countNumber = [limitDict objectForKey:kLimitCountKey];
    if (countNumber.intValue == 0) {
        return @"";
    }
    limitSql = [NSString stringWithFormat:@" limit %@,%@ ", atIndexNumber, countNumber];
    return limitSql;
}

- (NSString *)getWhereSql {
    NSMutableString *whereSql = [NSMutableString stringWithString:@""];
    NSArray *whereArray = [self.condition objectForKey:kWhereKey];
    if ([whereArray count] == 0) {
        return whereSql;
    }
    [whereSql appendFormat:@"where "];
    for (id obj in whereArray) {
        NSDictionary *whereDict = obj;
        NSString *logicCode = [whereDict objectForKey:kLogicCodeKey];
        NSString *whereField = [whereDict objectForKey:kWhereFieldKey];
        NSString *compareStr = [whereDict objectForKey:kOperationKey];
        id whereValue = [whereDict objectForKey:kWhereValueKey];
        
        if ([logicCode isEqualToString:kAnd] || [logicCode isEqualToString:kOr]) {
            [whereSql appendFormat:@" %@ ", logicCode];
        } else if ([logicCode isEqualToString:kLeftBracket] ||[logicCode isEqualToString:kRightBracket]) {
            [whereSql appendFormat:@"%@", logicCode];
        }
        if (whereField.length > 0) {
            if ([whereValue isKindOfClass:[NSString class]]) {
                [whereSql appendFormat:@" %@%@'%@' ", whereField, compareStr, whereValue];
            } else if ([whereValue isKindOfClass:[NSNumber class]]){
                [whereSql appendFormat:@" %@%@%@ ", whereField, compareStr, whereValue];
            } else if ([whereValue isKindOfClass:[NSNull class]]) {
                [whereSql appendFormat:@" %@ %@ NULL ", whereField, compareStr];
            } else {
                KSAssert(false);
            }
        }
    }
    return whereSql;
}

#pragma mark - public func
+ (instancetype)SQLConditionWithCondition:(BS_SQLCondition *)aCondition {
    BS_SQLCondition *condition = [[BS_SQLCondition alloc] init];
    condition.orderSQL = aCondition.orderSQL;
    condition.condition = [aCondition.condition copy];
    return condition;
}

- (void)reset {
    self.condition = [NSMutableDictionary dictionary];
    self.orderSQL = nil;
}

- (void)setLimitFrom:(NSUInteger)atIndex limitCount:(NSUInteger)limitCount {
    NSNumber *atIndexNumber = [NSNumber numberWithUnsignedInteger:atIndex];
    NSNumber *limitCntNumber = [NSNumber numberWithUnsignedInteger:limitCount];
    self.condition[kLimitKey] = @{kLimitAtKey:atIndexNumber,
                                  kLimitCountKey:limitCntNumber};
}

- (void)addLogicCode:(LogicCode)logicCode {
    [self addWhereField:@"" compare:SQLCompareEqual value:@"" logicCode:logicCode];
}

- (void)addWhereField:(NSString *)field
              compare:(SQLCompare)compare
                value:(id)value
            logicCode:(LogicCode)logicCode {
    if (!field || !value) {
        return;
    }
    
    NSMutableArray *whereArray = self.condition[kWhereKey];
    if (NO == [whereArray isKindOfClass:[NSMutableArray class]]) {
        whereArray = [NSMutableArray array];
        self.condition[kWhereKey] = whereArray;
    }
    NSString *cmpString = [self stringWithCompare:compare];
    NSString *logicString = @"";
    if ([whereArray count] > 0 || (logicCode != LogicCodeOr && logicCode != LogicCodeAnd)) {
        logicString = [self stringWithLogic:logicCode];
    }
    [whereArray addObject:@{kLogicCodeKey:logicString,
                            kWhereFieldKey:field,
                            kOperationKey:cmpString,
                            kWhereValueKey:value}];
}

- (NSString *)conditionSQL {
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:[self getWhereSql]];
    if ([[self orderSQL] length] > 0) {
        [sql appendString:@" ORDER BY "];
        [sql appendString:[self orderSQL]];
    }
    [sql appendString:[self getLimitSql]];
    return sql;
}

- (NSString *)whereAndLimitSQL {
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:[self getWhereSql]];
    [sql appendString:[self getLimitSql]];
    return sql;
}

@end

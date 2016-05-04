//
//  SQLCondition.h
//  Beach_Sun
//
//  Created by Beach_Sun_Team on 9/23/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LogicCode) {
    LogicCodeNone,
    LogicCodeAnd,
    LogicCodeOr,
    LogicCodeLeftBracket,
    LogicCodeRightBracket,
};

typedef NS_ENUM(NSInteger, SQLCompare) {
    SQLCompareEqual,
    SQLCompareNotEqual,
    SQLCompareGreater,
    SQLCompareLesser,
    SQLCompareEqualOrGreater,
    SQLCompareEqualOrLesser,
    SQLCompareBetween,
    SQLCompareLike,
    SQLCompareIs,
};

@interface BS_SQLCondition : NSObject

@property (copy, nonatomic) NSString *orderSQL;
@property (readonly, strong, nonatomic) NSMutableDictionary *condition;

+ (instancetype)SQLConditionWithCondition:(BS_SQLCondition *)condition;

- (void)reset;
- (void)setLimitFrom:(NSUInteger)atIndex limitCount:(NSUInteger)limitCount;
- (void)addLogicCode:(LogicCode)logicCode;
- (void)addWhereField:(NSString *)field compare:(SQLCompare)compare value:(id)value logicCode:(LogicCode)logicCode;
- (NSString *)conditionSQL;
- (NSString *)whereAndLimitSQL;

@end

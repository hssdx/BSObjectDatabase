//
//  BSODUtilities.h
//  BSOD
//
//  Created by Beach_Sun_Team on 9/16/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#ifndef BSODUtilities_h
#define BSODUtilities_h

#pragma mark -- DEBUG --

// DebugBreak()
#if TARGET_IPHONE_SIMULATOR

// simulator
#define DebugBreak() kill(getpid(),SIGINT)

#else // TARGET_IPHONE_SIMULATOR

// device
#define DebugBreak() kill(getpid(),SIGINT)

#endif // TARGET_IPHONE_SIMULATOR

// assert()
#undef KSAssert

#if DEBUG
void assert_output(const char * szFunction, const char *szFile, int nLine, const char *szExpression);
#define KSAssert(e) (!(e) ? assert_output(__func__, __FILE__, __LINE__, #e) : (void)0)
#else
#define KSAssert(e) (void)0
#endif

#if DEBUG
#define KSRequiredCast(id, _class) (id ? KSAssert([(id) isKindOfClass:[_class class]]), ((_class*)id) : ((_class*)id))
#else
#define KSRequiredCast(id, _class) ((_class*)id)
#endif

#define KSTryCast(id, _class) [(id) isKindOfClass:[_class class]] ? ((_class*)id) : nil;

#if DEBUG
#define KSLog(...) NSLog(__VA_ARGS__)
#define KSLog_Release(...) NSLog(__VA_ARGS__)
#define KSLogForFrame(frame)  KSLog(@"%s %s%@",__PRETTY_FUNCTION__,#frame,NSStringFromCGRect(frame))
#else
#define KSLog(...) (void)0
#define KSLogForFrame(frame) (void)0
#define KSLog_Release(...) [[PowerWordUtilities  utils] appendLog:[NSString stringWithFormat:__VA_ARGS__]]
#endif


#define PROP_TO_STRING(PROP_NAME) \
NSStringFromSelector(@selector(PROP_NAME))

#endif /* Beach_SunUtilities_h */


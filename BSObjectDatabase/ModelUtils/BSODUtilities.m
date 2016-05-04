//
//  BSODUtilities.m
//  BSOD
//
//  Created by Beach_Sun_Team on 9/16/15.
//  Copyright © 2015 Beach Sun Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSODUtilities.h"

#if DEBUG

void assert_output(const char * szFunction, const char *szFile, int nLine, const char *szExpression)
{
    printf("Assert failure: %s at %s %s:%d\n", szExpression, szFunction, szFile, nLine);
    DebugBreak();
}

#endif

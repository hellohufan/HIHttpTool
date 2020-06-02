#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HIHttpManager.h"
#import "HIHttpTool.h"
#import "HIHttpToolConfig.h"

FOUNDATION_EXPORT double HIHttpToolVersionNumber;
FOUNDATION_EXPORT const unsigned char HIHttpToolVersionString[];


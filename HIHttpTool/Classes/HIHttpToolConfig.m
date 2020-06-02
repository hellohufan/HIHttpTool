//
//  HIHttpToolConfig.m
//  HIHttpTool
//
//  Created by hufan on 2020/6/2.
//

#import "HIHttpToolConfig.h"

@implementation HIHttpToolConfig
+ (HIHttpToolConfig *)shareInstace {
    static dispatch_once_t once;
    static HIHttpToolConfig *instance;
    dispatch_once(&once, ^{
        instance = [[HIHttpToolConfig alloc] init];
        instance.timeoutInterval = 30.f;
        instance.authorization = @"";
    });
    return instance;
}
@end

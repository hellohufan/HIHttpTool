//
//  HIHttpManager.m
//  HIHttpTool
//
//  Created by hufan on 2020/6/2.
//

#import "HIHttpManager.h"

@implementation HIHttpManager

+ (instancetype)manager {
    HIHttpManager *manager = [super manager];
    NSMutableSet *newSet = [NSMutableSet set];
    newSet.set = manager.responseSerializer.acceptableContentTypes;
    [newSet addObject:@"text/html"];
    [newSet addObject:@"text/plain"];
    [newSet addObject:@"text/json"];
    [newSet addObject:@"application/javascript"];
    if ([HIHttpToolConfig shareInstace].authorization.length > 0) {
        [manager.requestSerializer setValue:[HIHttpToolConfig shareInstace].authorization forHTTPHeaderField:@"Authorization"];
    }
    manager.responseSerializer.acceptableContentTypes = newSet;
    return manager;
}

@end

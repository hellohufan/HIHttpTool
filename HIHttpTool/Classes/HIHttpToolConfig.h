//
//  HIHttpToolConfig.h
//  HIHttpTool
//
//  Created by hufan on 2020/6/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HIHttpToolConfig : NSObject

+ (HIHttpToolConfig *)shareInstace;

// 默认超时时间 30s
@property (nonatomic, assign) CGFloat timeoutInterval;

@property (nonatomic, copy) NSString *authorization;

@end

NS_ASSUME_NONNULL_END

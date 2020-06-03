//
//  HIHttpTool.h
//  HIHttpTool
//
//  Created by IVAN on 2019/1/24.
//  Copyright © 2019 IVAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HIHttpManager.h"

typedef NS_ENUM(NSInteger, HINetworkReachabilityStatus) {
    HINetworkReachabilityStatusUnknown          = -1,
    HINetworkReachabilityStatusNotReachable     = 0,
    HINetworkReachabilityStatusReachableViaWWAN = 1,
    HINetworkReachabilityStatusReachableViaWiFi = 2,
};

typedef void (^HIHTCallBack)(void);
typedef void (^HIHTCallBackProgress)(CGFloat progress);
typedef void (^HIHTCallBackNeworktStatus)(HINetworkReachabilityStatus status);

typedef void (^HIHTCallBackSuccess)(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable JSON);
typedef void (^HIHTCallBackFail)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
typedef void (^HIHTCallBackURL)(NSURL *_Nullable url);

#define HIHT_Log(FORMAT, ...) fprintf(stderr, "【%s】 %s ‖ 〖LINE:%li〗MESSAGE:\n%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __PRETTY_FUNCTION__, (long)__LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);

#define HIHT_GCD_AFTER(sec,afterQueueBlock) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(),afterQueueBlock);
//GCD - 一次性
#define HIHT_GCD_ONCE(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);
//GCD - 主线程
#define HIHT_GCD_MAIN(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);
//GCD - 后台
//#define HIHT_GCD_BACK(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);


@interface HIHttpTool : NSObject

/**
 设置超过时间
 
 @NOTE 默认30秒
 */
+ (void)setupTimeoutInterval:(CGFloat)timeoutInterval;

/**
 设置鉴权字段
 
 */
+(void)setupAuthorization:(NSString *_Nonnull)authorization;
    
/**
POST网络请求

@param url  URL 字符串，用来创建 request URL.
@param parameters 请求参数字典
@param success 返回成功回调
@param failure 返回失败回调

*/
+ (HIHttpManager *_Nonnull)POST:(nonnull NSString *)url
                         params:(nullable NSDictionary *)parameters
                        success:(nullable HIHTCallBackSuccess)success
                        failure:(nullable HIHTCallBackFail)failure;

/**
GET网络请求

@param url  URL 字符串，用来创建 request URL.
@param parameters 请求参数字典
@param success 返回成功回调
@param failure 返回失败回调

*/
+ (HIHttpManager *_Nonnull)GET:(nonnull NSString *)url
                        params:(nullable NSDictionary *)parameters
                       success:(nullable HIHTCallBackSuccess)success
                       failure:(nullable HIHTCallBackFail)failure;

/**
下载网络文件

@param url  URL 字符串，用来创建 request URL.
@param progress 下载过程BLock，主线程调用。
@param success 返回成功Block
@param failure 返回失败回调

*/
+ (HIHttpManager *_Nonnull)downFile:(nonnull NSString *)url
                           progress:(nullable HIHTCallBackProgress)progress
                            success:(HIHTCallBackURL _Nullable )success
                            failure:( HIHTCallBackFail _Nullable )failure;

/**
上传图片

@param url  URL 字符串，用来创建 request URL.
@param parameters 参数
@param image 图片
@param key 对应的key
@param progress 上传过程Block，主线程调用
@param success 返回成功回调
@param failure 返回失败回调

*/
+ (HIHttpManager *_Nonnull)uploadPhoto:(nonnull NSString*)url
                                params:(nullable NSDictionary *)parameters
                                 image:(nonnull UIImage*)image
                                   key:(nonnull NSString*)key
                              progress:(HIHTCallBackProgress _Nullable)progress
                               success:(HIHTCallBackSuccess _Nullable)success
                               failure:(HIHTCallBackFail _Nullable)failure;

/**
监视网络连接情况

@param connected 连接回调
@param lost 断开失去网络连接回调
 
@see HIHTCallBackNeworktStatus
*/
+ (void)starMonitoring:(HIHTCallBackNeworktStatus _Nonnull )connected lost:(HIHTCallBack _Nullable )lost;

@end

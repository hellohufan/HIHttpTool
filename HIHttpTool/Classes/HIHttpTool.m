//
//  HIHttpTool.m
//  HIHttpTool
//
//  Created by IVAN on 2019/1/24.
//  Copyright © 2019 IVAN. All rights reserved.
//

#import "HIHttpTool.h"
#import <AFNetworking/AFNetworking.h>

@implementation HIHttpTool

+(void)setupTimeoutInterval:(CGFloat)timeoutInterval {
    [HIHttpToolConfig shareInstace].timeoutInterval = timeoutInterval;
}

+(void)setupAuthorization:(NSString *)authorization {
    [HIHttpToolConfig shareInstace].authorization = authorization;
}

+(CGFloat)timeoutInterval {
    return [HIHttpToolConfig shareInstace].timeoutInterval;
}

+(NSString *)authorization {
    return [HIHttpToolConfig shareInstace].authorization;
}

+ (HIHttpManager *)POST:(nonnull NSString *)url
      params:(nullable NSDictionary *)parameters
     success:(nullable HIHTCallBackSuccess)success
     failure:(nullable HIHTCallBackFail)failure{
    
    NSAssert(url.length > 0, @"URL Can Not Be Empty");
    HIHttpManager *manager = [HIHttpManager manager];
    manager.requestSerializer.timeoutInterval = [HIHttpTool timeoutInterval];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if(success){
            [HIHttpTool success:success json:responseObject task:task];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failure){
            [HIHttpTool failure:failure error:error task:task];
        }
    }];
    return manager;
}

// GET请求
+ (HIHttpManager *_Nonnull)GET:(nonnull NSString *)url
                        params:(nullable NSDictionary *)parameters
                       success:(nullable HIHTCallBackSuccess)success
                       failure:(nullable HIHTCallBackFail)failure {
    HIHT_Log(@"url.lendth = %lu", (unsigned long)url.length);
    NSAssert(url.length > 0, @"URL Can Not Be Empty");
    HIHttpManager *manager = [HIHttpManager manager];
    manager.requestSerializer.timeoutInterval = [HIHttpTool timeoutInterval];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if(success){
            [HIHttpTool success:success json:responseObject task:task];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failure){
            [HIHttpTool failure:failure error:error task:task];
        }
    }];
    return manager;
}

// 下载文件
+ (HIHttpManager *_Nonnull)downFile:(NSString *)url
                           progress:(HIHTCallBackProgress)progress
                            success:(HIHTCallBackURL)success
                            failure:(HIHTCallBackFail)failure {
    NSAssert(url.length > 0, @"URL Can Not Be Empty");
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    HIHttpManager *manager = [HIHttpManager manager];
    if (!request){
        return manager;
    }
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress){
            HIHT_GCD_MAIN(^{
                progress(downloadProgress.fractionCompleted);
            });
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *downloadPath = [[self getDocumentPath]
                                 stringByAppendingPathComponent:@"Download"];
        NSString *filePath     = [downloadPath stringByAppendingPathComponent:response.suggestedFilename];
        BOOL isExitDownloadDir = [self creatDirectoryWithPath:downloadPath];
        
        //存在文件就删除
        BOOL isFileExist = [self fileIsExistOfPath:filePath];
        if (isFileExist) {
            [self removeFileOfPath:filePath];
        }
        
        if (isExitDownloadDir) {
            return [NSURL fileURLWithPath:filePath];
        }
        return [NSURL fileURLWithPath:@""];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        // 完成
        if (error)[self failure:nil error:error task:nil];
        if (success) {
            success(filePath);
        }
    }];
    [task resume];
    return manager;
}

// 上传图片
+ (HIHttpManager *_Nonnull)uploadPhoto:(NSString*)url
            params:(NSDictionary *)params
             image:(UIImage*)image
               key:(NSString*)key
          progress:(HIHTCallBackProgress)progress
           success:(HIHTCallBackSuccess)success
           failure:(HIHTCallBackFail)failure {
    NSAssert(url.length > 0, @"URL Can Not Be Empty");
    HIHttpManager *manager = [HIHttpManager manager];
    manager.requestSerializer.timeoutInterval = [HIHttpTool timeoutInterval];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *fileName =[NSString stringWithFormat:@"Photo%@.png",[HIHttpTool rts]];
        NSString *type = @"image/png";
        [formData appendPartWithFileData:[HIHttpTool zipImage:image] name:key fileName:fileName mimeType:type];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress){
            HIHT_GCD_MAIN(^{
                progress(uploadProgress.fractionCompleted);
            });
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if(success){
            [HIHttpTool success:success json:responseObject task:task];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failure){
            [HIHttpTool failure:failure error:error task:task];
        }
    }];
    return manager;
}

// 网络检测
+ (void)starMonitoring:(HIHTCallBackNeworktStatus)connected lost:(HIHTCallBack)lost {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                // ...
                break;
            case AFNetworkReachabilityStatusNotReachable:
                if (lost) {
                    lost();
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                if (connected) {
                    connected(HINetworkReachabilityStatusReachableViaWWAN);
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if (connected) {
                    connected(HINetworkReachabilityStatusReachableViaWiFi);
                }
                break;
            default:
                break;
        }
    }];
}

#pragma mark - 私有方法
+ (NSDictionary *)deleteNull:(NSDictionary*)dict {
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
    for (NSString *keyStr in dict.allKeys)
        if ([dict[keyStr] isEqual:[NSNull null]]) {
            NSString *key = [keyStr stringByReplacingOccurrencesOfString:@"_" withString:@""];
            [mutableDic setObject:@"" forKey:key];
        } else {
            NSString *key = [keyStr stringByReplacingOccurrencesOfString:@"_" withString:@""];
            [mutableDic setObject:dict[keyStr] forKey:key];
        }
    return (NSDictionary*)mutableDic;
}

+ (void)success:(HIHTCallBackSuccess)success json:(NSDictionary *)json task:(NSURLSessionDataTask *)task{
    json = [self deleteNull:json];
    if (success) {
        success(task, json);
    }
}

+ (void)failure:(HIHTCallBackFail)failure error:(NSError *)error task:(NSURLSessionDataTask *)task{
    NSString *errorMessage = [error localizedDescription];
    HIHT_Log(@"网络请求失败 -> 错误原因: %@", errorMessage);
    if (failure){
        failure(task, error);
    }
}

+(NSData *)zipImage:(UIImage *)myimage {
    NSData *data = UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length > 100*1024) {
        if (data.length > 2*1024*1024) {//2M以及以上
            data = UIImageJPEGRepresentation(myimage, 0.05);
        }else if (data.length > 1024*1024) {//1M-2M
            data = UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length > 512*1024) {//0.5M-1M
            data = UIImageJPEGRepresentation(myimage, 0.2);
        }else if (data.length > 200*1024) {//0.25M-0.5M
            data = UIImageJPEGRepresentation(myimage, 0.4);
        }
    }
    return data;
}

+(NSString *)rts{
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd-HHmmss"];
    format.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    NSString*chinaString = [format stringFromDate:date];
    NSDateFormatter *chinaFormat = [[NSDateFormatter alloc] init];
    [chinaFormat setDateFormat:@"yyyyMMdd-HHmmss"];
    NSDate *chinaDate = [chinaFormat dateFromString:chinaString];
    NSTimeInterval time = [chinaDate timeIntervalSince1970];
    return [NSString stringWithFormat:@"%d",(int)time];
}

#pragma mark - 文件操作

+ (BOOL)fileIsExistOfPath:(NSString *)filePath{
    BOOL flag = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        flag = YES;
    } else {
        flag = NO;
    }
    return flag;
}

+ (BOOL)removeFileOfPath:(NSString *)filePath{
    BOOL flag = YES;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:filePath]) {
        if (![fileManage removeItemAtPath:filePath error:nil]) {
            flag = NO;
        }
    }
    return flag;
}

+ (NSString *)getDocumentPath{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [filePaths lastObject];
}

+(BOOL)creatDirectoryWithPath:(NSString *)dirPath{
    BOOL ret = YES;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:dirPath];
    if (!isExist) {
        NSError *error;
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!isSuccess) {
            ret = NO;
            NSLog(@"creat Directory Failed. errorInfo:%@",error);
        }
    }
    return ret;
}

@end

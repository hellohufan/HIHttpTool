//
//  HIHttpManager.m
//  HIHttpTool
//
//  Created by hufan on 2020/6/2.
//

#import "HIHttpManager.h"

//请求方式
typedef NS_ENUM(NSUInteger, NetRequestMethodType) {
    NetRequestMethodTypeGet,
    NetRequestMethodTypePost,
    NetRequestMethodTypePut,
    NetRequestMethodTypeDelete,
    NetRequestMethodTypePatch,
    NetRequestMethodTypeHead
};

//数据解析类型
typedef NS_ENUM(NSUInteger, NetResponseSerializerType) {
    NetResponseSerializerTypeDefault,//默认类型 JSON
    NetResponseSerializerTypeJson,//JSON
    NetResponseSerializerTypeXml,//XML
    NetResponseSerializerTypePlist,//Pist
    NetResponseSerializerTypeCompound,//Compound
    NetResponseSerializerTypeImage,//image
    NetResponseSerializerTypeData//二进制
};

@implementation HIHttpManager

+ (instancetype)manager {
    HIHttpManager *manager = [super manager];
    NSMutableSet *newSet = [NSMutableSet set];
    newSet.set = manager.responseSerializer.acceptableContentTypes;
    [newSet addObject:@"text/html"];
    [newSet addObject:@"text/plain"];
    [newSet addObject:@"text/json"];
    [newSet addObject:@"application/javascript"];
    manager.responseSerializer.acceptableContentTypes = newSet;
    if ([HIHttpToolConfig shareInstace].authorization.length > 0) {
        [manager.requestSerializer setValue:[HIHttpToolConfig shareInstace].authorization forHTTPHeaderField:@"Authorization"];
    }
    return manager;
}

+ (AFHTTPResponseSerializer *)netResponseSerializerWithSerializerType:(NetResponseSerializerType)serializerType {
    switch (serializerType) {
        case NetResponseSerializerTypeDefault: return [AFJSONResponseSerializer serializer]; break;
        case NetResponseSerializerTypeJson: return [AFJSONResponseSerializer serializer]; break;
        case NetResponseSerializerTypeXml: return [AFXMLParserResponseSerializer serializer]; break;
        case NetResponseSerializerTypePlist: return [AFPropertyListResponseSerializer serializer]; break;
        case NetResponseSerializerTypeCompound: return [AFCompoundResponseSerializer serializer]; break;
        case NetResponseSerializerTypeImage: return [AFImageResponseSerializer serializer]; break;
        case NetResponseSerializerTypeData: return [AFHTTPResponseSerializer serializer]; break;
        default: return [AFJSONResponseSerializer serializer]; break;
    }
}
@end

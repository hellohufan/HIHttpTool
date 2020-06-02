//
//  HIViewController.m
//  HIHttpTool
//
//  Created by hellohufan on 05/31/2020.
//  Copyright (c) 2020 hellohufan. All rights reserved.
//

#import "HIViewController.h"
#import "HIHttpTool.h"

#define HDLog(FORMAT, ...) fprintf(stderr, "【%s】 %s ‖ 〖LINE:%li〗【MESSAGE】:\n%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __PRETTY_FUNCTION__, (long)__LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);

@interface HIViewController ()

@end

@implementation HIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self http];
}

- (void)http{
    NSString *url = @"https://www.baifubao.com/";
    NSDictionary *parameters = @{@"phone": @"18659152700", @"callback": @"phone", @"cmd": @"1059"};
    [HIHttpTool GET:url params:parameters success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable JSON) {
        HDLog(@"json = %@", JSON);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HDLog(@"Error = %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

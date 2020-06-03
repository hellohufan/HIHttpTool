//
//  HIViewController.m
//  HIHttpTool
//
//  Created by hellohufan on 05/31/2020.
//  Copyright (c) 2020 hellohufan. All rights reserved.
//

#import "HIViewController.h"
#import "HIHttpTool.h"

#define HIHTLog(FORMAT, ...) fprintf(stderr, "【%s】 %s ‖ 〖LINE:%li〗【MESSAGE】:\n%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __PRETTY_FUNCTION__, (long)__LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);

@interface HIViewController ()

@property (nonatomic, strong) IBOutlet UITextView *textView;

@end

@implementation HIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self httpGet];
    [self httpPost];
}

- (void)httpGet{
    NSString *url = @"https://api.apiopen.top/getJoke";
    NSDictionary *parameters = @{@"page": @"1", @"count": @"2", @"type": @"video"};
    [HIHttpTool GET:url params:parameters success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable JSON) {
        HIHTLog(@"json = %@", JSON);
        self.textView.text = [NSString stringWithFormat:@"GET JSON = \n%@\n%@", self.textView.text, JSON];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HIHTLog(@"Error = %@", error);
        self.textView.text = [NSString stringWithFormat:@"GET ERROR = \n%@\n%@", self.textView.text, error];
    }];
}

- (void)httpPost{
    NSString *url = @"https://api.apiopen.top/getWangYiNews";
    NSDictionary *parameter = @{};
    [HIHttpTool POST:url params:parameter success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable JSON) {
        HIHTLog(@"JSON = %@", JSON);
        self.textView.text = [NSString stringWithFormat:@"POST JSON = \n %@\n%@", self.textView.text, JSON];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HIHTLog(@"error = %@", error);
        self.textView.text = [NSString stringWithFormat:@"POST ERROR = \n %@\n%@", self.textView.text, error];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

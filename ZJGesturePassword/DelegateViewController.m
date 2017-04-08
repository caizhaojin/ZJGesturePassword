//
//  DelegateViewController.m
//  ZJGesturePassword
//
//  Created by Choi on 2017/3/31.
//  Copyright © 2017年 CZJ. All rights reserved.
//

#import "DelegateViewController.h"
#import "ZJGesturePassword.h"

@interface DelegateViewController ()<ZJGesturePasswordDelegate>

@end

@implementation DelegateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Delegate";
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.center = self.view.center;
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn addTarget:self action:@selector(showGesturePassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
}
- (void)showGesturePassword
{
    ZJGesturePassword *gesturePwd = [[ZJGesturePassword alloc] init];
    gesturePwd.delegate = self;
    [gesturePwd show];
    
    //[self.view addSubview:gesturePwd];
}


- (void)zjGesturePassword:(ZJGesturePassword *)zjGesturePassword password:(NSString *)password
{
    if ([password isEqualToString:@"123"]) {
        [zjGesturePassword reset];
    } else {
        [zjGesturePassword setError];
    }
    
    NSLog(@"Delegate - password  %@",password);
}
@end

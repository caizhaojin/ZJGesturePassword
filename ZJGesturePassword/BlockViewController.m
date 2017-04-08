//
//  BlockViewController.m
//  ZJGesturePassword
//
//  Created by Choi on 2017/3/31.
//  Copyright © 2017年 CZJ. All rights reserved.
//

#import "BlockViewController.h"
#import "ZJGesturePassword.h"

@interface BlockViewController ()

@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Block";
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.center = self.view.center;
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor darkGrayColor];
    [btn addTarget:self action:@selector(showGesturePassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}
- (void)showGesturePassword
{
    ZJGesturePassword *gesturePwd = [[ZJGesturePassword alloc] init];
    
    [gesturePwd show];
    
    //[self.view addSubview:gesturePwd];
    
    // 弱引用 - 在block调用self的时候，必须引用，否则无法销毁
    //__weak typeof(self) weakSelf = self;
    [gesturePwd setCompleteAction:^(ZJGesturePassword *zjGesturePassword ,NSString *password){
        
        if ([password isEqualToString:@"123"]) {
            [zjGesturePassword setError];
        }
        
        if ([password isEqualToString:@"14789"]) {
            [zjGesturePassword reset];
        }
        NSLog(@"Block - password %@",password);
    }];
}



@end

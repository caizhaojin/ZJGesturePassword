//
//  ZJGesturePassword.h
//  ZJGesturePassword
//
//  Created by Choi on 2017/3/31.
//  Copyright © 2017年 CZJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJGesturePassword;

@protocol ZJGesturePasswordDelegate <NSObject>

- (void)zjGesturePassword:(ZJGesturePassword *)zjGesturePassword password:(NSString *)password;

@end

@interface ZJGesturePassword : UIView

@property (weak, nonatomic) id <ZJGesturePasswordDelegate> delegate;

@property (copy, nonatomic) void(^completeAction)(ZJGesturePassword *zjGesturePassword ,NSString *password);

- (void)reset;
- (void)setError;

- (void)show;

@end


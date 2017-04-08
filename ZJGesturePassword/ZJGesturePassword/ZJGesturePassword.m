//
//  ZJGesturePassword.m
//  ZJGesturePassword
//
//  Created by Choi on 2017/3/31.
//  Copyright © 2017年 CZJ. All rights reserved.
//

#import "ZJGesturePassword.h"

typedef NS_ENUM(NSInteger, ZJPointState) {
    ZJPointStateNormal,
    ZJPointStateSelect
};


#pragma mark - 点模型
@interface ZJPoint : NSObject

@property (nonatomic) ZJPointState state;
@property (nonatomic) NSInteger index;
@property (nonatomic) CGPoint center;

@end

@implementation ZJPoint
@end


@protocol ZJGesturePasswordViewDelegate <NSObject>

- (void)zjGesturePassword:(NSString *)password;

@end

@interface ZJGesturePasswordView : UIView

@property (weak, nonatomic) id <ZJGesturePasswordViewDelegate> viewDelegate;

@property (strong, nonatomic) NSMutableArray *points;
@property (strong, nonatomic) NSMutableArray *selectPoints;

@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) CGFloat diameter;
@property (nonatomic) CGFloat radius;

@property (nonatomic) BOOL isError;
@property (nonatomic) CGFloat tintAlpha;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGFloat circleLineWidth;
/** default 0.3, max 1.0 */
@property (nonatomic) CGFloat smallCircleRatio;


@property (strong, nonatomic) UIColor *normalTintColor;
@property (strong, nonatomic) UIColor *selectTintColor;
@property (nonatomic, strong) UIColor *errorTintColor;
@end

@implementation ZJGesturePasswordView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setupGesturePassword];
    }
    return self;
}
- (void)setupGesturePassword
{
    self.backgroundColor = [UIColor clearColor];
    
    _lineWidth = 3;
    _circleLineWidth = 2;
    _tintAlpha = 0.4f;
    _smallCircleRatio = 0.3;
    _normalTintColor = [UIColor whiteColor];
    _selectTintColor = [UIColor whiteColor];
    _errorTintColor = [UIColor redColor];
    
    _points = [NSMutableArray array];
    _selectPoints = [NSMutableArray array];
    
    for (int i = 0; i < 9; i ++) {
        
        ZJPoint * point = [[ZJPoint alloc] init];
        point.state = ZJPointStateNormal;
        point.index = i;
        
        [_points addObject:point];
    }
}

- (void)dealloc
{
    NSLog(@"ZJGesturePasswordView");
}
#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *oneTouch = [touches anyObject];
    CGPoint point = [oneTouch locationInView:self];
    
    [self resetGesturePasswordView];
    
    _currentPoint = point;
    
    for (ZJPoint *zjPoint in _points) {
        if ([self distanceFromPoint:_currentPoint toPoint:zjPoint.center] < _radius) {
            zjPoint.state = ZJPointStateSelect;
            if (![_selectPoints containsObject:zjPoint]) {
                [_selectPoints addObject:zjPoint];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *oneTouch = [touches anyObject];
    CGPoint point = [oneTouch locationInView:self];
    _currentPoint = point;
    
    for (ZJPoint *zjPoint in _points) {
        
        if ([self distanceFromPoint:_currentPoint toPoint:zjPoint.center] < _radius) {
            
            if (![_selectPoints containsObject:zjPoint]) {
                zjPoint.state = ZJPointStateSelect;
                [_selectPoints addObject:zjPoint];
            }
            break;
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self outputPwd];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self outputPwd];
    [self setNeedsDisplay];
}
#pragma mark - Method
- (CGFloat)distanceFromPoint:(CGPoint)start toPoint:(CGPoint)end {
    
    CGFloat distance;
    //下面就是高中的数学，不详细解释了
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    return distance;
}
- (void)outputPwd {
    
    ZJPoint *zjPoint = [_selectPoints lastObject];
    _currentPoint = zjPoint.center;
    
    //获取结果
    NSMutableString *pwd = [[NSMutableString alloc]initWithCapacity:0];
    for (int i = 0; i < _selectPoints.count; i ++) {
        ZJPoint *zjPoint = _selectPoints[i];
        [pwd appendFormat:@"%@", @(zjPoint.index+1)];
    }
    
    if ([self.viewDelegate respondsToSelector:@selector(zjGesturePassword:)]) {
        [self.viewDelegate zjGesturePassword:pwd];
    }
}
- (void)resetGesturePasswordView
{
    _isError = NO;
    
    for (ZJPoint *point in _selectPoints) {
        point.state = ZJPointStateNormal;
    }
    [_selectPoints removeAllObjects];
    [self setNeedsDisplay];
    
}
- (void)setErrorGesturePasswordView;
{
    _isError = YES;
    [self setNeedsDisplay];
}
#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    
    [self drawLine:rect];
    [self drawPoint:rect];
    
}

- (void)drawPoint:(CGRect)rect {
    
    float interval = (MIN(rect.size.width, rect.size.height)) / 13;
    _diameter = interval * 3;
    _radius = _diameter * 0.5f;
    
    
    for (int i = 0; i < 9; i ++) {
        
        int row = i / 3;
        int list = i % 3;
        
        
        CGRect frame = CGRectMake(list * ( interval + _diameter ) + interval,
                                  row * ( interval + _diameter ) + interval,
                                  _diameter,
                                  _diameter);
        
        
        ZJPoint * zjPoint = [_points objectAtIndex:i];
        zjPoint.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        
        
        //大圆
        {
            switch (zjPoint.state) {
                case ZJPointStateNormal:
                    [[UIColor clearColor] setFill];
                    break;
                case ZJPointStateSelect:
                    if (_isError) {
                        [[_errorTintColor colorWithAlphaComponent:_tintAlpha] setFill];
                    } else {
                        [[_selectTintColor colorWithAlphaComponent:_tintAlpha] setFill];
                    }
                    break;
            }
            
            CGContextFillEllipseInRect(context, CGRectMake(zjPoint.center.x - _radius,
                                                           zjPoint.center.y - _radius,
                                                           _diameter,
                                                           _diameter));
        }
        
        //圆圈
        {
            CGContextAddEllipseInRect(context, frame);
            switch (zjPoint.state) {
                case ZJPointStateNormal:
                    [_normalTintColor setStroke];
                    break;
                case ZJPointStateSelect:
                    if (_isError) {
                        [_errorTintColor setStroke];
                    } else {
                        [_selectTintColor setStroke];
                    }
                    break;
            }
            CGContextSetLineWidth(context, _circleLineWidth);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
        //圆点
        {
            if (zjPoint.state == ZJPointStateSelect) {
                
                if (_isError) {
                    [_errorTintColor setFill];
                } else {
                    [_selectTintColor setFill];
                }
                CGContextFillEllipseInRect(context, CGRectMake(zjPoint.center.x - _diameter * _smallCircleRatio * .5,
                                                               zjPoint.center.y - _diameter * _smallCircleRatio * .5,
                                                               _diameter * _smallCircleRatio,
                                                               _diameter * _smallCircleRatio));
            }
        }
        
    }
    
}

- (void)drawLine:(CGRect)rect {
    
    if (_selectPoints.count == 0) {
        return;
    }
    
    UIBezierPath *path;
    
    path = [UIBezierPath bezierPath];
    path.lineWidth = _lineWidth;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    
    if (_isError) {
        [_errorTintColor set];
    } else {
        [_selectTintColor set];
    }
    
    for (int i = 0; i < _selectPoints.count; i ++) {
        ZJPoint * point = _selectPoints[i];
        
        if (i == 0) {
            [path moveToPoint:point.center];
        } else {
            [path addLineToPoint:point.center];
        }
    }
    
    [path addLineToPoint:_currentPoint];
    [path stroke];
}

#pragma mark - CGContext使用
//画未选中点图片
//- (UIImage *)drawUnselectImageWithRadius:(float)radius
//{
//    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
//    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] setStroke];
//    CGContextSetLineWidth(context, 5);
//
//    CGContextDrawPath(context, kCGPathStroke);
//
//    UIImage *unselectImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return unselectImage;
//}
//
////画选中点图片
//- (UIImage *)drawSelectImageWithRadius:(float)radius
//{
//    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    CGContextSetLineWidth(context, 5);
//
//    CGContextAddEllipseInRect(context, CGRectMake(3+radius*5/12, 3+radius*5/12, radius/6, radius/6));
//
//    UIColor *selectColor = _selectTintColor;
//
//    [selectColor set];
//
//    CGContextDrawPath(context, kCGPathFillStroke);
//
//    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
//
//    [selectColor setStroke];
//
//    CGContextDrawPath(context, kCGPathStroke);
//
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
//    return image;
//}

//画错误图片
//- (UIImage *)drawWrongImageWithRadius:(float)radius
//{
//    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    CGContextSetLineWidth(context, 5);
//
//    CGContextAddEllipseInRect(context, CGRectMake(3+radius*5/12, 3+radius*5/12, radius/6, radius/6));
//
//    UIColor *selectColor = [UIColor redColor];
//
//    [selectColor set];
//
//    CGContextDrawPath(context, kCGPathFillStroke);
//
//    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
//
//    [selectColor setStroke];
//
//    CGContextDrawPath(context, kCGPathStroke);
//
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
//    return image;
//}

@end

@interface ZJGesturePassword ()<ZJGesturePasswordViewDelegate>

@property (strong, nonatomic) ZJGesturePasswordView *pwdView;

@end

@implementation ZJGesturePassword

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.alpha = 0;
        
        CGRect frame = self.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        frame.size.height = [UIScreen mainScreen].bounds.size.height;
        self.frame = frame;
        
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        [self addSubview:toolbar];
        
        ZJGesturePasswordView *pwdView = [[ZJGesturePasswordView alloc] init];
        pwdView.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
        pwdView.center = self.center;
        pwdView.viewDelegate = self;
        [self addSubview:pwdView];
        _pwdView = pwdView;
        
        UIButton *closeBtn = [[UIButton alloc] init];
        closeBtn.frame = CGRectMake((frame.size.width - 100)/2, frame.size.height - 70, 100, 50);
        [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [self addSubview:closeBtn];
        
    }
    return self;
}

- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!self.superview) {
        [window.subviews.lastObject addSubview:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}
- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)zjGesturePassword:(NSString *)password
{
    if (self.completeAction && !self.delegate) {
        self.completeAction(self,password);
    }
    
    if (!self.completeAction && [self.delegate respondsToSelector:@selector(zjGesturePassword:password:)]) {
        [self.delegate zjGesturePassword:self password:password];
    }
}

- (void)reset
{
    [_pwdView resetGesturePasswordView];
}
- (void)setError
{
    [_pwdView setErrorGesturePasswordView];
}


- (void)dealloc
{
    NSLog(@"ZJGesturePassword");
}
@end

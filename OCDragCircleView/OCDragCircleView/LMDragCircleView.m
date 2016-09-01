//
//  MyView.m
//  QQ小红点效果
//
//  Created by 林萌 on 15/8/22.
//  Copyright (c) 2015年 林萌. All rights reserved.
//

//#define maxDistance 70.0

#import "LMDragCircleView.h"

@interface LMDragCircleView (){
    //手指移动时，x,y偏移值
    CGFloat distanceX;
    CGFloat distanceY;
    
    //触摸开始时，x,y偏移值
    CGFloat oriDisX;
    CGFloat oriDisY;
    
    //触摸结束时，下半圆回缩时用来定时刷新界面的定时器
    NSTimer *timer;
    //定时刷新的总次数
    NSInteger count;
    //已经刷新的次数
    NSInteger doCount;
    
    //触摸结束时,偏移角度的sin值
    CGFloat a;
    //触摸结束时，偏移角度的cos值
    CGFloat b;
    //触摸结束时,此时两圆圆心的距离
    CGFloat distance;
    //触摸结束时，两圆圆心的距离是否超出了最大距离
    BOOL isOverRect;
    
    //触摸位置是否在小圆点内
    BOOL isInCircle;
}

@end

@implementation LMDragCircleView

@synthesize badgeValue,badgeThresholdValue,badgeValueFont,badgeValueThresholdFont,badgeValueColor;
@synthesize oriRadius,circleColor,oriCenterPosition;
@synthesize topCircleMinishScale,bottomCircleMinishScale;
@synthesize maxDistance,baseAmplitude,amplitudeScale;
@synthesize springDuration;
@synthesize recoverRect;
@synthesize delegate;

-(void)drawRect:(CGRect)rect {
    //红色填充
    [self.circleColor setFill];
    
    //初始间距
    CGFloat d = sqrt(distanceX * distanceX + distanceY * distanceY);;
    
    //上半圆的圆心
    CGFloat topX;
    CGFloat topY;
    //上半圆半径
    CGFloat radiusTop;
    
    //下半圆圆心
    CGFloat bottomX = self.oriCenterPosition.x + distanceX;
    CGFloat bottomY = self.oriCenterPosition.y + distanceY;
    //下半圆半径
    CGFloat radiusBottom;
    
    //上半圆的起止角度，下半圆正好与之相反
    CGFloat startAngleTop = distanceY>0 ? M_PI-asin(distanceX/d) : asin(distanceX/d);
    CGFloat endAngeleTop = distanceY>0 ? -asin(distanceX/d) : -(M_PI-asin(distanceX/d));
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //如果两个圆的圆心距离超过指定值，水滴回缩成一个圆；
    //刚开始距离为0的时候，初始状态也是一个圆
    if (isOverRect == YES || d == 0) {
        
        //此时上半圆的圆心也就是下半圆
        topX = bottomX;
        topY = bottomY;
        
        radiusTop = self.oriRadius;
        radiusBottom = self.oriRadius;
        
        if (d == 0) {
            startAngleTop = M_PI;
            endAngeleTop = 0;
        }
        
        //绘制上半圆
        [path addArcWithCenter:CGPointMake(topX, topY) radius:radiusTop startAngle:startAngleTop endAngle:endAngeleTop clockwise:YES];
        
        //绘制下半圆
        [path addArcWithCenter:CGPointMake(bottomX, bottomY) radius:radiusBottom startAngle:endAngeleTop endAngle:startAngleTop clockwise:YES];

    }
    else {  
        topX = self.oriCenterPosition.x;
        topY = self.oriCenterPosition.y;
        
        //上半圆半径,随着距离的增大而递减
        radiusTop = self.oriRadius - d * self.topCircleMinishScale;
        
        //下半圆半径,随着距离的增大而递减,幅度小于上半圆半径
        radiusBottom = self.oriRadius - d * bottomCircleMinishScale;
        
        //下半圆右侧点
        CGFloat brX = bottomX + radiusBottom * (distanceY/d);
        CGFloat brY = bottomY - radiusBottom * (distanceX/d);
        
        //绘制上半圆
        [path addArcWithCenter:CGPointMake(topX, topY) radius:radiusTop startAngle:startAngleTop endAngle:endAngeleTop clockwise:YES];
        
        //右侧贝塞尔曲线上方的点
        CGFloat p1X = topX + radiusTop * (distanceY/d);
        CGFloat p1Y = topY - radiusTop * (distanceX/d);
        
        //右侧贝塞尔曲线的控制点
        CGFloat prX = p1X  + (d/2) * (distanceX/d);
        CGFloat prY = p1Y  + (d/2) * (distanceY/d);
        
        //绘制右侧的贝塞尔曲线
        [path addQuadCurveToPoint:CGPointMake(brX, brY) controlPoint:CGPointMake(prX, prY)];
        
        //绘制下半圆
        [path addArcWithCenter:CGPointMake(bottomX, bottomY) radius:radiusBottom startAngle:endAngeleTop endAngle:startAngleTop clockwise:YES];
        
        //左侧贝塞尔曲线上方的点
        CGFloat pX = topX - radiusTop * (distanceY/d);
        CGFloat pY = topY + radiusTop * (distanceX/d);
        
        //左侧贝塞尔曲线的控制点
        CGFloat plX = pX + (d/2) * (distanceX/d);
        CGFloat plY = pY + (d/2) * (distanceY/d);
        
        //绘制左侧的贝塞尔曲线
        [path addQuadCurveToPoint:CGPointMake(pX, pY) controlPoint:CGPointMake(plX, plY)];
    }
    
    [path fill];
    
    /*
     绘制提示文字
     */
    NSString *bvStr;
    UIFont *bvFont;
    
    if (self.badgeValue > self.badgeThresholdValue) {
        bvStr = [NSString stringWithFormat:@"%ld+",(long)badgeThresholdValue];
        bvFont = self.badgeValueThresholdFont;
    }
    else {
       bvStr = [NSString stringWithFormat:@"%ld",(long)badgeValue];
        bvFont = self.badgeValueFont;
    }
    
    CGSize strSize = [bvStr sizeWithFont:self.badgeValueFont];
   
    CGFloat bvX = bottomX - strSize.width/2;
    CGFloat bvy = bottomY - strSize.height/2;
    
    [bvStr drawInRect:CGRectMake(bvX, bvy, strSize.width, strSize.height) withAttributes:@{NSFontAttributeName:bvFont,
                                                                                           NSForegroundColorAttributeName:self.badgeValueColor
                                                                                           }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //触摸开始时，获取初始点的位置
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGRect rect = CGRectMake(oriCenterPosition.x - oriRadius, oriCenterPosition.y - oriRadius, 2 * oriRadius, 2 * oriRadius);
    
    isInCircle = CGRectContainsPoint(rect, point);
    
    if (!isInCircle) {
        return;
    }
    
    oriDisX = point.x;
    oriDisY = point.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!isInCircle) {
        return;
    }
    
    //触摸移动时，获取手指移动距离
    UITouch *touch = [touches anyObject];
    distanceX = [touch locationInView:self].x - oriDisX;
    distanceY = [touch locationInView:self].y - oriDisY;
    
    CGFloat d = sqrt(distanceX * distanceX + distanceY * distanceY);
    
    if ( d >= self.maxDistance) {
        isOverRect = YES;
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (!isInCircle) {
        return;
    }
    
    //如果松开时，距离超出最大距离
    if (isOverRect == YES) {
        isOverRect = NO;
        
        //如果超出了最大距离 但是而后又往回移了一些(处于某个区间)，此时，应该将小红点移回原处
        if (CGRectContainsPoint(self.recoverRect, point)) {
            distanceX = 0;
            distanceY = 0;
            [self setNeedsDisplay];
            return;
        }
        
        //以动画的形式隐藏小圆圈
        if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenWithCircleView:)]) {
            [self.delegate hiddenWithCircleView:self];
        }
        else {
            [self hiddenCircle];
        }
        return;
    }
    //如果松开时x上的距离和y上的距离均为0,直接返回,无需回弹
    else if (distanceX == 0 && distanceY == 0) {
        return;
    }
    
    //松手后下半圆慢慢回复原位
    CGFloat d = sqrt(distanceX * distanceX + distanceY * distanceY);
    distance = d;
    
    a = distanceX / d;
    b = distanceY / d;
    //回到初始值需要的次数
    count = d / 10;

    timer = [NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(topCircleBackToOri) userInfo:nil repeats:YES];
}

/*
 隐藏红圈
 */
- (void)hiddenCircle {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(aaBack)];
    self.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)aaBack {
    [self removeFromSuperview];
}

/*
 上半圆回缩到初始状态，x,y上的偏移减小为0
 */
- (void)topCircleBackToOri {
    if (doCount == count) {
        distanceX = 0;
        distanceY = 0;
        doCount = 0;
        [timer invalidate];
        timer = nil;
        [self setNeedsDisplay];
        //回弹动画
        [self springBack];
        return;
    }

    doCount++;
    distanceX = distanceX - 10 * a;
    distanceY = distanceY - 10 * b;

    [self setNeedsDisplay];
}

/*
 上半圆回缩到初始状态后，会有一个弹簧动画
 */
- (void)springBack {

    CGFloat maxDis = self.baseAmplitude + distance * self.amplitudeScale;
    
    CAKeyframeAnimation *ba = [CAKeyframeAnimation animation];
    ba.keyPath = @"position";
    ba.values = @[[NSValue valueWithCGPoint:CGPointMake(-maxDis * a + self.layer.position.x , -maxDis * b + self.layer.position.y)],
                  [NSValue valueWithCGPoint:CGPointMake(maxDis * a + self.layer.position.x , maxDis * b + self.layer.position.y)]];
    ba.duration = self.springDuration / 10;
    
    CAKeyframeAnimation *keyAni = [CAKeyframeAnimation animation];
    keyAni.keyPath = @"position";
    keyAni.duration = self.springDuration;
    keyAni.beginTime = CACurrentMediaTime() + ba.duration;
    
    NSInteger number =  60 * keyAni.duration;
    
    NSMutableArray *ary = [NSMutableArray array];
    
    for (CGFloat i = 0; i < number; i++) {
        CGFloat x = i / number;
        CGFloat y = maxDis * pow(M_E, -4 * x) * cos(30 * x);
        [ary addObject:[NSValue valueWithCGPoint:CGPointMake(y * a + self.layer.position.x , y * b + self.layer.position.y)]];
    }
    
    keyAni.values = ary;

    [self.layer addAnimation:ba forKey:nil];
    [self.layer addAnimation:keyAni forKey:nil];
}

/*
 属性默认值设置
 */

- (NSInteger)badgeThresholdValue {
    if (!badgeThresholdValue) {
        badgeThresholdValue = 99;
    }
    return badgeThresholdValue;
}

- (UIFont *)badgeValueFont {
    if (!badgeValueFont) {
        badgeValueFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
    }
    return [badgeValueFont retain];
}

- (UIColor *)badgeValueColor {
    if (!badgeValueColor) {
        badgeValueColor = [UIColor whiteColor];
    }
    return [badgeValueColor retain];
}

- (UIFont *)badgeValueThresholdFont {
    if (!badgeValueThresholdFont) {
        badgeValueThresholdFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    }
    return [badgeValueThresholdFont retain];
}

- (CGFloat)oriRadius {
    if (!oriRadius) {
        oriRadius = 12.0;
    }
    return oriRadius;
}

- (CGFloat)topCircleMinishScale {
    if (!topCircleMinishScale) {
        topCircleMinishScale = 0.1;
    }
    return topCircleMinishScale;
}

- (CGFloat)bottomCircleMinishScale {
    if (!bottomCircleMinishScale) {
        bottomCircleMinishScale = 0.02;
    }
    return bottomCircleMinishScale;
}

- (UIColor *)circleColor {
    if (!circleColor) {
        circleColor = [UIColor redColor];
    }
    return [circleColor retain];
}

- (CGFloat)maxDistance {
    if (!maxDistance) {
        maxDistance = 70.0;
    }
    return maxDistance;
}

- (CGFloat)baseAmplitude {
    if (!baseAmplitude) {
        baseAmplitude = 5.0;
    }
    return baseAmplitude;
}

- (CGFloat)amplitudeScale {
    if (!amplitudeScale) {
        amplitudeScale = 0.35;
    }
    return amplitudeScale;
}

- (NSTimeInterval)springDuration {
    if (!springDuration) {
        springDuration = 1.2;
    }
    return springDuration;
}

- (CGPoint)oriCenterPosition {
    if (CGPointEqualToPoint(oriCenterPosition, CGPointZero)) {
        oriCenterPosition = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    }
    return oriCenterPosition;
}

- (void)setFrame:(CGRect)frame {
    frame = [UIScreen mainScreen].bounds;
    [super setFrame:frame];
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame = [UIScreen mainScreen].bounds;
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithCircleCenter:(CGPoint)position {
    if (self = [self initWithFrame:[UIScreen mainScreen].bounds]) {
        self.oriCenterPosition = position;
    }
    return self;
}

- (void)dealloc {
    [badgeValueThresholdFont release];
    [badgeValueColor release];
    [badgeValueFont release];
    [circleColor release];
    [super dealloc];
    NSLog(@"%@",@"LMDragCircleView被销毁了");
}

@end

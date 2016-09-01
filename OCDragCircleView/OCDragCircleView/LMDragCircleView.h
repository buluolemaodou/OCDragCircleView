//
//  MyView.h
//  QQ小红点效果
//
//  Created by 林萌 on 15/8/22.
//  Copyright (c) 2015年 林萌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "LMDragCircleView.h"

@class LMDragCircleView;
@protocol LMDragCircleViewDelegate <NSObject>

@optional

/*
 隐藏圆圈方法，实现之可自定义圆圈隐藏动画,执行完动画以后,需要将view从父控件中移除
 */
- (void)hiddenWithCircleView:(LMDragCircleView *)circleView;

@end

@interface LMDragCircleView : UIView {
    NSInteger badgeValue;
    NSInteger badgeThresholdValue;
    UIFont *badgeValueFont;
    UIFont *badgeValueThresholdFont;
    UIColor *badgeValueColor;
    
    CGFloat oriRadius;
    UIColor *circleColor;
    CGPoint oriCenterPosition;
    
    CGFloat topCircleMinishScale;
    CGFloat bottomCircleMinishScale;
    
    CGFloat maxDistance;
    CGFloat baseAmplitude;
    CGFloat amplitudeScale;

    
    NSTimeInterval springDuration;
    
    CGRect recoverRect;
    
    id delegate;
}

@property (nonatomic,assign) id<LMDragCircleViewDelegate> delegate;

@property (nonatomic,assign) NSInteger badgeValue;//数字
@property (nonatomic,assign) NSInteger badgeThresholdValue;//阀值,超出时，显示xx+
@property (nonatomic,retain) UIFont *badgeValueFont;//数字字体
@property (nonatomic,retain) UIFont *badgeValueThresholdFont;//数字溢出字体(xx+或者数字过大时)
@property (nonatomic,retain) UIColor *badgeValueColor;//数字颜色

@property (nonatomic,assign) CGFloat topCircleMinishScale;//上半圆随距离增大的减小比例
@property (nonatomic,assign) CGFloat bottomCircleMinishScale;//下半圆随距离增大的减小比例

@property (nonatomic,assign) CGFloat oriRadius;//初始半径
@property (nonatomic,retain) UIColor *circleColor;//颜色
@property (nonatomic,assign) CGPoint oriCenterPosition;//圆心初始位置

@property (nonatomic,assign) CGFloat maxDistance;//极限拖动距离
@property (nonatomic,assign) CGFloat baseAmplitude;//基准振幅

/*
 最大振幅会在基准振幅的基础上随着拖动距离的增大而增大，此属性为增大的比例
 默认为0.35
 */
@property (nonatomic,assign) CGFloat amplitudeScale;

/*
 弹簧动画的时间间隔
 默认为1.2s
 */
@property (nonatomic,assign) NSTimeInterval springDuration;

@property (nonatomic,assign) CGRect recoverRect;//拖动小红点到某个区域，即会复原到原位置


- (instancetype)initWithCircleCenter:(CGPoint)position;

@end

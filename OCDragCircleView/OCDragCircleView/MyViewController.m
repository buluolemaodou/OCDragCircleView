//
//  MyViewController.m
//  QQ小红点
//
//  Created by bingdian on 15/8/31.
//  Copyright (c) 2015年 bingdian. All rights reserved.
//

#import "MyViewController.h"

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    LMDragCircleView *ldcv = [[LMDragCircleView alloc] initWithCircleCenter:CGPointMake(150, 200)];
    ldcv.badgeValue = 17;
    ldcv.delegate = self;
    ldcv.recoverRect = CGRectMake(0, 0, 100, 200);
    [self.view addSubview:ldcv];
    [ldcv release];
}

- (void)hiddenWithCircleView:(LMDragCircleView *)circleView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:circleView];
    [UIView setAnimationDidStopSelector:@selector(aaBack)];
    circleView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    circleView.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)dealloc {
    [super dealloc];
    NSLog(@"MyViewController被销毁了");
}

@end

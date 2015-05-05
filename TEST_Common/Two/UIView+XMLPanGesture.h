//
//  UIView+XMLPanGesture.h
//  TEST_Common
//
//  Created by luxiaoming on 15/4/29.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMLPanGestureDelegate <NSObject>

@optional

- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture didChangeWithView:(UIView *)targetView;
- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture willShowTargetView:(UIView *)targetView;
- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture didShowTargetView:(UIView *)targetView;
- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture willHideTargetView:(UIView *)targetView;
- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture didHideTargetView:(UIView *)targetView;

@end



/**
 *  动画是依赖pop的
 */
@interface UIView (XMLPanGesture)

@property (nonatomic, assign) id<XMLPanGestureDelegate> panGestureDelegate;

/**
 *  注意这个方法必须放在view被add到subView上之后调用,因为里面会用到view.superView
 *  在iOS8的6或者6+上，这个方法需放到viewDidAppear里面，因为动画是改frame的，而layout在viewDidAppear的时候才会确定正确的frame
 */
- (void)addPanGestureWithEndFrame:(CGRect)endFrame;

- (void)showGesturedViewWithCompletedBlock:(void(^)(BOOL isFinished))completedBlock;

- (void)hideGesturedViewWithCompletedBlock:(void(^)(BOOL isFinished))completedBlock;
@end

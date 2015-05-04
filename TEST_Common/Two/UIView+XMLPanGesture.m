//
//  UIView+XMLPanGesture.m
//  TEST_Common
//
//  Created by luxiaoming on 15/4/29.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import "UIView+XMLPanGesture.h"
#import <POP.h>
#import <objc/runtime.h>

#define kDefaultPanGestureMaxTopOffset 80

@interface UIView ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGRect endFrame;

@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) CGPoint endCenter;
@property (nonatomic, assign) BOOL isShowed;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIView *panMaskView;
@property (nonatomic, assign) id<XMLPanGestureDelegate>panGestureDelegate;

@end

@implementation UIView (XMLPanGesture)

#pragma mark - publicMethod

- (void)addPanGestureWithEndFrame:(CGRect)endFrame {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesutre = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesutre];
    
    
    self.panGesture = panGesture;
    self.originalFrame = self.frame;
    self.endFrame = endFrame;
    self.originalCenter = self.center;
    self.endCenter = CGPointMake(CGRectGetWidth(self.endFrame) / 2, self.endFrame.origin.y + CGRectGetHeight(self.endFrame) / 2);
    self.isShowed = NO;
    self.isAnimating = NO;
    
    UIView *panMaskView = [[UIView alloc] initWithFrame:self.superview.bounds];
    panMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    panMaskView.hidden = YES;
    panMaskView.alpha = 0;
    UITapGestureRecognizer *panMaskViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanMaskViewTapGesture:)];
    [panMaskView addGestureRecognizer:panMaskViewTapGesture];
    self.panMaskView = panMaskView;
    [self.superview insertSubview:self.panMaskView belowSubview:self];
}

#pragma mark - privateMethod


#pragma mark - UIGestureRecognizerDelegate

/**
 *  貌似只要一个手势设置了delegate，这个view的所有手势的delegate都会变成这个
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
        CGPoint location = [gestureRecognizer locationInView:self];
        if (location.y < 44) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    
}

#pragma mark - gestureAction

- (void)handlePanMaskViewTapGesture:(UITapGestureRecognizer *)sender {
    if (self.isAnimating) {
        return;
    }
    [self hideGesturedViewWithCompletedBlock:^(BOOL isFinished) {
    }];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (self.isAnimating) {
        return;
    }
    if (self.isShowed) {
        [self hideGesturedViewWithCompletedBlock:nil];
    } else {
        [self showGesturedViewWithCompletedBlock:nil];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    if (self.isAnimating == YES) {
        return;
    }
    
    if ([self.panGestureDelegate respondsToSelector:@selector(xmlPanGesture:didChangeWithView:)]) {
        [self.panGestureDelegate xmlPanGesture:self.panGesture didChangeWithView:self];
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self];
        if (self.isShowed == NO) {
            //从下往上滑动的时候，translation.y是负值，
            CGFloat currentY = self.originalCenter.y + translation.y;
            if (currentY <= self.endCenter.y - kDefaultPanGestureMaxTopOffset) {
                currentY = self.endCenter.y - kDefaultPanGestureMaxTopOffset;
            }
            CGPoint newCenter = CGPointMake(self.originalCenter.x, currentY);
            self.center = newCenter;
        } else {
            CGFloat currentY = self.endCenter.y + translation.y;
            if (currentY <= self.endCenter.y - kDefaultPanGestureMaxTopOffset) {
                currentY = self.endCenter.y - kDefaultPanGestureMaxTopOffset;
            }
            CGPoint newCenter = CGPointMake(self.endCenter.x, currentY);
            self.center = newCenter;
        }
        self.panMaskView.hidden = NO;
        CGFloat percent = (self.center.y - self.originalCenter.y) / (self.endCenter.y - self.originalCenter.y);//当前移动距离与终点移动距离的比
        if (percent >= 1) {
            percent = 1;
        }
        self.panMaskView.alpha = percent;
        
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [sender velocityInView:self];
        CGPoint translation = [sender translationInView:self];
//        NSLog(@"location is %f and velocity is %f",location.y, velocity.y);
        if (velocity.y < 0 && ABS(translation.y) > ABS(self.endCenter.y - self.originalCenter.y) / 3) {
            //向上滑动且滑动距离超过最大距离的1/3时，显示GesturedView
            [self showGesturedViewWithCompletedBlock:nil];
        } else {
            [self hideGesturedViewWithCompletedBlock:nil];
        }
        
    } else {
        return;
    }
}

- (void)showGesturedViewWithCompletedBlock:(void(^)(BOOL isFinished))completedBlock {
    if ([self.panGestureDelegate respondsToSelector:@selector(xmlPanGesture:willShowTargetView:)]) {
        [self.panGestureDelegate xmlPanGesture:self.panGesture willShowTargetView:self];
    }
    self.isAnimating = YES;
    [self pop_addAnimation:[UIView popFrameAnimationWithFinalFrame:self.endFrame completedBlock:^(POPAnimation *animation, BOOL finished) {
        self.isShowed = YES;
        self.isAnimating = NO;
        if (completedBlock) {
            completedBlock(finished);
        }
    }] forKey:@"kGesturedShowAnimation"];
    self.panMaskView.hidden = NO;
    [self.panMaskView pop_addAnimation:[UIView popEaseInOutAnimationWithFinalAlpha:1 completedBlock:^(POPAnimation *animation, BOOL finished) {
        if ([self.panGestureDelegate respondsToSelector:@selector(xmlPanGesture:didShowTargetView:)]) {
            [self.panGestureDelegate xmlPanGesture:self.panGesture didShowTargetView:self];
        }
    }] forKey:@"kPanMaskViewShowAnimation"];
}

- (void)hideGesturedViewWithCompletedBlock:(void(^)(BOOL isFinished))completedBlock {
    if ([self.panGestureDelegate respondsToSelector:@selector(xmlPanGesture:willHideTargetView:)]) {
        [self.panGestureDelegate xmlPanGesture:self.panGesture willHideTargetView:self];
    }
    self.isAnimating = YES;
    [self pop_addAnimation:[UIView popFrameAnimationWithFinalFrame:self.originalFrame completedBlock:^(POPAnimation *animation, BOOL finished) {
        self.isShowed = NO;
        self.isAnimating = NO;
        if (completedBlock) {
            completedBlock(finished);
        }
        if ([self.panGestureDelegate respondsToSelector:@selector(xmlPanGesture:didHideTargetView:)]) {
            [self.panGestureDelegate xmlPanGesture:self.panGestureDelegate didHideTargetView:self];
        }
    }] forKey:@"kGesturedHideAnimation"];
    [self.panMaskView pop_addAnimation:[UIView popEaseInOutAnimationWithFinalAlpha:0 completedBlock:^(POPAnimation *animation, BOOL finished) {
        self.panMaskView.hidden = YES;
        
    }] forKey:@"kPanMaskViewHideAnimation"];

}

#pragma mark - POPAnimation

+ (POPAnimation *)popFrameAnimationWithFinalFrame:(CGRect)finalFrame completedBlock:(void(^)(POPAnimation *animation, BOOL finished))completedBlock {
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    animation.toValue = [NSValue valueWithCGRect:finalFrame];
    animation.completionBlock = completedBlock;
    animation.springBounciness = 15;
    animation.springSpeed = 6;
    animation.velocity = [NSValue valueWithCGRect:CGRectMake(0, 1000, 0, 0)];
    return animation;
}


+ (POPAnimation *)popEaseInOutAnimationWithFinalAlpha:(CGFloat)finalAlpha completedBlock:(void(^)(POPAnimation *animation, BOOL finished))completedBlock{
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    animation.toValue = @(finalAlpha);
    animation.completionBlock = completedBlock;
    return animation;
}

#pragma mark - property 

- (void)setOriginalFrame:(CGRect)originalFrame {
    objc_setAssociatedObject(self, @selector(originalFrame), [NSValue valueWithCGRect:originalFrame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)originalFrame {
    return [objc_getAssociatedObject(self, @selector(originalFrame)) CGRectValue];
}

- (void)setEndFrame:(CGRect)endFrame {
    objc_setAssociatedObject(self, @selector(endFrame), [NSValue valueWithCGRect:endFrame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)endFrame {
    return [objc_getAssociatedObject(self, @selector(endFrame)) CGRectValue];
}

- (void)setOriginalCenter:(CGPoint)originalCenter {
    objc_setAssociatedObject(self, @selector(originalCenter), [NSValue valueWithCGPoint:originalCenter], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)originalCenter {
    return [objc_getAssociatedObject(self, @selector(originalCenter)) CGPointValue];
}

- (void)setEndCenter:(CGPoint)endCenter {
    objc_setAssociatedObject(self, @selector(endCenter), [NSValue valueWithCGPoint:endCenter], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)endCenter {
    return [objc_getAssociatedObject(self, @selector(endCenter)) CGPointValue];
}

- (void)setIsShowed:(BOOL)isShowed {
    objc_setAssociatedObject(self, @selector(isShowed), [NSNumber numberWithBool:isShowed], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isShowed {
    return [objc_getAssociatedObject(self, @selector(isShowed)) boolValue];
}

- (void)setIsAnimating:(BOOL)isAnimating {
    objc_setAssociatedObject(self, @selector(isAnimating), [NSNumber numberWithBool:isAnimating], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAnimating {
    return [objc_getAssociatedObject(self, @selector(isAnimating)) boolValue];
}

- (void)setPanGesture:(UIPanGestureRecognizer *)panGesture {
    objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIPanGestureRecognizer *)panGesture {
    return objc_getAssociatedObject(self, @selector(panGesture));
}

- (void)setPanMaskView:(UIView *)panMaskView {
    objc_setAssociatedObject(self, @selector(panMaskView), panMaskView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)panMaskView {
    return objc_getAssociatedObject(self, @selector(panMaskView));
}

- (void)setPanGestureDelegate:(id<XMLPanGestureDelegate>)panGestureDelegate {
    objc_setAssociatedObject(self, @selector(panGestureDelegate), panGestureDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<XMLPanGestureDelegate>)panGestureDelegate {
    return objc_getAssociatedObject(self, @selector(panGestureDelegate));
}

@end

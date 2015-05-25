//
//  TESTFloatingView.m
//  TEST_Common
//
//  Created by luxiaoming on 15/5/25.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import "TESTFloatingView.h"

@implementation TESTFloatingView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        return nil;
    } else {
        return result;
    }
}

@end

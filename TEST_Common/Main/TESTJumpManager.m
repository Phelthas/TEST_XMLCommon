//
//  TESTJumpManager.m
//  TEST_Common
//
//  Created by luxiaoming on 2019/7/9.
//  Copyright © 2019 luxiaoming. All rights reserved.
//

#import "TESTJumpManager.h"

@implementation TESTJumpManager

+ (UIViewController *)getRootViewController {
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

+ (UINavigationController *)getCurrentNavigationController {
    UIViewController *root = [self getRootViewController];
    if ([root isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)root;
    }
    return nil;
}

+ (void)jumpToViewController:(UIViewController *)viewController inNav:(UINavigationController *)nav {
    UINavigationController *currentNav = nav;
    if (currentNav == nil) {
        currentNav = [self getCurrentNavigationController];
    }
    [currentNav pushViewController:viewController animated:YES];;
}


@end

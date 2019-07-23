//
//  TESTJumpManager.h
//  TEST_Common
//
//  Created by luxiaoming on 2019/7/9.
//  Copyright © 2019 luxiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TESTJumpManager : NSObject

+ (UIViewController *)getRootViewController;

+ (nullable UINavigationController *)getCurrentNavigationController;

+ (void)jumpToViewController:(UIViewController *)viewController inNav:(nullable UINavigationController *)nav;

@end

NS_ASSUME_NONNULL_END

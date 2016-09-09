//
//  FourDisplayViewController.h
//  TEST_Common
//
//  Created by luxiaoming on 16/8/30.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FourDisplayViewController : UIViewController

@property (nonatomic, strong) NSAttributedString *displayString;


+ (instancetype)loadFromStroyboard;

@end

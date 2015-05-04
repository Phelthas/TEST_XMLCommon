//
//  TESTViewController.m
//  TEST_Base
//
//  Created by luxiaoming on 15/4/28.
//  Copyright (c) 2015年 XiaoMing. All rights reserved.
//

#import "TESTViewController.h"
#import "UIView+XMLPanGesture.h"


@interface TESTViewController ()<XMLPanGestureDelegate>

@property (weak, nonatomic) IBOutlet UIView *testView;

@end

@implementation TESTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //用代码写
//    [self.testView removeFromSuperview];
//    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 400, CGRectGetWidth([UIScreen mainScreen].bounds), 100)];
//    testView.backgroundColor = [UIColor orangeColor];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//    label.text = @"asdfasdf";
//    [testView addSubview:label];
//    self.testView = testView;
//    
//    [self.view addSubview:testView];
//    [testView addPanGestureWithEndFrame:CGRectMake(0, 200, CGRectGetWidth([UIScreen mainScreen].bounds), 100)];
//    testView.panGestureDelegate = self;
    
    //用storyBoard
    self.testView.backgroundColor = [UIColor clearColor];
    [self.testView addPanGestureWithEndFrame:CGRectMake(0, 300, CGRectGetWidth([UIScreen mainScreen].bounds), self.testView.frame.size.height)];
    self.testView.panGestureDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - XMLPanGestureDelegate

- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture didChangeWithView:(UIView *)targetView {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.testView.backgroundColor = [UIColor orangeColor];
    }
}

- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture willShowTargetView:(UIView *)targetView {
    self.testView.backgroundColor = [UIColor orangeColor];

}

- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture didShowTargetView:(UIView *)targetView {
    
}

- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture willHideTargetView:(UIView *)targetView {
    
}

- (void)xmlPanGesture:(UIPanGestureRecognizer *)panGesture didHideTargetView:(UIView *)targetView {
    self.testView.backgroundColor = [UIColor clearColor];
}

@end

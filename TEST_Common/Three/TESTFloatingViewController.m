//
//  TESTFloatingViewController.m
//  TEST_Common
//
//  Created by luxiaoming on 15/5/20.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import "TESTFloatingViewController.h"
#import "TESTFloatingView.h"

#define kFloatingViewMinimumHeight 64
#define kFloatingViewMaximumHeight 200

@interface TESTFloatingViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet TESTFloatingView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;

@property (nonatomic, strong) id savedDelegate;


@end

@implementation TESTFloatingViewController

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;//因为会利用到tableView的contentInset，所以不想系统给我们改，最好把这个设置为UIRectEdgeNone,否则在viewDidAppear的时候tableView的contentInset会变
    self.tableView.contentInset = UIEdgeInsetsMake(kFloatingViewMaximumHeight, 0, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.backButton addTarget:self action:@selector(handleBackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.savedDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;//这里是为了保留系统的右滑返回手势

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self.savedDelegate;//这里是为了保留系统的右滑返回手势

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"index : (%ld, %ld)", (long)indexPath.section, (long)indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


#pragma mark - kvo

//// 效果1：
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"contentOffset"]) {
//        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
//        if (offset.y <= 0 && -offset.y >= kFloatingViewMaximumHeight) {
//            self.headerViewHeightConstraint.constant = - offset.y;
//        } else if (offset.y < 0 && -offset.y < kFloatingViewMaximumHeight && -offset.y > kFloatingViewMinimumHeight) {
//            self.headerViewHeightConstraint.constant = kFloatingViewMaximumHeight;
//            self.headerViewTopConstraint.constant = -offset.y - kFloatingViewMaximumHeight;
//        } else {
//            self.headerViewTopConstraint.constant = kFloatingViewMinimumHeight - kFloatingViewMaximumHeight;
//        }
//    }
//}

//效果2：
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        if (offset.y <= 0 && -offset.y >= kFloatingViewMaximumHeight) {
            self.headerViewTopConstraint.constant = -offset.y - kFloatingViewMaximumHeight;
        } else if (offset.y < 0 && -offset.y < kFloatingViewMaximumHeight && -offset.y > kFloatingViewMinimumHeight) {
            self.headerViewTopConstraint.constant = -offset.y - kFloatingViewMaximumHeight;
        } else {
            self.headerViewTopConstraint.constant = kFloatingViewMinimumHeight - kFloatingViewMaximumHeight;
        }
    }
}

////效果3：
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"contentOffset"]) {
//        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
//        if (offset.y <= 0 && -offset.y >= kFloatingViewMinimumHeight) {
//            self.headerViewHeightConstraint.constant = - offset.y;
//        } else {
//            self.headerViewHeightConstraint.constant = kFloatingViewMinimumHeight;
//        }
//    }
//}

#pragma mark - buttonAction

- (void)handleBackButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end

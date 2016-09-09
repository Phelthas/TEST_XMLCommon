//
//  FourDisplayViewController.m
//  TEST_Common
//
//  Created by luxiaoming on 16/8/30.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

#import "FourDisplayViewController.h"

@interface FourDisplayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation FourDisplayViewController

+ (instancetype)loadFromStroyboard {
    FourDisplayViewController *viewController = [[UIStoryboard storyboardWithName:@"Four" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.attributedText = self.displayString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

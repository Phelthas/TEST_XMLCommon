//
//  TESTFeatureItem.m
//  TEST_Common
//
//  Created by luxiaoming on 2019/7/9.
//  Copyright © 2019 luxiaoming. All rights reserved.
//

#import "TESTFeatureItem.h"


@implementation TESTFeatureItem


+ (NSArray<TESTFeatureItem *> *)defaultTestItems {
    
    TESTFeatureItem *one = [[TESTFeatureItem alloc] init];
    one.title = @"Test AVAudioMix";
    [one setAction:^{
        
    }];
    
    return @[one];
}



@end

//
//  TESTFeatureItem.h
//  TEST_Common
//
//  Created by luxiaoming on 2019/7/9.
//  Copyright © 2019 luxiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TESTFeatureItemAction)(void);

@interface TESTFeatureItem : NSObject

@property (nonatomic, copy, nullable) NSString *title;

@property (nonatomic, copy) TESTFeatureItemAction action;


+ (NSArray<TESTFeatureItem *> *)defaultTestItems;


@end

NS_ASSUME_NONNULL_END

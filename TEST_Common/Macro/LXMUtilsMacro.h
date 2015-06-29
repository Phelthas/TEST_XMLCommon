//
//  LXMUtilsMacro.h
//  TEST_Common
//
//  Created by luxiaoming on 15/6/18.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#ifndef TEST_Common_LXMUtilsMacro_h
#define TEST_Common_LXMUtilsMacro_h

#define kLXMUserDefaults [NSUserDefaults standardUserDefaults]
#define kLXMNotificationCenter   [NSNotificationCenter defaultCenter]
#define kLXMFileManager          [NSFileManager defaultManager]
#define kLXMApplication          [UIApplication sharedApplication]


#define kLXMScreenHeight            [[UIScreen mainScreen] bounds].size.height
#define kLXMScreenWidth             [[UIScreen mainScreen] bounds].size.width

//判断屏幕尺寸，注意这个取出来的是屏幕实际尺寸，iPad需要另外写
#define is3_5Inch CGSizeEqualToSize([UIScreen mainScreen].currentMode.size, CGSizeMake(640, 960))
#define is4_0Inch CGSizeEqualToSize([UIScreen mainScreen].currentMode.size, CGSizeMake(640, 1136))
#define is4_7Inch CGSizeEqualToSize([UIScreen mainScreen].currentMode.size, CGSizeMake(750, 1334))
#define is5_5Inch CGSizeEqualToSize([UIScreen mainScreen].currentMode.size, CGSizeMake(1242, 2208))

//判读运行模式，判读程序运行时实际的“点”，iPad运行iPhone程序也可以用这个
#define is320_480 CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(320, 480))
#define is320_568 CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(320, 568))
#define is375_667 CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 667))
#define is414_736 CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 736))

//颜色相关
#define LXMColor(R, G, B, A)       [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define LXMColorFromHex(hexValue) [UIColor \
                                    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                    green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                    blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//调试用log
#define IOS_DEBUG
#ifdef  IOS_DEBUG
#define LogMethodName NSLog(@"%s",__FUNCTION__)
#define NSLog(string,...) NSLog(@"\n 文件名：%s \n 函数名：%s \n 代码行数：%d \n     " string, __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__)

#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)

#else
#define NSLog(...) {}
#endif

#endif

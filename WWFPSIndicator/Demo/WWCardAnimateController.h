//
//  WWCardAnimateController.h
//  WWAnimatePratise
//
//  Created by Tidus on 15/8/12.
//  Copyright (c) 2015年 tidus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)

@interface WWCardAnimateController : UIViewController

- (instancetype)initWithDefaultImages;

- (instancetype)initWithImages:(NSArray *)images;

@end

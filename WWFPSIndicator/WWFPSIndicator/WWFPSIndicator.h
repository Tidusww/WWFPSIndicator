//
//  WWFPSIndicator.h
//  TidusWWDemo
//
//  Created by Tidus on 16/11/30.
//  Copyright © 2016年 Tidus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WWFPSIndicatorRefreshFrequency) {
    WWFPSIndicatorRefreshFrequencyNormal = 1,
    WWFPSIndicatorRefreshFrequencyMedium = 3,
    WWFPSIndicatorRefreshFrequencyHigh = 10
};

typedef NS_ENUM(NSUInteger, WWFPSIndicatorTextStyle) {
    WWFPSIndicatorTextStyleNormal = 0,
    WWFPSIndicatorTextStyleColorful = 1
};

@interface WWFPSIndicator : NSObject

@property (nonatomic, assign) WWFPSIndicatorRefreshFrequency frequency;
@property (nonatomic, assign) WWFPSIndicatorTextStyle textStyle;

+ (WWFPSIndicator *)sharedInstance;

- (void)start;
- (void)stop;


@end








#ifndef WWUIKit_h
@interface UIView (WWView)

#pragma mark - Frame
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)width;
- (CGFloat)height;

- (void)x:(CGFloat)x;
- (void)y:(CGFloat)y;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

@end
#endif

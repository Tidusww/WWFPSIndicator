//
//  WWFPSIndicator.m
//  TidusWWDemo
//
//  Created by Tidus on 16/11/30.
//  Copyright © 2016年 Tidus. All rights reserved.
//

#import "WWFPSIndicator.h"
@interface WWFPSIndicator ()

@property (nonatomic, strong) UILabel *fpsLabel;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger scheduleTimes;
@property (nonatomic, assign) CFTimeInterval timestamp;


@end

@implementation WWFPSIndicator

#pragma mark - life cycle
+ (WWFPSIndicator *)sharedInstance;
{
    static WWFPSIndicator *indicator;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        indicator = [[WWFPSIndicator alloc] init];
    });
    
    return indicator;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        [self setupSubviews];
        [self setupDisplayLink];
        
        _frequency = WWFPSIndicatorRefreshFrequencyNormal;
        _textStyle = WWFPSIndicatorTextStyleNormal;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationDidBecomeActiveNotification)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillResignActiveNotification)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
    }
    return self;
}

- (void)setupSubviews
{
    _fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, 60, 30)];
    _fpsLabel.font = [UIFont systemFontOfSize:12.f];
    _fpsLabel.textColor = [UIColor whiteColor];
    _fpsLabel.textAlignment = NSTextAlignmentCenter;
    _fpsLabel.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [_fpsLabel addGestureRecognizer:panGesture];
    
    _fpsLabel.userInteractionEnabled = YES;
}

- (void)setupDisplayLink
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkTicks:)];
    [_displayLink setPaused:YES];
    
    //add to main thread
    NSThread *thread = [NSThread currentThread];
    //no sense to add to the Sub thread
    //    thread = [[self class] fpsThread];
    
    [self performSelector:@selector(scheduleLink) onThread:thread withObject:nil waitUntilDone:NO modes:[[NSSet setWithObject:NSRunLoopCommonModes] allObjects]];
    
}

- (void)scheduleLink
{
    //add to run loop for NSRunLoopCommonModes
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - fps thread
+ (NSThread *)fpsThread;
{
    static NSThread *fpsThread;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fpsThread = [[NSThread alloc] initWithBlock:^(){
            //run the runloop
            [[NSRunLoop currentRunLoop] run];
        }];
        fpsThread.name = @"WWFpsThread";
        [fpsThread start];
    });
    
    return fpsThread;
}

#pragma mark - operation
- (void)start
{
    if(!_displayLink){
        [self setupDisplayLink];
    }
    
    if(!_displayLink.paused){
        return;
    }
    
    _scheduleTimes = 0;
    _timestamp = 0;
    
    [self show];
}

- (void)show
{
    [_displayLink setPaused:NO];
    [_fpsLabel removeFromSuperview];
    [[UIApplication sharedApplication].delegate.window addSubview:_fpsLabel];
    [[UIApplication sharedApplication].delegate.window bringSubviewToFront:_fpsLabel];
}

- (void)stop
{
    if(_displayLink){
        [_displayLink invalidate];
        _displayLink = nil;
    }
    [self hide];
}

- (void)hide
{
    [_displayLink setPaused:YES];
    [_fpsLabel removeFromSuperview];
}



- (void)linkTicks:(CADisplayLink *)link
{
    _scheduleTimes ++;
    
    if(_timestamp == 0){
        _timestamp = link.timestamp;
    }
    
    CFTimeInterval timePassed = link.timestamp - _timestamp;
    if(timePassed < 1.f/_frequency){
        return;
    }
    
    //fps
    int fps = MIN((int)round(_scheduleTimes/timePassed), 60);
#ifdef DEBUG
//    printf("fps:%ld, timePassed:%f\n", (long)fps, timePassed);
#endif
    
    
    //update label
    if(_textStyle == WWFPSIndicatorTextStyleNormal){
        [_fpsLabel setText:[NSString stringWithFormat:@"%d FPS", fps]];
    }else if(_textStyle == WWFPSIndicatorTextStyleColorful){
        UIColor *fpsColor;
        if(fps >= 55){
            fpsColor = [UIColor greenColor];
        }else if(fps >= 45){
            fpsColor = [UIColor yellowColor];
        }else{
            fpsColor = [UIColor redColor];
        }
        
        NSString *fpsStr = [NSString stringWithFormat:@"%ld", (long)fps];
        NSString *totalStr = [fpsStr stringByAppendingString:@" FPS"];
        NSRange range = [totalStr rangeOfString:fpsStr];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:totalStr];
        [attributedString addAttribute:NSForegroundColorAttributeName value:fpsColor range:range];
        
        [_fpsLabel setAttributedText:attributedString];
        
    }
    [[UIApplication sharedApplication].delegate.window bringSubviewToFront:_fpsLabel];
    
    
    //reset
    _timestamp = link.timestamp;
    _scheduleTimes = 0;
    
}

#pragma mark - notification
- (void)applicationDidBecomeActiveNotification {
    [_displayLink setPaused:NO];
}

- (void)applicationWillResignActiveNotification {
    [_displayLink setPaused:YES];
}

#pragma mark - panGesture
- (void)didPan:(UIPanGestureRecognizer *)sender
{
    UIWindow *superView = [UIApplication sharedApplication].delegate.window;
    CGPoint position = [sender locationInView:superView];
    if(sender.state == UIGestureRecognizerStateBegan){
        _fpsLabel.alpha = 0.5;
    }else if(sender.state == UIGestureRecognizerStateChanged){
        _fpsLabel.center = position;
    }else if(sender.state == UIGestureRecognizerStateEnded){
        
        CGRect newFrame = CGRectMake(MIN(superView.width-_fpsLabel.width, MAX(0, _fpsLabel.x)),
                                     MIN(superView.height-_fpsLabel.height, MAX(0, _fpsLabel.y)),
                                     _fpsLabel.width,
                                     _fpsLabel.height);
        
        [UIView animateWithDuration:0.2 animations:^{
            _fpsLabel.frame = newFrame;
            _fpsLabel.alpha = 1;
        }];
    }
}


@end




#ifndef WWUIKit_h
@implementation UIView (WWView)

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)x:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)y:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end
#endif

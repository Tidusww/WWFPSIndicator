//
//  WWCardAnimateController.m
//  WWAnimatePratise
//
//  Created by Tidus on 15/8/12.
//  Copyright (c) 2015年 tidus. All rights reserved.
//

#import "WWCardAnimateController.h"

@interface WWCardAnimateController ()
@property (assign, nonatomic) CGFloat maxPanX;
@property (assign, nonatomic) NSInteger defaultSize;//所有ImageView的总数
@property (assign, nonatomic) NSInteger maxSize;//所有ImageView的总数
@property (assign, nonatomic) NSInteger curIndex;//第一张图片在队列中的位置
@property (strong, nonatomic) NSMutableArray *imageArray;//所有图片的队列
@property (strong, nonatomic) NSMutableSet *reuseImageViewSet;//重用ImageView队列
@property (strong, nonatomic) NSMutableArray *displayImageViewArray;//当前ImageView的队列

@property (assign, nonatomic) BOOL firstViewScaleToFill;//是否放大了第一张图片
@end

@implementation WWCardAnimateController

#pragma mark - Life Cycle
- (instancetype)init
{
    self = [self initWithDefaultImages];
    
    return self;
}


- (instancetype)initWithDefaultImages
{
    //使用这个，在模拟器上滑动的时候会卡一点
    UIImage *image1 = [UIImage imageNamed:@"TaylorSwift1"];
    UIImage *image2 = [UIImage imageNamed:@"TaylorSwift2"];
    UIImage *image3 = [UIImage imageNamed:@"TaylorSwift3"];
    UIImage *image4 = [UIImage imageNamed:@"TaylorSwift4"];
    UIImage *image5 = [UIImage imageNamed:@"TaylorSwift5"];
    UIImage *image6 = [UIImage imageNamed:@"TaylorSwift6"];
    UIImage *image7 = [UIImage imageNamed:@"TaylorSwift7"];
    
//    UIImage *image1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaylorSwift1" ofType:@"png"]];
//    UIImage *image2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaylorSwift2" ofType:@"png"]];
//    UIImage *image3 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaylorSwift3" ofType:@"png"]];
//    UIImage *image4 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaylorSwift4" ofType:@"png"]];
//    UIImage *image5 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaylorSwift5" ofType:@"png"]];
//    UIImage *image6 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaylorSwift6" ofType:@"png"]];
//    UIImage *image7 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaylorSwift7" ofType:@"png"]];
    NSArray *images = @[image1, image2, image3, image4, image5, image6, image7];
    
    
    
    
    
    return [self initWithImages:images];
    
    
}

- (instancetype)initWithImages:(NSArray *)images
{
    if((self = [super init])){
        self.imageArray = [images mutableCopy];
        self.displayImageViewArray = [@[] mutableCopy];
        self.reuseImageViewSet = [[NSMutableSet alloc] init];
        self.maxPanX = kScreenWidth/4;
        self.curIndex = 0;
        self.defaultSize = 3;
        self.maxSize = images.count>self.defaultSize ? self.defaultSize : images.count;
        self.firstViewScaleToFill = NO;
    }
    
    return self;
}

- (void)dealloc
{
    self.imageArray = nil;
    self.reuseImageViewSet = nil;
    self.displayImageViewArray = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:54.0/255 green:201.0/255 blue:204.0/255 alpha:1]];
    
    [self setupSubviews];
    [self setupGesture];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Life Cycle 结束
#pragma mark -

/**
 *  初始化所有ImageView
 */
- (void)setupSubviews {
    for (int i =0; i<self.maxSize; i++) {
        [self drawImageViewAtIndex:i WithImageAtIndex:i];
    }
}

/**
 *  插入一张新ImageView
 */
- (void)insertNewImageView {
    //下一张image的index就是当前index加上最大长度-1，另外要模一下
    NSInteger nextImageIndex = (self.curIndex + self.maxSize - 1) % self.imageArray.count;
    //在所有图片背后插入一张图片之后再统一往前移动,所以不用self.maxSize-1
    [self drawImageViewAtIndex:self.maxSize WithImageAtIndex:nextImageIndex];
}

/**
 *  根据ImageView所在的index和需要显示的图片index
 *  生成对应的ImageView，并根据viewIndex调整turansform
 */
- (void)drawImageViewAtIndex:(NSInteger)viewIndex WithImageAtIndex:(NSInteger)imageIndex {
    UIImageView *view = [self imageViewForReuse];
    
    UIImage *img = self.imageArray[imageIndex];
    [view setImage:img];
    
    view.frame = CGRectMake((kScreenWidth-288)/2, (kScreenHeight-432)/2, 288, 432);
    view.contentMode = UIViewContentModeScaleAspectFill;
    
    //设置transform
    [self imageView:view initTransformAtIndex:viewIndex];
    
    
    [self.view addSubview:view];
    [self.displayImageViewArray addObject:view];
}

/**
 *  返回可用的UIImageVeiw
 */
- (UIImageView *) imageViewForReuse {
    UIImageView *imageView = nil;
    if(self.reuseImageViewSet.count > 0){
        imageView = [self.reuseImageViewSet anyObject];
        [self.reuseImageViewSet removeObject:imageView];
    }
    
    if(!imageView){
        imageView = [[UIImageView alloc] init];
    }
    
    return imageView;
}

/**
 *  根据图片队列的index，和当前展示图片的inde，换算出某一index的图片应该展示在第几个
 */
- (NSInteger) displayIndexForImageIndex:(NSInteger)imageIndex {
    
    NSInteger displayIndex = (imageIndex - self.curIndex + self.maxSize)%self.maxSize;
    if(displayIndex < 0){
        return -1;
    }
    return displayIndex;
}

#pragma mark - 手势事件
- (void)setupGesture {
    //滑动手势
    UIPanGestureRecognizer *panGuesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGuesture];
    
    //点击手势
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGuesture];
}

/**
 *  panGesture响应事件
 */
- (void)handlePanGesture: (UIPanGestureRecognizer *)panGesture {
    CGPoint offset = [panGesture translationInView:panGesture.view];
    
    if(self.firstViewScaleToFill){
        return;
    }
    
    if(panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged){
        //开始滑动与滑动中
        for (int i =0; i<self.displayImageViewArray.count; i++) {
            UIImageView *view = self.displayImageViewArray[i];
            //设置动画位置
            [self imageView:view animateWithX:offset.x atIndex:i];
            
        }
        
    }else if(panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled){
        //开始结束
//        NSLog(@"panGesture is ended.");
        if(fabs(offset.x) > self.maxPanX){
            //移除第一张图片
            [self popupTheFirstImageViewWithX:offset.x];
            //复原
            [self recoveryImageViewTransformWithX:offset.x];
        }else{
            //复原
            [self recoveryImageViewTransformWithX:offset.x];
        }
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    UIImageView *firstView = self.displayImageViewArray[0];
    if(!self.firstViewScaleToFill){
        //
        CGPoint location = [tapGesture locationInView:firstView];
        if(location.x > 0 && location.y > 0 && location.x < firstView.bounds.size.width && location.y < firstView.bounds.size.height){
            NSLog(@"in View.");
            
            //动画，让第一张图片放大到全屏，并添加单击手势和缩放手势
            [self makeTheFirstImageViewScaleToFill];
        }
    }else if(self.firstViewScaleToFill){
        [self makeTheFirstImageViewScaleToDefault];
    }
}

#pragma mark - 初始位置
/**
 *  根据 index 设置 imageView 的初始位置
 */
- (void)imageView:(UIImageView *)view initTransformAtIndex:(NSInteger)i{
    //创建3D形变的transform
    CATransform3D perspective = CATransform3DIdentity;
    //设置矩阵中的m34属性
    perspective.m34 = -0.001;
    
    //设置imageView的layer的transform属性
    view.layer.transform = perspective;
    
    //改变layer的y轴上的位置：x,y,z轴上的偏移量
    view.layer.transform = CATransform3DTranslate(view.layer.transform, 0, i*-5, i*-5);
    
    //改变layer的缩放： x,y,z轴上的缩放
    view.layer.transform = CATransform3DScale(view.layer.transform, 1-0.08*i, 1, 1);
    
    //改变layer的旋转角度：绕x,y,z轴旋转‘弧度’
    view.layer.transform = CATransform3DRotate(view.layer.transform,-2*M_PI/180, 1, 0, 0);
    
    //改变layer的透明度
    view.layer.opacity = 1-0.1*(CGFloat)i;
    
    //
    view.layer.masksToBounds = YES;
    
    //下面的设置会消耗GPU性能
    //设置圆角
//    view.layer.cornerRadius = 5;
//    
//    
//    //设置阴影
//    view.layer.shadowColor = [UIColor grayColor].CGColor;
//    view.layer.shadowOpacity = 0.5f;
//    view.layer.shadowRadius = 5;
//    view.layer.shadowOffset = CGSizeMake(0, 5);
//    
//    
//    //光栅化
//    view.layer.shouldRasterize = YES;
//    view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    //    if(view.layer.opacity == 1){
    //        [view.layer setOpaque:YES];
    //        [view setOpaque:YES];
    //        [view setAlpha:1];
    //    }
    
}




#pragma mark - 滑动动画
/**
 *  根据 x 设置 ImageView 的 位置
 */
- (void)imageView:(UIImageView *)view animateWithX:(CGFloat)x atIndex:(NSInteger)i {
    
    CGFloat xForIndex = (1-(CGFloat)i/(CGFloat)self.displayImageViewArray.count ) * x ;
    
    //设置layer.transform.translation.x的绝对位置
    [view.layer setValue:@(xForIndex*0.6) forKeyPath:@"transform.translation.x"];
    
    //设置layer.transform.rotation.z 在z轴上的旋转角度
    [view.layer setValue:@(xForIndex / kScreenWidth / 3 * (30*M_PI/180)) forKeyPath:@"transform.rotation.z"];
    
}

#pragma mark - 复原动画
- (void)recoveryImageViewTransformWithX:(CGFloat)x {
    __weak typeof(self) wself = self;
    CGFloat duration = fabs(x) > self.maxPanX ? 0.1 : 0.5;
    CGFloat damping = fabs(x) > self.maxPanX ? 1 : 0.3;
    
    //usingSpringWithDamping
    [UIImageView animateWithDuration:duration
                               delay:0
              usingSpringWithDamping:damping
               initialSpringVelocity:1//越接近1，初始速度越快
                             options:0
     |UIViewAnimationOptionBeginFromCurrentState
//     |UIViewAnimationOptionCurveEaseIn
                          animations:^(){
                              
                              for (int i=0; i<self.displayImageViewArray.count; i++) {
                                  UIImageView *view = self.displayImageViewArray[i];
                                  //将偏移量置0
                                  [wself imageView:view animateWithX:0 atIndex:i];
                              }
                          }
                          completion:^(BOOL finished){
                              if(fabs(x) > self.maxPanX){
                                  //加入新的view
                                  [wself insertNewImageView];
                                  //统一向前滑动
                                  [wself makeImageViewMoveForward];
                              }
                          }];
}

#pragma mark - 去掉第一张图片
/**
 *  从队列和屏幕中移除该UIImageView
 */
- (void)popupTheFirstImageViewWithX:(CGFloat) x {
    //把第一张图片移出屏幕
    UIView *view = self.displayImageViewArray[0];
    //移除队列，需要先执行，等下复原动画时就不会包括此ImageView了
    [self.displayImageViewArray removeObject:view];
    //设置足够大的z轴，避免在移除动画时被第二张图片盖住
    [view.layer setValue:@(100) forKeyPath:@"transform.translation.z"];
    
    //提前把第二张图片alpha设为一，避免出现残影
    UIView *view1 = self.displayImageViewArray[1];
    view1.alpha = 1;
    
    //更新index
    self.curIndex ++ ;
    self.curIndex = self.curIndex % self.imageArray.count;
    
    //动画
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(){
        [view.layer setValue:@(x>0?kScreenWidth:-kScreenWidth) forKeyPath:@"transform.translation.x"];
    } completion:^(BOOL finished){
        //从界面移除
        [((UIImageView *)view) setImage:nil];
        [view removeFromSuperview];
        //重置x轴，设置足够小的z轴，并设置为透明，确保在重用此view时出现位置问题
        [view.layer setValue:@(0) forKeyPath:@"transform.translation.x"];
        [view.layer setValue:@(-100) forKeyPath:@"transform.translation.z"];
        view.alpha = 0;
        //添加到重用队列
        [self.reuseImageViewSet addObject:view];
    }];
    
}

#pragma mark - 前移动画
- (void)makeImageViewMoveForward {
    __weak typeof(self) wself = self;
    
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){
                         
                         for (int i=0; i<self.displayImageViewArray.count; i++) {
                             UIImageView *view = self.displayImageViewArray[i];
                             //将偏移量置0
                             [wself imageView:view initTransformAtIndex:i];
                         }

                         
                     }
                     completion:^(BOOL finished){
                     
                         
                         
                         
                     }];
    
    
    
}

#pragma mark - 点击动画
/**
 *  放大图片
 */
- (void)makeTheFirstImageViewScaleToFill {
    UIImageView *view = self.displayImageViewArray[0];
    
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){
                         view.frame = self.view.bounds;
                         view.layer.transform = CATransform3DIdentity;
                         [view.layer setValue:@(100) forKeyPath:@"transform.translation.z"];
                         view.layer.cornerRadius = 0;
                     }
                     completion:^(BOOL finished){
                         self.firstViewScaleToFill = YES;
                     }];

    
}
/**
 *  缩小图片
 */
- (void)makeTheFirstImageViewScaleToDefault {
    __weak typeof(self) wself = self;
    UIImageView *view = self.displayImageViewArray[0];
    
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){
                         
                         view.frame = CGRectMake((kScreenWidth-288)/2, (kScreenHeight-432)/2, 288, 432);
                         [wself imageView:view initTransformAtIndex:0];
                     }
                     completion:^(BOOL finished){
                         self.firstViewScaleToFill = NO;
                     }];
    
}
@end

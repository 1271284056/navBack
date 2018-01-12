//
//  JDNavController.m
//  全屏返回
//
//  Created by JiangDong Zhang on 2018/1/12.
//  Copyright © 2018年 zhizhangyi. All rights reserved.
//
//屏幕宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


#import "JDNavController.h"

@interface JDNavController ()<UIGestureRecognizerDelegate>
{
    //开始点击的位置
    CGPoint startTouch;
    //最后一张截图
    UIImageView *lastScreenShotView;
    //返回时,上一级页面蒙版
    UIView *blackMask;
}

//背景view
@property (nonatomic,strong) UIView *backgroundView;
//截屏图片数组
@property (nonatomic,strong) NSMutableArray *screenShotsList;
//是否动画中
@property (nonatomic,assign) BOOL isMoving;
//拖拽手势
@property (weak, nonatomic) UIPanGestureRecognizer *pan;

@end

@implementation JDNavController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.screenShotsList = [NSMutableArray new];
        self.needDissMiss = YES;
    }
    return self;
}

- (void)dealloc{
    self.screenShotsList = nil;
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //navigationBar 样式
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    //去掉原来的边缘侧滑手势
    self.interactivePopGestureRecognizer.enabled = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    //拖拽手势
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                   action:@selector(paningGestureReceive:)];
    [panRecognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
    self.pan = panRecognizer;
    
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 其它滑动手势必须等kkNavigationController识别失败，才允许启用
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    } else {
        return NO;
    }
}

//允许多个手势同时响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

//手势是否响应
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //是否是pan手势
    BOOL isPanGesture = ([self.pan isEqual:gestureRecognizer]);
    CGPoint point = [self.pan velocityInView:self.pan.view];

    // 如果是向左滑动，或者y轴的分量过大，那么不启用效果
    if (isPanGesture && (point.x < 0 || fabs(point.y) > fabs(point.x) / 2)) {
        return NO;
    }
    
    UIViewController *viewController = [self.viewControllers lastObject];
    // -Wundeclared-selector忽略performSelector导致的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    //如果子控制器里实现关闭侧滑手势方法return NO. 手势不生效.
    if (isPanGesture && [viewController respondsToSelector:@selector(QDNavigationControllerEnabled)]) {
        if ([viewController performSelector:@selector(QDNavigationControllerEnabled)] == NO) {
            return NO;
        }
    }
    //滑动时候,向右滑动在横向滑动的scrollView的话,滑动到scrollView的contentSize的x == 0时,(最左边)才能触发侧滑手势
    //有符合条件的ScrollView 特殊处理
    BOOL hasScroll = NO;
    //是否可以全屏返回
    BOOL needPop = NO;
    CGPoint pointNow = [gestureRecognizer locationInView:self.view];

    for (UIView *subVi in [self.viewControllers lastObject].view.subviews) {
        //这个scrollview包含这点 往右滑 contentSize宽度大于屏幕宽度 在最左边时候 系统手势被屏蔽 手动pop
        if ([subVi isKindOfClass:NSClassFromString(@"UIScrollView")]
            && ((UIScrollView *)subVi).contentSize.width > kScreenWidth
            ){
            hasScroll = YES;
            //scrollView的ContentSize 转成frame判断触摸点是否在scrollView上
            CGSize scrollContentSize = ((UIScrollView *)subVi).contentSize;
            CGRect contentSizeRect = CGRectMake(0, 0, scrollContentSize.width, scrollContentSize.height);
            //scrollView在最左边 触摸点在scrollView上 可以全屏返回
            if ( ((UIScrollView *)subVi).contentOffset.x == 0
                && CGRectContainsPoint( contentSizeRect, [self.view convertPoint:pointNow toView:subVi])
                ){
                [((UIScrollView *)subVi).panGestureRecognizer requireGestureRecognizerToFail:self.pan];
                needPop = YES;
                break;
            }
            //触摸点不在scrollView上 可以全屏返回
            if (hasScroll == YES && !CGRectContainsPoint( contentSizeRect, [self.view convertPoint:pointNow toView:subVi])) {
                needPop = YES;
                break;
            }
        }
        
    }
    
    //不是跟控制器,符合可以侧滑条件
    if (self.viewControllers.count > 1 && (hasScroll == NO || needPop == YES)) {
        if ([self needGoback] == NO) {
            return  NO;
        }else{
            return YES;
        }
    }else{
        if (self.viewControllers.count == 1
            && (hasScroll == NO || needPop == YES)
            && [self.pan translationInView:[self.viewControllers lastObject].view].x > 2) {
            //根控制器 符合条件 dismiss
            [self popOrDissMiss];
        }
        return NO;
    }
    
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.viewControllers.count >= 1 ) {
        viewController.hidesBottomBarWhenPushed = YES;
        //子控制器创建返回按钮
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self creatBackButton]];
        
        //截图
        UIImage *capture = [self _captureForNavigationController:self];
        
        // 有时会获得nil，为防止crash使用[NSNull null]放入数组
        if (capture) {
            [self.screenShotsList addObject:capture];
        } else {
            [self.screenShotsList addObject:[NSNull null]];
        }
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

//截图
- (UIImage *)_captureForNavigationController:(UINavigationController *)navigationController
{
    UIView *view = navigationController.view;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.window.screen.scale);
    
    /* iOS 7 */
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    else /* iOS 5,6 */
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}

//返回方法
- (void)popOrDissMiss{
    if ([self needGoback] == NO) {
        return ;
    }
    if (self.viewControllers.count == 1 && self.needDissMiss == YES) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self popViewControllerAnimated:YES];
}

//如果自控制器遵守协议 调用willGoBack方法
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
- (BOOL)needGoback{
    UIViewController *viewController = [self.viewControllers lastObject];
    //控制器里面实现QDNavigationControllerWillGoBack方法 并return NO可以取消销毁页面
    if ([viewController respondsToSelector:@selector(QDNavigationControllerWillGoBack)]) {
        if ([viewController performSelector:@selector(QDNavigationControllerWillGoBack)] == NO) {
            return NO;
        }
    }
    return YES;
}

#pragma clang diagnostic pop
//拖拽手势执行
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    if (self.screenShotsList.count <= 0) return;
    UIViewController *currentViewController = [self.viewControllers lastObject];
    
    CGPoint touchPoint = [recoginzer locationInView: [[UIApplication sharedApplication] keyWindow]];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        id lastScreenShotObject = [self.screenShotsList lastObject];
        UIImage *lastScreenShot;
        if (lastScreenShotObject == [NSNull null]) {
            lastScreenShot = nil;
        } else {
            lastScreenShot = lastScreenShotObject;
        }
        
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        
        [lastScreenShotView setFrame:CGRectMake(0,
                                                lastScreenShotView.frame.origin.y,
                                                lastScreenShotView.frame.size.height,
                                                lastScreenShotView.frame.size.width)];
        
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
        currentViewController.view.userInteractionEnabled = NO;
        currentViewController.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        currentViewController.view.layer.shouldRasterize = YES;
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        //销毁
        if (touchPoint.x - startTouch.x > 80)
        {
            [UIView animateWithDuration:0.2 animations:^{
                //适配大屏幕，同时解决了pop不能到屏幕最右边的现象和pop后 邮件列表 和 会话 toolbar重影的问题
                [self moveViewWithX:self.view.bounds.size.width];
            } completion:^(BOOL finished) {
                if (self.viewControllers.count > 1) {
                    [self popViewControllerAnimated:NO];
                }
                
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
            }];
        }
        else
        {//不销毁返回
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
                currentViewController.view.userInteractionEnabled = YES;
                currentViewController.view.layer.shouldRasterize = NO;
            }];
            
        }
        return;
        
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
            currentViewController.view.layer.shouldRasterize = NO;
        }];
        
        return;
    }
    
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

//开始移动
- (void)moveViewWithX:(float)x
{
    //x < 0时，view已经移动到了最左边了，不需要执行任何操作了
    if (x < 0) {
        return;
    }
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float alpha = 0.4 - (x/800);
    
    blackMask.alpha = alpha;
    
    // 直接将照片贴着屏幕底边展示即可
    id lastScreenShotObject = [self.screenShotsList lastObject];
    UIImage *lastScreenShot;
    if (lastScreenShotObject == [NSNull null]) {
        lastScreenShot = nil;
    } else {
        lastScreenShot = lastScreenShotObject;
    }
    
    CGFloat lastScreenShotViewHeight = lastScreenShot.size.height;
    CGFloat superviewHeight = lastScreenShotView.superview.frame.size.height;
    CGFloat y = superviewHeight - lastScreenShotViewHeight;
    
    CGFloat gapScale = 0;//间隙0.04 * (kScreenWidth - x) / kScreenWidth; // 0
    
    [lastScreenShotView setFrame:CGRectMake(gapScale * kScreenWidth,
                                            y + gapScale * lastScreenShotViewHeight,
                                            (1 - 2 * gapScale) * kScreenWidth,
                                            (1 - 2 * gapScale) * lastScreenShotViewHeight)];
    
}

//返回按钮
- (UIButton *)creatBackButton{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 44.0f)];
    [backButton setImage:[UIImage imageNamed:@"daylight-btn-left-arrow-normal"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"daylight-btn-left-arrow-highlighted"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(popOrDissMiss) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

@end

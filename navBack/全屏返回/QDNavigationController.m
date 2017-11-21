//
//  QDNavigationController.m
//  SecMail
//
//  Created by JiangDong Zhang on 2017/9/12.
//  Copyright © 2017年 Qiduo Tech, Inc. All rights reserved.
//
//屏幕宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "QDNavigationController.h"

@interface QDNavigationController ()<UIGestureRecognizerDelegate>
//拖拽手势
@property (weak, nonatomic) UIPanGestureRecognizer *pan;

@end

@implementation QDNavigationController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //navigationBar 样式
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    //   [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    //把系统侧滑手势添加到导航控制器view上
    NSArray *targets = [self.interactivePopGestureRecognizer valueForKey:@"_targets"];
    id  targetObjc = targets[0];
    id target = [targetObjc valueForKey:@"target"];
    NSString *actionStr = @"handleNavigationTransition:";
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(actionStr)];
    pan.delegate = self;
    self.pan = pan;
    [self.view addGestureRecognizer:pan];
    //去掉原来的边缘侧滑手势
    self.interactivePopGestureRecognizer.enabled = NO;
    self.needDissMiss = YES;
}

//手势是否生效
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    //是否是pan手势
    BOOL isPanGesture = ([self.pan isEqual:gestureRecognizer]);
    if ([self.pan translationInView:[self.viewControllers lastObject].view].x < 0 || !isPanGesture) {
        return NO;
    }
    
    UIViewController *viewController = [self.viewControllers lastObject];
    //如果子控制器里实现关闭侧滑手势方法return NO. 手势不生效. -Wundeclared-selector忽略警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (isPanGesture && [viewController respondsToSelector:@selector(QDNavigationControllerEnabled)]) {
        if ([viewController performSelector:@selector(QDNavigationControllerEnabled)] == NO) {
            return NO;
        }
    }
#pragma clang diagnostic pop
    
    //处理根视图左边缘侧滑 dismiss
    if (self.viewControllers.count == 1
        && isPanGesture
        && [self.pan translationInView:[self.viewControllers lastObject].view].x > 3
        && point.x <= 30) {
        [self popOrDissMiss];
        return NO;
    }
    
    //有符合条件的ScrollView 特殊处理
    BOOL hasScroll = NO;
    //是否可以全屏返回
    BOOL needPop = NO;
    if (self.viewControllers.count > 1) {
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
                    && CGRectContainsPoint( contentSizeRect, [self.view convertPoint:point toView:subVi])
                    ){
                    [((UIScrollView *)subVi).panGestureRecognizer requireGestureRecognizerToFail:self.pan];
                    needPop = YES;
                    break;
                }
                //触摸点不在scrollView上 可以全屏返回
                if (hasScroll == YES && !CGRectContainsPoint( contentSizeRect, [self.view convertPoint:point toView:subVi])) {
                    needPop = YES;
                    break;
                }
            }
        }
    }
    
    if (self.viewControllers.count > 1 && (hasScroll == NO || needPop == YES)) {
        if ([self needGoback] == NO) {
            return  NO;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //子控制器创建返回按钮
    if (self.viewControllers.count >= 1 ) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self creatBackButton]];
    }
    [super pushViewController:viewController animated:YES];
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
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


//返回按钮
- (UIButton *)creatBackButton{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 44.0f)];
    [backButton setImage:[UIImage imageNamed:@"daylight-btn-left-arrow-normal"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"daylight-btn-left-arrow-highlighted"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(popOrDissMiss) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

@end

//
//  TestViewController.m
//  全屏返回
//
//  Created by JiangDong Zhang on 2017/9/13.
//  Copyright © 2017年 zhizhangyi. All rights reserved.
//

#import "TestViewController.h"
#import "ViewController2.h"
#import "ViewController1.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface TestViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;


@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationItem.title = @"test";
    [self setUpUI];

    // Do any additional setup after loading the view.
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setTitle:@"push" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(btnclick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)btnclick{
    TestViewController *vc1 = [[TestViewController alloc] init];
    
    [self.navigationController pushViewController:vc1 animated:YES];
    
}
- (void)setUpUI{
    
    [self.view addSubview:self.scrollView];
    ViewController1 *vc1 = [[ViewController1 alloc] init];
    vc1.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, 300);
    
    [self addChildViewController:vc1];

    [self.scrollView addSubview:vc1.view];
    

    
    ViewController2 *vc2 = [[ViewController2 alloc] init];

    vc2.view.frame = CGRectMake(0, 0, kScreenWidth, 300);
    if (self.navigationController.viewControllers.count == 2) {
        vc2.view.backgroundColor = [UIColor blueColor];
    }
    [self addChildViewController:vc2];
    [self.scrollView addSubview:vc2.view];
}


- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300 )];
        _scrollView.contentSize = CGSizeMake(kScreenWidth * 2, 300 );
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}

@end

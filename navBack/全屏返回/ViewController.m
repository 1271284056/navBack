//
//  ViewController.m
//  全屏返回
//
//  Created by JiangDong Zhang on 2017/9/13.
//  Copyright © 2017年 zhizhangyi. All rights reserved.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "TestViewController.h"
#import "QDNavigationController.h"
#import "JDNavController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 40, 40)];
    [rightBtn setTitle:@"push" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(btnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
}

- (void)btnclick{
    TestViewController *vc1 = [[TestViewController alloc] init];
    
//    QDNavigationController *naviController = [[QDNavigationController alloc] initWithRootViewController:vc1];
//    naviController.needDissMiss = YES;
//    [self presentViewController:naviController animated:YES completion:nil];
    
    JDNavController *naviController = [[JDNavController alloc] initWithRootViewController:vc1];
    naviController.needDissMiss = YES;
    [self presentViewController:naviController animated:YES completion:nil];

}




@end

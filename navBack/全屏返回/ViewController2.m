//
//  ViewController2.m
//  全屏返回
//
//  Created by JiangDong Zhang on 2017/9/13.
//  Copyright © 2017年 zhizhangyi. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController2.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor brownColor];
    self.navigationItem.title = @"222";
    // Do any additional setup after loading the view.
    
    
  

}


- (BOOL)QDNavigationControllerWillGoBack{
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

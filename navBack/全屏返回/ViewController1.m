//
//  ViewController1.m
//  全屏返回
//
//  Created by JiangDong Zhang on 2017/9/13.
//  Copyright © 2017年 zhizhangyi. All rights reserved.
//

#import "ViewController1.h"
#import "ViewController2.h"

@interface ViewController1 ()

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.navigationItem.title = @"111";
    
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 40, 40)];
    [rightBtn setTitle:@"push" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(btnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
}

- (void)btnclick{
    ViewController2 *vc1 = [[ViewController2 alloc] init];
    
    [self.navigationController pushViewController:vc1 animated:YES];

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

//
//  JDNavController.h
//  全屏返回
//
//  Created by JiangDong Zhang on 2018/1/12.
//  Copyright © 2018年 zhizhangyi. All rights reserved.
//  整体返回(包含导航栏)

#import <UIKit/UIKit.h>

@interface JDNavController : UINavigationController

//present出来的根控制器,右滑dissmiss 默认关闭 NO
@property (nonatomic, assign) BOOL needDissMiss;


/* 子控制器写下面的方法 可以关闭全屏返回
 reture NO 关闭当前页面全屏返回效果  默认开启全屏返回
 - (BOOL)QDNavigationControllerEnabled{
 return NO;
 }
 
 子控制器将要pop或 dismiss时候调用  return NO 取消销毁页面,不取消销毁页面要 return YES;
 - (BOOL)QDNavigationControllerWillGoBack{
 return YES;
 }
 
 目前直接放在子控制器View上的scrollView都能自动实现滑动到最左边再手势返回,如果scrollView层级比较深,或者特殊情况下才允许手势返回如(需要手势在页面左侧滑动范围内才生效),需要实现下面方法,return YES后才能手势返回
 - (BOOL)QDNavigationControllerAllowDragBack:(UIGestureRecognizer *)gestureRecognizer{
 return YES;
 
 }
 
 */
@end

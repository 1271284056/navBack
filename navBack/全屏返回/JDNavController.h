//
//  JDNavController.h
//  全屏返回
//
//  Created by JiangDong Zhang on 2018/1/12.
//  Copyright © 2018年 zhizhangyi. All rights reserved.
//  截图返回,导航控制器整体可以返回

#import <UIKit/UIKit.h>

@interface JDNavController : UINavigationController

//根控制器是否是present出来的  根控制器右滑dissmiss
@property (nonatomic, assign) BOOL needDissMiss;
/* 子控制器写下面的方法 可以关闭全屏返回
 reture NO 关闭当前页面全屏返回效果  默认开启全屏返回
 - (BOOL)QDNavigationControllerEnabled{
 return NO;
 }
 
 pop或 dismiss时候调用  return NO 取消销毁页面,不取消销毁页面要 return YES;
 - (BOOL)QDNavigationControllerWillGoBack{
 return YES;
 }
 */
@end

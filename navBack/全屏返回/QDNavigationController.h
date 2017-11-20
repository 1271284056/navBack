//
//  QDNavigationController.h
//  SecMail
//
//  Created by JiangDong Zhang on 2017/9/12.
//  Copyright © 2017年 Qiduo Tech, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDNavigationController : UINavigationController

//根控制器是否是present出来的  根控制器右滑dissmiss
@property (nonatomic, assign) BOOL needDissMiss;

/* 自控制器写下面的方法 可以关闭全屏返回
 reture NO 关闭全屏返回效果  默认开启全屏返回
 - (BOOL)QDNavigationControllerEnabled;
 
 点击左上角返回按钮调用
 - (void)willGoBack;
 */

@end

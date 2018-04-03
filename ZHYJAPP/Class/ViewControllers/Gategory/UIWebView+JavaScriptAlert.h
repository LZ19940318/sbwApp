//
//  UIWebView+JavaScriptAlert.h
//  ZHYJAPP
//
//  Created by admin on 16/7/29.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (JavaScriptAlert) <UIAlertViewDelegate,UIWebViewDelegate>

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

//- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;


+ (UIWebView *)initWithSet:(NSString *)urlStr;
+ (UIWebView *)initWithSet;

@end

//
//  UIWebView+JavaScriptAlert.m
//  ZHYJAPP
//
//  Created by admin on 16/7/29.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "UIWebView+JavaScriptAlert.h"




@implementation UIWebView (JavaScriptAlert)

+ (UIWebView *)initWithSet:(NSString *)urlStr{
    
    
    UIWebView *_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, +44 ,MainWidth, MainHeight - 24) ];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scalesPageToFit = YES;//设置自适应
    _webView.scrollView.bounces = NO;//禁止下拉滚动
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:mainBundlePath isDirectory:YES];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath,urlStr];
    NSString *htmlStr = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlStr baseURL:baseURL];

    

    return _webView;
    
}



+ (UIWebView *)initWithSet{
    
    
    UIWebView *_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -44 ,MainWidth, MainHeight + 24) ];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scalesPageToFit = YES;//设置自适应
    _webView.scrollView.bounces = NO;//禁止下拉滚动
//    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:mainBundlePath isDirectory:YES];
//    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath,urlStr];
//    NSString *htmlStr = [NSString stringWithContentsOfFile:htmlPath
//                                                  encoding:NSUTF8StringEncoding error:nil];
//    [_webView loadHTMLString:htmlStr baseURL:baseURL];
//    
    
    
    return _webView;
    
}

//static BOOL diagStat = NO;

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame
{
    UIAlertView* dialogue = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [dialogue show];
}
bool diagStat;

-(BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame{
    UIAlertView* dialogue = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [dialogue show];
    while (dialogue.hidden==NO && dialogue.superview!=nil) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    }
    return diagStat;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        diagStat=YES;
        [self stringByEvaluatingJavaScriptFromString:@"iosSubDataChangeConfirm()"];

    }else if(buttonIndex==1){
        diagStat=NO;
    }
}


@end

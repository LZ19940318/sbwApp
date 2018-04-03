
//  missionTaskVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/1/10.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "missionTaskVC.h"


@interface missionTaskVC ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    NSString  *_urlString;
    NSString *callback;
}
@end

@implementation missionTaskVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_webView) {
        
        _webView = [UIWebView initWithSet];
        _webView.delegate = self;
//        if (![_paramStr isEqualToString:@"1"]) {
//            CGRect frame = _webView.frame;
//            frame.origin.y = -44;
//            frame.size.height = frame.size.height - 24;
//            _webView.frame = frame;
//        }
        CGRect frame = _webView.frame;
        frame.origin.y = -44;
        frame.size.height = frame.size.height - 44;
        _webView.frame = frame;

        
        
        [self.view addSubview:_webView];
        
    }
    
    
    //从mainBundle里取本地html文件
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath, self.urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",[htmlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    
    [_webView loadRequest:request];

    
}

#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{ //多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);
   
    //返回按钮
    if ([requestString hasSuffix:@"todo.html"]) {
//        [self postDataWithRequestStr:requestString];
        [self dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }

    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }
    //    退出登录,页面调用app.logout
    
   
    //页面切换时调用
//    if ([requestString hasPrefix:@"puturl"]) {
//        [self putWithRequestStr:requestString];
//        return YES;
//    }
    return YES;
}
//开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView
{
}
//加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
//        [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '120%'"];
    }else{
    }
    
    //webview加载完成后移除黑色视图，否则会覆盖本地html的导航栏
    //Html当中的js代码会引起内存泄露,设置缓存
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    // WebView放到最上层
    [self.view bringSubviewToFront:_webView];
}

//提交数据
- (void)postDataWithRequestStr:(NSString *)requestString
{
    NSArray  *components = [requestString componentsSeparatedByString:@"$$$"];
    NSString *urlString = [components objectAtIndex:1];//请求路径
    NSString *params = [components objectAtIndex:2];//请求参数
    //    NSString *callback = [components objectAtIndex:3];//回调函数
    NSRange range = [params rangeOfString:@"back"];//匹配得到的下标
    //    NSLog(@"rang:%@",NSStringFromRange(range));
    if (range.length == 0) {
        //        callback = [params substringWithRange:range];//截取范围类的字符串
        urlString = [urlString stringByReplacingOccurrencesOfString:@"app.server_address" withString:[DataManager sharedDataManager].hostString];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"app.ou" withString:[DataManager sharedDataManager].userMsg[@"ou"]];
        params = [params stringByReplacingOccurrencesOfString:@"app.ou" withString:[DataManager sharedDataManager].userMsg[@"ou"]];
        NSLog(@"ou===%@", [DataManager sharedDataManager].userMsg[@"ou"]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        //所有网络请求都需要带cookie
        NSString *cookie = [[DataManager sharedDataManager] cookieValue];
        [request setValue:cookie forHTTPHeaderField:@"Cookie"];
        request.HTTPMethod = @"POST";
        NSLog(@"%@", params);
        // 设置请求体
        // NSString --> NSData
        
        request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
        [NetworkManager networkWithRequest:request completion:^(id responseObject, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                NSLog(@"88888%@   ----%@", responseObject, requestString);
                NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"777%@", dataString);
                NSString *jsFunc=[callback stringByAppendingFormat:@"%@%@%@",@"(",dataString,@")"];
                NSLog(@"提交数据jsFunc: %@", jsFunc);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_webView stringByEvaluatingJavaScriptFromString:dataString];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络请求错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                });
            }
        }];
        
    }else{
        
        
        urlString = [urlString stringByReplacingOccurrencesOfString:@"app.server_address" withString:[DataManager sharedDataManager].hostString];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"app.ou" withString:[DataManager sharedDataManager].userMsg[@"ou"]];
        params = [params stringByReplacingOccurrencesOfString:@"app.ou" withString:[DataManager sharedDataManager].userMsg[@"ou"]];
        NSLog(@"ou===%@", [DataManager sharedDataManager].userMsg[@"ou"]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        //所有网络请求都需要带cookie
        NSString *cookie = [[DataManager sharedDataManager] cookieValue];
        [request setValue:cookie forHTTPHeaderField:@"Cookie"];
        request.HTTPMethod = @"POST";
        NSLog(@"%@", params);
        // 设置请求体
        // NSString --> NSData
        
        request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
        [NetworkManager networkWithRequest:request completion:^(id responseObject, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                NSLog(@"88888%@   ----%@", responseObject, requestString);
                NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"777%@", dataString);
                NSString *jsFunc=[callback stringByAppendingFormat:@"%@%@%@",@"(",dataString,@")"];
                NSLog(@"提交数据jsFunc: %@", jsFunc);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    [_webView stringByEvaluatingJavaScriptFromString:dataString];
                    [_webView stringByEvaluatingJavaScriptFromString:jsFunc];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                 
                    
                     [MsgToolBox  controller:self showAlert:@"温馨提示" content:@"网络请求错误"];
                });
            }
        }];
    }
}




@end

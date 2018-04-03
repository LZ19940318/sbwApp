//
//  ReportDetaiVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/22.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ReportDetaiVC.h"
#import "Mail_Document_VC.h"
#import "LinkViewController.h"

@interface ReportDetaiVC ()<UIWebViewDelegate>
{
    
    UIWebView *_webView;
    NSString *callback;
    NSString *timeStr;
    BOOL isRightClick;

}

@end

@implementation ReportDetaiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isRightClick = NO;
    
    self.title = @"";
    
    // 创建导航标题、按钮
    [self setNav];
    
    // 加载webView
    // [self initWebView];

}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self initWebView];


}

#pragma mark init

- (void)initWebView{
    
    if (!_webView) {
        
        _webView = [UIWebView initWithSet];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    
    //从mainBundle里取本地html文件
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath, self.urlS];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",[htmlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    [_webView loadRequest:request];
    
    
}


- (void)setNav{
  
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [rightButton setTitle:@"回复" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBtn;

    
    
 
}
#pragma mark Click

- (void)rightClick{
    
    [_webView stringByEvaluatingJavaScriptFromString:@"reply();"];
    isRightClick = YES;
   
    
    
}


#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);
    
    
     NSArray *unidArray = [requestString componentsSeparatedByString:@".app/"];
     if (unidArray.count > 1) {
         
         if (isRightClick == YES) {
         
         if ([unidArray.lastObject hasPrefix:@"mail/newMail.html"]) {
             
             Mail_Document_VC *mail = [[Mail_Document_VC alloc]init];
             mail.urlStr = unidArray.lastObject;
             [self.navigationController pushViewController:mail animated:YES];
             isRightClick = NO;
             
             return YES;
             
             
         }
         }
     }
    
    if ([requestString hasPrefix:@"http://"]) {
        
        LinkViewController *link = [[LinkViewController alloc]init];
        link.urlStr = requestString;
        [self.navigationController pushViewController:link animated:YES];
        
    }
    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }
    return YES;
    
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
                
                NSString *jsFunc=[callback stringByAppendingFormat:@"%@%@%@",@"(",dataString,@")"];
                NSLog(@"提交数据jsFunc: %@", jsFunc);
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([dataString isEqualToString:@"alert('发送成功!')"]) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
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
        NSLog(@"截取的值为：%@",callback);
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
                    [_webView stringByEvaluatingJavaScriptFromString:jsFunc];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络请求错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                });
            }
        }];
    }
}


@end

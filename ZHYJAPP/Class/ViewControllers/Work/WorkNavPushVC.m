//
//  WorkNavPushVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "WorkNavPushVC.h"
#import "Work_Document_VC.h"


@interface WorkNavPushVC ()<UIWebViewDelegate>{
    
    UIWebView *_webView;
    UIBarButtonItem *rightButton;
    BOOL isClickSub; // 防止重复提交
    NSString *lastRequest;
}

@end

@implementation WorkNavPushVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setNav];
  
   
    
    

    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self initWebView];

}
#pragma mark -- init
- (void)setNav{
    
    
    isClickSub = NO;
    rightButton = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(rightClick)];
   
    if ([self.urlStr isEqualToString:@"oa/readTodoListHad.html"]) {
        self.title = @"已读文件列表";
        rightButton = [[UIBarButtonItem alloc]initWithTitle:@"首页" style:UIBarButtonItemStyleDone target:self action:@selector(rightClick1)];

    }
    [rightButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem=rightButton;
    
    
    
}



- (void)initWebView{
    
    if (!_webView) {
        
        _webView = [UIWebView initWithSet];
        _webView.delegate = self;
        [self.view addSubview:_webView];
        
        
    }
    
    //从mainBundle里取本地html文件
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath, self.urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",[htmlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    [_webView loadRequest:request];
    
}

#pragma mark -- Click
- (void)rightClick{

    if (isClickSub == NO) {
        
        [_webView stringByEvaluatingJavaScriptFromString:@"getdata1();"];

    }
    
}

- (void)rightClick1{
    
  [self.navigationController popToRootViewControllerAnimated:YES];     
}

#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);

    
    if ([lastRequest isEqualToString:requestString]) {
        return YES;
    }
    
    lastRequest = requestString;
    NSArray *appArray = [requestString componentsSeparatedByString:@"app/"];
    
    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }
    
    
    if ([appArray[1] hasPrefix:@"oa/readDoc.html"]) {
        
        Work_Document_VC *doc = [[Work_Document_VC alloc]init];
        doc.urlStr = appArray[1];
        [self.navigationController pushViewController:doc animated:YES];
    }

    
    return YES;
    
}


//提交数据
- (void)postDataWithRequestStr:(NSString *)requestString
{
    
    isClickSub = YES;
    NSArray  *components = [requestString componentsSeparatedByString:@"$$$"];
    NSString *urlString = [components objectAtIndex:1];//请求路径
    NSString *params = [components objectAtIndex:2];//请求参数
    
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
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{

                    // 我的日志，新增，发送成功后，返回到上个界面
                if ([dataString isEqualToString:@"back('true')"]) {
                    
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
        
    
    
}


@end

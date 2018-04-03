//
//  TwoViewController.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/5/22.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "TwoViewController.h"

@interface TwoViewController ()<UIWebViewDelegate>
{
    
    UIWebView *_webView;
    UIButton *editButton;
}

@end

@implementation TwoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;

    [self initWebViewWith:self.urlStr];
  
}

#pragma mark -- init

- (void)initWebViewWith:(NSString *)url{
    
    if (!_webView) {
        _webView = [UIWebView initWithSet];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    
    
    //从mainBundle里取本地html文件
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath, url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",[htmlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    
    
    
}


- (void)setNav{
    self.title = @"个性设置";
    
    
    if ([self.urlStr isEqualToString:@"Modify_password.html"]) {
        self.title = @"";
    }else{
        
        self.title = @"个性设置";
        
        
        editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [editButton setTitle:@"编辑" forState:UIControlStateSelected];
        [editButton setTitle:@"提交" forState:UIControlStateNormal];
        [editButton setTintColor:[UIColor whiteColor]];
        [editButton addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
        editButton.selected = YES;
        
        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:editButton];
        self.navigationItem.rightBarButtonItem=rightBtn;
    }
    
}
#pragma mark -- Click

- (void)rightClick:(UIButton *)sender{
    

    if (sender.selected) {
        [_webView stringByEvaluatingJavaScriptFromString:@"editData();"];
        
    }else{
        [_webView stringByEvaluatingJavaScriptFromString:@"getdata1();"];
        
    }
    
    
    
    editButton.selected = NO;
    
    
}

#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);
    
    //根据
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
    
//    [self.navigationController popViewControllerAnimated:YES];

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
            NSLog(@"88888%@   ----%@", responseObject, requestString);
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
           
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
        
   
    
}

- (void)dealloc{
    
    _webView.delegate = nil;
    [_webView stopLoading];
}

@end

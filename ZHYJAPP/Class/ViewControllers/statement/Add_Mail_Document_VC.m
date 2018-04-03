//
//  Work_Document_VC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "Add_Mail_Document_VC.h"

@interface Add_Mail_Document_VC ()<UIWebViewDelegate>{
    
    UIWebView *_webView;
    NSString *timeStr;
    NSString *callback;
    BOOL isShowButton;
    BOOL isChangeButton;
    UIButton *editButton;
    NSString *requestString;
}

@property (nonatomic ,strong)NSDictionary *titleDic;

@end

@implementation Add_Mail_Document_VC

- (NSDictionary *)titleDic{
    if (_titleDic) {
        _titleDic = @{
                      @"crm/Hot_customer_document.html":@"新增客户",
                      @"crm/Sales_opportunities_document.html":@"新增机会",
                      @"crm/cusFile_document.html":@"客户档案",
                      @"work/daily_document.html":@"我的日报"
                      };
        
    };
    return _titleDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
  
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

    
    [self initWebView];
    
}

- (void)setNav{
    
    if ([self.urlStr hasPrefix:@"oa/doc.html"]) {
        self.title = @"处理文件";
    }

    
    if ([self.urlStr hasPrefix:@"work/daily_document.html"]) {
        self.title = @"处理文件";
        isShowButton = YES;
    }
    
    if ([self.urlStr hasPrefix:@"ProjectInput_document.html"]) {
        self.title = @"项目录入";
        isShowButton = YES;
    }
    
    if (isShowButton) {
        
        
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

- (void)rightClick:(UIButton *)sender{
    
    
    if (sender.selected) {
        [_webView stringByEvaluatingJavaScriptFromString:@"editData();"];
        
    }else{
        [_webView stringByEvaluatingJavaScriptFromString:@"getdata1();"];
        
    }
    
    
    
    editButton.selected = NO;
    
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


#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);
    
    
    
    
    //根据
    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }
    
    if ([requestString hasSuffix:@"saletab.html"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    if ([requestString hasSuffix:@"product-count.html"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    if ([requestString hasSuffix:@"dproduct-tab.html"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    
    if ([requestString hasSuffix:@"subClick"]) {
        
        isShowButton = YES;
        [self setNav];
        editButton.selected = NO;
        
        NSLog(@"------");
        
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
                        
                        //                NSString *jsFunc=[callback stringByAppendingFormat:@"%@%@%@",@"(",dataString,@")"];
                        NSLog(@"dataString: %@", dataString);
                        
                        
                        
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
//                                if ([dataString isEqualToString:@"true"]) {
//                                    [_webView stringByEvaluatingJavaScriptFromString:@"back1();"];
//                                    
//                                    
//                                    
//                                    [self.navigationController popViewControllerAnimated:YES];
//                                    
//                                    
//                                }else{
//                                    
//                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                                    [alert show];
//                                    
//                                    
//                                }
//                            
                            
                            
                            
                                if ([dataString isEqualToString:@"alert('成功')"]) {
                                    
                                    [self.navigationController popViewControllerAnimated:YES];
                                }else{
                                    
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                                                        [alert show];

                                    
                                }
                                [_webView stringByEvaluatingJavaScriptFromString:dataString];
                        });
                        
                    }
                    else{
                        
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
                            
                            //                NSString *jsFunc=[callback stringByAppendingFormat:@"%@%@%@",@"(",dataString,@")"];
                            
                            //                NSLog(@"提交数据jsFunc: %@", jsFunc);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [self.navigationController popViewControllerAnimated:YES];

                                
                                if ([dataString isEqualToString:@"back('true')"]) {
                                    //                    [_webView stringByEvaluatingJavaScriptFromString:@"back1();"];
                                    
                                    
                                    
//                            [self.navigationController popViewControllerAnimated:YES];
                                    
                                    
                                }else{
                                    
//                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                                    [alert show];
                                    
                                    
                                }
                                
                                
                                [_webView stringByEvaluatingJavaScriptFromString:dataString];
                                //                    [_webView stringByEvaluatingJavaScriptFromString:jsFunc];
                                
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

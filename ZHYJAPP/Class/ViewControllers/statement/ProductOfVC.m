//
//  ProductOfVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/20.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ProductOfVC.h"
#import "ReportDetaiVC.h"
#import "Mail_Document_VC.h"
#import "Mail_Document.h"


@interface ProductOfVC ()<UIWebViewDelegate>
{
    
    UIWebView *_webView;
}
@end

@implementation ProductOfVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // 设置标题
    [self setTitle];
    
    // 创建WebView
    [self initWebView];
    
    

}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

}

// 设置标题
- (void)setTitle{
    
    if ([self.urlS isEqualToString:@"mail/sendList.html"]) {
        
        self.title = @"发件箱";
        
    }else if([self.urlS isEqualToString:@"mail/dragList.html"]){
        
        self.title = @"草稿箱";
        
    }else if([self.urlS isEqualToString:@"mail/readMailList.html"]){
        
        self.title = @"已读邮件";
        
    }
    
    
    
    
    
}


- (void)initWebView{
    
    if (!_webView) {
        
        _webView = [UIWebView initWithSet];
        _webView.delegate = self;
        [self.view addSubview:_webView];

    }
    
    NSString *mainBundlePaht = [[NSBundle mainBundle]bundlePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@",mainBundlePaht,self.urlS];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",[htmlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    [_webView loadRequest:request];
    
}

#pragma mark -- UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
   NSString *requestString = [[request URL] absoluteString];
    
  

    NSArray *unidArray = [requestString componentsSeparatedByString:@"?unid="];
    
    
    if (unidArray.count > 1) {
        
        // 发件箱
        
        if ([self.urlS isEqualToString:@"mail/sendList.html"]) {
            
            if ([unidArray.firstObject hasSuffix:@"mail/send.html"]) {
                
                Mail_Document *reportVC = [[Mail_Document alloc]init];
                reportVC.urlStr = [NSString stringWithFormat:@"mail/send.html?unid=%@",unidArray.lastObject];
           
                    [self.navigationController pushViewController:reportVC animated:YES];
                
                
                
                return YES;

            }
            
        }
        
        // 草稿箱
        if([self.urlS isEqualToString:@"mail/dragList.html"]){

            
            if ([unidArray.firstObject hasSuffix:@"mail/newMail.html"]) {
                
                Mail_Document_VC *reportVC = [[Mail_Document_VC alloc]init];
                reportVC.urlStr = [NSString stringWithFormat:@"mail/newMail.html?unid=%@",unidArray.lastObject];
                [self.navigationController pushViewController:reportVC animated:YES];


                return YES;

                
            }

            
        }
        
        // 已读
        if([self.urlS isEqualToString:@"mail/readMailList.html"]){
            
            
            if ([unidArray.firstObject hasSuffix:@"mail/mail.html"]) {
                
                ReportDetaiVC *reportVC = [[ReportDetaiVC alloc]init];
                reportVC.urlS = [NSString stringWithFormat:@"mail/mail.html?unid=%@",unidArray.lastObject];
                [self.navigationController pushViewController:reportVC animated:YES];
                
                
                return YES;
                
                
            }
            
            
        }
        
        
        

        
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
    NSString *callback = [params substringWithRange:range];//截取范围类的字符串
    //    NSLog(@"截取的值为：%@",str);
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@"app.server_address" withString:[DataManager sharedDataManager].hostString];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"app.ou" withString:[DataManager sharedDataManager].userMsg[@"ou"]];
    params = [params stringByReplacingOccurrencesOfString:@"app.ou" withString:[DataManager sharedDataManager].userMsg[@"ou"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    //所有网络请求都需要带cookie
    NSString *cookie = [[DataManager sharedDataManager] cookieValue];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    request.HTTPMethod = @"POST";
    //    NSLog(@"%@", request.allHTTPHeaderFields);
    // 设置请求体
    // NSString --> NSData
    
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    [NetworkManager networkWithRequest:request completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString *jsFunc=[callback stringByAppendingFormat:@"%@%@%@",@"(",dataString,@")"];
            // NSLog(@"提交数据jsFunc: %@", jsFunc);
            dispatch_async(dispatch_get_main_queue(), ^{
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



@end

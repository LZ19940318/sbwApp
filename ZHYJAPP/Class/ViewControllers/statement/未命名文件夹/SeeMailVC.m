//
//  ReportDetaiVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/22.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "SeeMailVC.h"

#import "Mail_Document_VC.h"




#import "ChooseDataView.h"




@interface SeeMailVC ()<UIWebViewDelegate>
{
    
    UIWebView *_webView;
    NSString *callback;
    NSString *timeStr;

}
@property (nonatomic ,strong)NSDictionary *titleDic;

@end

@implementation SeeMailVC

- (NSDictionary *)titleDic{
    
    if (!_titleDic) {
        
        _titleDic = @{
                      @"report/cnOrderDetail.html":@"销售订单",
                      @"chinaWare-alyz_Ram.html":@"",
                      @"report/cnSaleOrderReport.html":@"销售月报",
                      @"chinaWare-alyz.html?key=jq":@"进球分析",
                      @"chinaWare-alyz.html?key=jl":@"精炼分析",
                      @"chinaWare-alyz.html?key=nt":@"泥条领料分析",
                      @"chinaWare-alyz.html?key=cx":@"成型车间分析",
                      @"chinaWare-alyz_three.html?key=cc":@"成瓷统计",
                      @"chinaWare-alyz_three.html?key=zn":@"制泥损耗分析",
                      @"chinaWare-alyz_three.html?key=cxsh":@"成型损耗分析",
                      @"chinaWare-alyz_three.html?key=sc":@"烧成损耗按产品",
                      @"chinaWare-alyz_three.html?key=pb":@"烧成损耗按排班",
                      };
    }
    return _titleDic;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleDic[self.urlS];

    // 创建导航标题、按钮
    [self setNav];
    
    // 加载webView
    [self initWebView];

}



#pragma mark init
- (void)setNav{
  
    /** 报表模块下，子界面共用一个界面，区分导航的显示*/
    
    // 销售订单页面导航栏没有 右按钮
//    if (![self.title isEqualToString:@"销售订单"]) {
//        
//        UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//       
//        UIImage *image2 = [UIImage imageNamed:@"date.png"];
//
//         // 应收款 页面，没有标题，且右按钮图片不一样
//        if ([self.title isEqualToString:@""]) {
//            
//
//            image2 = [UIImage imageOriginalWithName:@"share.png"];
//            // 设置tag值，区别是”选择日期“跟”分享“
//            rightButton.tag = 10;
//  
//        }
//        [rightButton setBackgroundImage:image2 forState:UIControlStateNormal];
//        [rightButton addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
//        
//        self.navigationItem.rightBarButtonItem=rightBtn;
//        
//    }
    
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [rightButton setTitle:@"回复" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBtn;

    
    
 
}
- (void)rightClick{
    
    Mail_Document_VC *mail = [[Mail_Document_VC alloc]init];
    mail.urlStr = [NSString stringWithFormat:@"mail/newMail.html?unid=%@",self.unid];
    [self.navigationController pushViewController:mail animated:YES];
    
    
}


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

#pragma mark Click
- (void)rightClick:(UIButton *)sender{
    
      // tag = 10 为分享，页面功能无需分享
    if(sender.tag != 10){
        
        ChooseDataView *chooseDataView = [[ChooseDataView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTagBlock:^(NSInteger buttonTag) {
            
            // 封装选择日期类，tag = 20 ，为确认按钮 tag = 10 为取消
            if (buttonTag == 20) {
                
                [self ChangeTitle];
            }
            
        } withTimeStr:^(NSString *timeString) {
            
            timeStr = timeString;
            
        }];
        
        [self.view addSubview:chooseDataView];
        
    }
    
    
}


-(void)ChangeTitle {
    
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"onchangeDateiOS('%@')", timeStr]];
    
    // 当前的标题 + 选择的日期
    self.title =  [NSString stringWithFormat:@"%@ %@", _titleDic[self.urlS],timeStr];
    
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
    
    if ([requestString hasSuffix:@"rili"]) {
        //自定义时间选择器
      // 与界面交互的日历已取消，改为点击导航栏右按钮
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

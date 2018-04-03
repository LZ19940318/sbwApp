//
//  Work_Document_VC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "Work_Document_VC.h"

@interface Work_Document_VC ()<UIWebViewDelegate>{
    
    UIWebView *_webView;
    BOOL isShowButton;
    UIButton *editButton;

}

@property (nonatomic ,strong)NSDictionary *titleDic;

@end

@implementation Work_Document_VC



- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setNav];
  
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

    [self initWebView];
    
}

#pragma mark  -- init

- (NSDictionary *)titleDic{
    if (_titleDic) {
        _titleDic = @{
                      @"crm/Hot_customer_document.html":@"新增客户",
                      @"crm/Sales_opportunities_document.html":@"新增机会",
                      @"crm/cusFile_document.html":@"客户档案",
                      @"work/daily_document.html":@"我的日报",
                      @"todo/payment_cost.html":@"费用类付款申请",
                      @"todo/fund_plan.html":@"资金计划审批",
                      @"todo/payment_purchase.html":@"采购类付款申请",
                      @"todo/payment_special.html":@"专项类付款申请"
                      
                      
                      };
        
    };
    return _titleDic;
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
    
    if ([self.urlStr hasPrefix:@"todo/fund_plan.html"]) {
        self.title = @"资金计划审批";
        isShowButton = YES;
    }
    
    if ([self.urlStr hasPrefix:@"todo/payment_cost.html"]) {
        self.title = @"付费用类付款申请";
        isShowButton = YES;
    }
    
   
    if ([self.urlStr hasPrefix:@"todo/payment_special.html"]) {
        self.title = @"专项类付款申请";
        isShowButton = YES;
    }
    if ([self.urlStr hasPrefix:@"todo/payment_purchase.html"]) {
        self.title = @"采购类付款申请";
        isShowButton = YES;
    }
    
    if (isShowButton) {
        
        
        editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [editButton setTitle:@"编辑" forState:UIControlStateSelected];
        [editButton setTitle:@"提交" forState:UIControlStateNormal];
        [editButton setTintColor:[UIColor whiteColor]];
        editButton.selected = YES;

        // @"todo/payment_purchase.html" @"todo/payment_cost.html" @"todo/payment_special.html"
        if ([self.urlStr hasPrefix:@"todo/payment_cost.html"]||[self.urlStr hasPrefix:@"todo/fund_plan.html"]||[self.urlStr hasPrefix:@"todo/payment_purchase.html"]||[self.urlStr hasPrefix:@"todo/payment_special.html"]) {
            
            [editButton setTitle:@"审批" forState:UIControlStateSelected];
            [editButton setTitle:@"审批" forState:UIControlStateNormal];
        }

        [editButton addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:editButton];
        self.navigationItem.rightBarButtonItem=rightBtn;
        
    }
    
    
    
    
}

#pragma mark -- Click

- (void)rightClick:(UIButton *)sender{
    // checkBox
    
    
    
    NSLog(@"----- %@",sender.currentTitle);
    
    if ([sender.currentTitle isEqualToString:@"编辑"]) {
        
        
        
    }else if([sender.currentTitle isEqualToString:@"提交"]){
        if (sender.selected == YES) {
            [_webView stringByEvaluatingJavaScriptFromString:@"editData();"];

        }else{
        
        [_webView stringByEvaluatingJavaScriptFromString:@"getdata1();"];
            
        }
    }else if([sender.currentTitle isEqualToString:@"审批"]){
        
        [_webView stringByEvaluatingJavaScriptFromString:@"checkBox();"];

    }
    
    
    
    editButton.selected = NO;
    
}

#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);
    
    
    
    
    // 判断是否显示标题，根据拦截的 right_title
    NSString *transStr = [NSString stringWithString:[requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSArray *titleSeparate = [transStr componentsSeparatedByString:@"right_title="];
    if (titleSeparate.count > 1) {
        // 文件中心 - > 选择文件 ，右边导航栏显示 right_title
        [editButton setTitle:titleSeparate.lastObject forState:UIControlStateNormal];
        
    }
    
    
    //根据
    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }
    
    if ([requestString hasSuffix:@"sub"]) {
        
        isShowButton = YES;
        [self setNav];
        editButton.selected = NO;
        
        
    }
    
    return YES;
    
}

//提交数据
- (void)postDataWithRequestStr:(NSString *)requestString
{
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
                
                NSLog(@"dataString: %@", dataString);

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_webView stringByEvaluatingJavaScriptFromString:dataString];

                        if ([dataString isEqualToString:@"alert('提交成功!');location.href='todo.html'"]) {
                            [self.navigationController popViewControllerAnimated:YES];
                            isShowButton = NO;
                            [self setNav];

                           
                        }
                      [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"callback('%@')",dataString]];
                });
                
            }
            else{
                
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络请求错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        
                    });
            }
        }];
    

}


@end

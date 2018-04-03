//
//  NewsVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 16/9/29.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "WorksVC.h"
#import "WorkDetailVC.h"


@interface WorksVC ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    NSMutableDictionary *_userIcon;
    NSString *transString;
    
}

@end

@implementation WorksVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"应用";


    
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self initWebView];


    // 页面进入的时候，就开始加载，当返回到界面的时候，可以刷新数据界面

}

#pragma mark 加载网页
- (void)initWebView{
    
    
    if (!_webView) {
        _webView = [UIWebView initWithSet];
        _webView.delegate = self;
        
        // 重写webView的位置
        CGRect frame = _webView.frame;
        frame.origin.y = 0;
        _webView.frame = frame;
        [self.view addSubview:_webView];
    }
    

    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:mainBundlePath isDirectory:YES];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath,@"work.html"];
    NSString *htmlStr = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlStr baseURL:baseURL];
    
    
    
}


#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);

    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }
    
    
    transString = [NSString stringWithString:[requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSArray *urlArray = @[@"oa/todo.html",// 待审批
                          @"oa/newDoc.html?unid=B2C1D2303CF98E0C4825811F001FA515&wfpath=combestbkc/oa/combest_jtqxj.nsf&flowName=集团请销假管理", // 请销假
                          @"work_signin/signIn.html",//签到
                          @"work/daily_list.html", // 日志
                          
                          @"oa/todo.html",// 审批
                          @"todo/plan_list.html", // 资金计划
                          @"todo/pay_list.html",  // 付款申请
                          @"oa/send_list.html",   // 公告
                          @"oa/readTodoList.html", // 待阅文件
                          @"arc/arc.html",      // 文件中心
                          @"work/calendar.html",  // 万年历
                          
                          @"https://common.diditaxi.com.cn/general/webEntry?wx=true#/",
                          @"https://touch.qunar.com/hotel/",
                          @"https://touch.qunar.com/h5/flight/"
                          ];
    for (NSString *urlStr  in urlArray) {
        
       
        if ([transString hasSuffix:urlStr]) {

            WorkDetailVC *workDetailVC = [[WorkDetailVC alloc]init];
            workDetailVC.urlStr = urlStr;
            [self.navigationController pushViewController:workDetailVC animated:YES];
            return YES;
        }
        
    }
    
    
    return YES;
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
    [_webView stringByEvaluatingJavaScriptFromString:@"onchangeDate('1')"];
    
    [self.view bringSubviewToFront:_webView];
}

#pragma mark - 与JS交互

//提交数据
- (void)postDataWithRequestStr:(NSString *)requestString
{
    NSArray  *components = [requestString componentsSeparatedByString:@"$$$"];
    NSString *urlString = [components objectAtIndex:1];//请求路径
    NSString *params = [components objectAtIndex:2];//请求参数
    
    
    // 替换地址域名
    urlString = [urlString stringByReplacingOccurrencesOfString:@"app.server_address" withString:[DataManager sharedDataManager].hostString];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"app.ou" withString:[DataManager sharedDataManager].userMsg[@"ou"]];
    params = [params stringByReplacingOccurrencesOfString:@"app.ou" withString:[DataManager sharedDataManager].userMsg[@"ou"]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    //所有网络请求都需要带cookie
    NSString *cookie = [[DataManager sharedDataManager] cookieValue];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    request.HTTPMethod = @"POST";
    
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    [NetworkManager networkWithRequest:request completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 根据返回的数据，与h5交互
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



//更改状态栏字体为白色  (默认为黑色)
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



@end

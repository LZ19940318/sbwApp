
//  ZHYJWebViewController.m
//  ZHYJAPP
//
//  Created by admin on 16/4/27.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ZHYJWebViewController.h"

#import "DataEncoding.h"
#import "ZHYJLocalCache.h"
//#import <CloudPushSDK/CloudPushSDK.h>
#import "Reachability.h"
#import "RedpacketViewControl.h"

#import "MyVC.h"
#import "ReportDetaiVC.h"
#import "ProductOfVC.h"
#import "PlanView.h"

#import "ReportDetaiVC.h"
#import "Mail_Document_VC.h"

#import "PopViewController.h"

static NSString *const sUserIconKey = @"UserIcon";

@interface ZHYJWebViewController () <UIWebViewDelegate, UIImagePickerControllerDelegate,CLLocationManagerDelegate,UIPopoverPresentationControllerDelegate>
{
    UIWebView *_webView;
    NSString  *_urlString;
    CLLocationManager *_locationManager;
    NSMutableArray *userLocationArr;
    NSString *timeStr;
    PlanView *_planView;
    BOOL isSelectPlan;
    PopViewController *_popVC;
    // 右边添加弹出试图按钮
    UIButton *rightButton;
    
}

@property (nonatomic,retain) NSURLConnection *aSynConnection;
@property (nonatomic,retain) NSInputStream *inputStreamForFile;
@property (nonatomic,retain) NSString *photoFilePath;


@end

@implementation ZHYJWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"新邮件";
    
    isSelectPlan = NO;

  
    [self setNav];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popClick:) name:@"popClick" object:nil];
    NSArray *array = [[DataManager sharedDataManager] IMUserlist];
    
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;

    [self loadWebview:@"mail/mailList.html"];

}



#pragma mark -- init

- (void)loadWebview:(NSString *)urlStr{
    
    
    if (!_webView) {
        
        _webView = [UIWebView initWithSet];
        _webView.delegate = self;
        
        CGRect frame = _webView.frame;
        frame.origin.y = 0;
        _webView.frame = frame;
        [self.view addSubview:_webView];
    }
    
    
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath,urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",[htmlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    
    [_webView loadRequest:request];
    
  
    
    
}


- (void)setNav{
    
    
    // 右边添加弹出试图按钮
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50, 10, 22, 22)];
    [rightButton addTarget:self action:@selector(rightClick1) forControlEvents:UIControlEventTouchUpInside];
    
    [rightButton setBackgroundImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    
    // 左边刷新按钮
    UIButton *rightButton1 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50, 10, 40, 22)];
    [rightButton1 addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
    [rightButton1 setTitle:@"刷新" forState:UIControlStateNormal];
    
 
    UIBarButtonItem *rightButtonItem1 = [[UIBarButtonItem alloc]initWithCustomView:rightButton1];
    self.navigationItem.leftBarButtonItem = rightButtonItem1;
    

    
}

#pragma mark Click

- (void)leftClick{
    
    [self loadWebview:@"mail/mailList.html"];
    
}

- (void)rightClick1{
    
    /*
     
     [pover setSourceView:self.view];//设置在哪个控制器里面弹出来
     [pover setSourceRect:btn.frame];//设置弹出视图的位置。
     [pover setPermittedArrowDirections:UIPopoverArrowDirectionAny];//设置弹出类型为任意
     
     **/
    
    _popVC = [[PopViewController alloc]init];
    _popVC.modalPresentationStyle = UIModalPresentationPopover;
//    _popVC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    _popVC.popoverPresentationController.sourceView = rightButton;
    _popVC.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    _popVC.popoverPresentationController.delegate = self;
    _popVC.preferredContentSize = CGSizeMake(300, 300);
    _popVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
//    [_popVC.popoverPresentationController setSourceView:(UIView *)self.navigationItem.rightBarButtonItem];
    CGRect rect = rightButton.bounds;
    rect.size.width = 100;
    rect.size.height = 44;
    [_popVC.popoverPresentationController setSourceRect:rect];

    
    [self presentViewController:_popVC animated:YES completion:nil];
    
}

- (void)rightClick{
    
    
    // 判断是否为选择状态
    
    if (isSelectPlan == YES) {
        
        isSelectPlan = NO;
        [_planView removeFromSuperview];
        
        return;
    }
    
    isSelectPlan = YES;

    
    if (!_planView) {
        _planView = [[PlanView alloc]initWithFrame:CGRectMake(MainWidth - 120, 0, 120, 160) withButtonTag:^(NSInteger tag) {
            
            
            NSString *tempStr;
            
            
            switch (tag) {
                case 21:{
                    // 发件箱
                    tempStr = @"mail/sendList.html";
                    break;
                }
                case 22:{
                    
                    // 草稿箱
                    tempStr = @"mail/dragList.html";
                    break;
                }
                case 23:{
                    
                    // 写信
                    tempStr = nil;
                    
                    Mail_Document_VC *reportVC = [[Mail_Document_VC alloc]init];
                    reportVC.urlStr = @"mail/newMail.html";
                    [self.navigationController pushViewController:reportVC animated:YES];
                    
                    [_planView removeFromSuperview];
                    isSelectPlan = NO;
                    break;
                }
                case 24:{
                    
                    // 已读邮件
                    tempStr = @"mail/readMailList.html";
                    break;
                }
                default:
                    break;
            }
            
            
            if (tempStr) {
                
                ProductOfVC *proVC = [[ProductOfVC alloc] init];
                proVC.urlS = tempStr;
                [self.navigationController pushViewController:proVC animated:YES];
                
                [_planView removeFromSuperview];
                isSelectPlan = NO;
            }
            
            
        }] ;
        
    }
    
    [self.view addSubview:_planView];
    
}


- (void)popClick:(NSNotification *)notification{
    [_popVC dismissViewControllerAnimated:YES completion:nil];
    
    NSIndexPath *path = notification.object;
    NSInteger tag = path.row;
    NSString *tempStr;
    
    
    
    switch (tag) {
        case 0:{
            
            // 已读邮件
            tempStr = @"mail/readMailList.html";
            break;
            
        }
        case 1:{
            
            
            // 发件箱
            tempStr = @"mail/sendList.html";
            break;
            
        }
        case 2:{
            
            // 草稿箱
            tempStr = @"mail/dragList.html";
            break;
            
        }
        case 3:{
            
            // 写信
            tempStr = nil;
            
            Mail_Document_VC *reportVC = [[Mail_Document_VC alloc]init];
            reportVC.urlStr = @"mail/newMail.html";
            [self.navigationController pushViewController:reportVC animated:YES];
            
            [_planView removeFromSuperview];
            isSelectPlan = NO;
            break;
           
        }
        default:
            break;
    }
    
    
    if (tempStr) {
        
        ProductOfVC *proVC = [[ProductOfVC alloc] init];
        proVC.urlS = tempStr;
        [self.navigationController pushViewController:proVC animated:YES];
    }

    
}
#pragma mark popViewDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    
    return UIModalPresentationNone;
}

#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);
    //根据
    
    NSArray *unidArray = [requestString componentsSeparatedByString:@".app/"];

    
    if (unidArray.count > 1) {
        
        
            if ([unidArray.lastObject hasPrefix:@"mail/mail.html"]) {
                
                ReportDetaiVC *reportVC = [[ReportDetaiVC alloc] init];
                reportVC.urlS = unidArray.lastObject;
                [self.navigationController pushViewController:reportVC animated:YES];
                
                return NO;
                
            }
            
        
    }

    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }
    
    return YES;
}



//加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //设置body字体，但是会导致页面刷新时有由小变大的渐变效果
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        //        [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '120%'"];
    }else{
    }
    
    //webview加载完成后移除黑色视图，否则会覆盖本地html的导航栏
    //Html当中的js代码会引起内存泄露,设置缓存
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    // WebView放到最上层
    //    [_webView stringByEvaluatingJavaScriptFromString:@"onchangeDate('1')"];
    
    [self.view bringSubviewToFront:_webView];
}

#pragma mark - 与JS交互

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


//释放webview
- (void)dealloc
{
    _webView.delegate = nil;
    [_webView stopLoading];
}



@end






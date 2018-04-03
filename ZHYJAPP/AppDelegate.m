//
//  AppDelegate.m
//  ZHYJAPP
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "ZHYJLoginViewController.h"
#import "ZHYJLocalCache.h"
#import "AFNetworking.h"
#import "DataEncoding.h"
#import "DataManager.h"
#import "NetworkManager.h"
#import "ZHYJWebViewController.h"
#import "CustomURLProtocol.h"
#import "Reachability.h"
#import "TabBarVC.h"
#import "EaseUI.h"
#import "EMSDKFull.h"
#import "ConversationListController.h"

@interface AppDelegate () <NSXMLParserDelegate>
{
    NSMutableArray *_parserStrArr;
    NSString *_xmlelement;
    ZHYJLoginViewController *loginVC;
    ZHYJWebViewController   *webviewVC;
    UIView *alView;
    NSString *currenV; // 当前版本号
    NSString *linkStr;  // 升级链接
    
    NSTimer *myTimer;
//    UIAlertController *alertVCtrl;
}
@property (nonatomic, strong) TabBarVC *mainController1;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
      NSArray *tempArray = [DataManager sharedDataManager].IMUserlist;
    
 

//    NSLog(@"%@", NSHomeDirectory());
//    [NSThread sleepForTimeInterval:1.5];//添加启动图片的时长
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
   //环信
    EMOptions *options = [EMOptions optionsWithAppkey:@"1171161012115337#sgjt"];
    options.isAutoAcceptGroupInvitation = YES;
//    options.isAutoAcceptFriendInvitation = YES;
#ifdef REDPACKET_AVALABLE
    /**
     *  TODO: 通过环信的AppKey注册红包
     */
    [[RedPacketUserConfig sharedConfig] configWithAppKey:@"1171161012115337#sgjt"];
#endif

    options.apnsCertName = @"zhyjerp";
//        options.apnsCertName = @"sgjt";

    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
//   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
////
//
//    [ChatDemoHelper shareHelper];
//    
////    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
////    if (isAutoLogin){这里是发送实时通话通知
//   [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
//    }
//    else
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
//    }
    
    // 注册苹果推送，获取deviceToken用于推送
    
    [self registerAPNS:application];
    //  阿里云推送
    [self initCloudPush];
    
    // 注册通知
    [self registerMessageReceive];
//    [CloudPushSDK handleLaunching:launchOptions];
    
    loginVC   = [ZHYJLoginViewController new];
    webviewVC = [ZHYJWebViewController new];
    TabBarVC *tb=[[TabBarVC alloc]init];
    //缓存设置
//    ZHYJLocalCache *cache = [[ZHYJLocalCache alloc]initWithMemoryCapacity:1024*1024*100 diskCapacity:1024*1024*1024 diskPath:nil];
//    [NSURLCache setSharedURLCache:cache];

    //判断本地用户名是否为空,因为只保存一个用户，所以只需判断本地是否存在用户名密码
    NSLog(@"login-=-----%@   %@", [[DataManager sharedDataManager] password], [[DataManager sharedDataManager] username]);
    if ([[DataManager sharedDataManager] password] != nil && [[DataManager sharedDataManager] username] != nil) {
        
        
   
        
        for (NSDictionary *dict in tempArray ) {
            // 自动登录环信，根据保存的用户名跟密码
            if ([[dict[@"ImUserName"] lowercaseString] isEqualToString:[DataManager sharedDataManager].userMsg[@"ImUserName"]]) {
               
                [[EMClient sharedClient] setApnsNickname:dict[@"cnName"]];
                
            }
        }

        NSString *sUsername = [[DataManager sharedDataManager] username];
        NSString *sPassword = [[DataManager sharedDataManager] password];
        sPassword = [DataEncoding decodeInBase64:sPassword];
        sPassword = [DataEncoding decryptUseDES:sPassword key:@"password"];
//        NSLog(@"%@", sPassword);
        //确认用户名后再进行网络请求并直接进入用户界面
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970]*1000;
        
        
        [NetworkManager loginWithUsename:sUsername password:sPassword completion:^(id responseObject, NSURLResponse *response, NSError *error) {
            NSDate* dat1 = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval b=[dat1 timeIntervalSince1970]*1000;
            NSInteger c = b - a;
            NSLog(@"data+++++%ld", (long)c);
            //当修改了密码后，要重新判断
            if (responseObject == nil) {
                
                self.window.rootViewController = loginVC;
                [self.window makeKeyAndVisible];
//                [MsgToolBox controller:self showAlert:@"温馨提示" content:@"请重新登陆!"];
            }else if ([responseObject isEqual:@""]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
//                    [MsgToolBox controller:self showAlert:@"登录失败" content:@"账号或密码错误，请重新输入。"];
                    
                });
                self.window.rootViewController = loginVC;
            }else{
            //登录成功后从后台获取用户信息
                [NetworkManager getUserMsgWithTime:@"0" completion:^(id responseObject, NSURLResponse *response, NSError *error) {
                    

                    NSLog(@"%@  %@", [DataManager sharedDataManager].userMsg[@"ImUserName"], [DataManager sharedDataManager].userMsg[@"ImPassWord"]);
                    // 登录环信
                    EMError *error1 = [[EMClient sharedClient] loginWithUsername:[[DataManager sharedDataManager].userMsg[@"ImUserName"] lowercaseString] password:[DataManager sharedDataManager].userMsg[@"ImPassWord"]];
                    
                    NSLog(@"登录error%@", error1);
                    if (error1 == nil) {
                        NSLog(@"登录成功");
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
                        [ChatDemoHelper shareHelper];
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                        EMError *error = [[EMClient sharedClient] loginWithUsername:[[DataManager sharedDataManager].userMsg[@"ImUserName"] lowercaseString] password:[DataManager sharedDataManager].userMsg[@"ImPassWord"]];
                        if (!error)
                        {
                            [[EMClient sharedClient].options setIsAutoLogin:YES];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[EMClient sharedClient] migrateDatabaseToLatestSDK];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[ChatDemoHelper shareHelper] asyncGroupFromServer];
                                    [[ChatDemoHelper shareHelper] asyncConversationFromDB];
                                    [[ChatDemoHelper shareHelper] asyncPushOptions];
                                    //发送自动登陆状态通知
                                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@([[EMClient sharedClient] isLoggedIn])];
                                    
                                    //保存最近一次登录用户名
                                    //                        [weakself saveLastLoginUsername];
                                });
                            });
                            
                        }
                    }else{
                        switch (error1.code)
                        {
                                //                    case EMErrorNotFound:
                                //                        TTAlertNoTitle(error.errorDescription);
                                //                        break;
                            case EMErrorNetworkUnavailable:
                                TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                                break;
                            case EMErrorServerNotReachable:
                                TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                                break;
                            case EMErrorUserAuthenticationFailed:
                                TTAlertNoTitle(error1.errorDescription);
                                break;
                            case EMErrorServerTimeout:
                                TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                                break;
                            default:
                                TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
                                self.window.rootViewController = loginVC;
                                break;
                        }
                    }
                if (error) {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
//                self.window.rootViewController = webviewVC;
                self.window.rootViewController = tb;
//                tb.selectedIndex = 0;
            }
            [self.window makeKeyAndVisible];
//            [self checkUpdateVersion];
            [self checkUpdateVersionForItunes];
            [SVProgressHUD dismiss];
        }];
        
    }else{
        
        self.window.rootViewController = loginVC;
        [self.window makeKeyAndVisible];

        //        [self checkUpdateVersion];
        [self checkUpdateVersionForItunes];

    }
    
    /*检测网络放在界面显示后面，不会造成网络改变时alView被覆盖*/
    //添加通知，监测网络状态，网络发生改变时发出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)name:kReachabilityChangedNotification object:nil];
    //当前网络连接
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    //网络发生改变时调用
    [self updateInterfaceWithReachability:self.internetReachability];

//     myTimer =  [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(isThefastID) userInfo:nil repeats:YES];
    
    return YES;
}



//IP进行比较
- (void)isThefastID{
    [NetworkManager CheckThefastID];
}


#pragma mark 环信
- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {//登陆成功加载主窗口控制器
        //加载申请通知的数据
//        [[ApplyViewController shareController] loadDataSourceFromLocalDB];
        if (self.mainController1 == nil) {
            self.mainController1 = [[TabBarVC alloc] init];
             self.window.rootViewController = self.mainController1;
        }else{
            self.mainController1 = [[TabBarVC alloc] init];
            self.window.rootViewController = self.mainController1;
//            navigationController  = self.mainController1.navigationController;
        }
        
        [ChatDemoHelper shareHelper].mainVC = self.mainController1;
        
        [[ChatDemoHelper shareHelper] asyncGroupFromServer];
        [[ChatDemoHelper shareHelper] asyncConversationFromDB];
        [[ChatDemoHelper shareHelper] asyncPushOptions];
        self.window.rootViewController = self.mainController1;
    }else{//登陆失败加载登陆页面控制器

        loginVC = [[ZHYJLoginViewController alloc] init];
        self.window.rootViewController = loginVC;
    }
}

#pragma mark -- 阿里云推送
- (void)initCloudPush {
    //[CloudPushSDK turnOnDebug];
    // SDK初始化
//    [CloudPushSDK asyncInit:@"23443372" appSecret:@"66bdfbcb9e49a57f0cba44c6af172e71" callback:^(CloudPushCallbackResult *res) {
//        if (res.success) {
////            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
//            
//        } else {
////            NSLog(@"Push SDK init failed, error: %@", res.error);
//        }
//    }];
}

/**
 *    注册苹果推送，获取deviceToken用于推送
 */
- (void)registerAPNS:(UIApplication *)application {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
    }
    else {
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
}

/*
 *  苹果推送注册成功回调，将苹果返回的deviceToken上传到CloudPush服务器
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //向阿里云推送注册设备的deviceToken
//    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
//        if (res.success) {
////            NSLog(@"Register deviceToken success.%@", [CloudPushSDK getApnsDeviceToken]);       
//        } else {
////            NSLog(@"Register deviceToken failed, error: %@", res.error);
//        }
//    }];
}

/*
 *  苹果推送注册失败回调
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: --%@", error);
}

/**
 *    注册推送消息到来监听
 */
- (void)registerMessageReceive {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];
}

/**
 *    处理到来推送消息
 *
 *    @param     notification
 */

/*
 *  App处于启动状态时，通知打开回调
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
    
//    NSLog(@"%@", userInfo);
    // 通知打开回执上报
//    [CloudPushSDK handleReceiveRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    // iOS badge 清0
    application.applicationIconBadgeNumber = 0;

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
#warning 修改信息
//        [self showAlertTitle:@"收到一条新消息" WithMessage:userInfo[@"aps"][@"alert"]];
        
        
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    if (_mainController1) {
        [_mainController1 didReceiveLocalNotification:notification];
    }

}

- (void)timerFireMethod:(NSTimer*)theTimer//弹出框
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert =NULL;
}

- (void)showAlert:(NSString *) message{//时间
    
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@"提示:" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:promptAlert
                                    repeats:YES];
    [promptAlert show];
}

//网络断开的提示框
- (void)showAlertView:(Boolean)show
{
    if (!alView) {
        
       
        alView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.window.frame.size.width, 40)];
        alView.backgroundColor = [UIColor blackColor];
        alView.alpha = 0.5;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, alView.frame.size.width, alView.frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"❗️ 当前网络不可用，请检查你的网络设置";
        label.textColor = [UIColor whiteColor];
        [alView addSubview:label];
        [self.window addSubview:alView];
    }
    alView.hidden = !show;
    //保证alView一直在window的最上层
    if (show) {
        [self.window bringSubviewToFront:alView];
    }else {
        [self.window sendSubviewToBack:alView];
    }
}

//- (void)checkUpdateVersion
//{
//    [NetworkManager getUpdateVersion:^(id responseObject, NSURLResponse *response, NSError *error) {
//        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseObject];
//        parser.delegate = self;
//        [parser parse];
//        
//        NSString *updateUrl = [_parserStrArr objectAtIndex:3];
//        double version = [[_parserStrArr objectAtIndex:1] doubleValue];
//        double currentVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] doubleValue];
//        if ([_parserStrArr[0] isEqualToString:@"1"]) {
////            if (currentVersion < version) {
//////                dispatch_async(dispatch_get_main_queue(), ^{
//////                    UIAlertController *alertVCtrl = [UIAlertController alertControllerWithTitle:@"发现新版本" message:@"检测到新版本，赶快体验一下吧！" preferredStyle:UIAlertControllerStyleAlert];
//////                    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//////                        //延时调用
//////                            dispatch_after(0.2, dispatch_get_main_queue(), ^{
//////                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
//////                        });
//////                    }];
//////                    [alertVCtrl addAction:sure];
//////                    [self.window.rootViewController presentViewController:alertVCtrl animated:YES completion:nil];
////                });
////            }
//        }
//    }];
//}




/** 版本升级  */
- (void)checkUpdateVersionForItunes{
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSLog(@"当前应用名称：%@",appCurName);
    // 当前应用软件版本  比如：1.0.1
    currenV = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // 当前应用版本号码   int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"当前应用版本号码：%@",appCurVersionNum);
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    [mgr.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil]];
    //POST必须上传的字段1257347094
    NSDictionary *dict = @{@"id":@"1258482967"};
    [mgr POST:@"https://itunes.apple.com/lookup" parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        
        
        NSArray *array = responseObject[@"results"];
        if (array.count != 0) {// 先判断返回的数据是否为空
            NSDictionary *dict = array[0];
            linkStr = dict[@"trackViewUrl"];
            linkStr = [linkStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            if ([dict[@"version"] compare:currenV options:NSNumericSearch] ==NSOrderedDescending) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:@"当前版本过低，请前往更新！" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil] ;
                alert.delegate = self;
                alert.tag = 222;
                [alert show];
                
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 222) {
        
        if (buttonIndex == 1) {
            UIApplication *application = [UIApplication sharedApplication];
            [application openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/id1258482967?mt=8"]];
            //            https://itunes.apple.com/us/app/%E6%99%BA%E6%85%A7erpdm/id1239035371?mt=8
            //            [application openURL:[NSURL URLWithString:linkStr]];
        }
        
    }
}


#pragma mark - NSXMLParserDelegate
//在开始解析xml节点前，通过该方法可以做一些初始化工作
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //每一条信息都用数组来存，最后得到的数据即在此数组中
    _parserStrArr = [NSMutableArray array];
}
//开始解析节点，当解析器对象遇到xml的开始标记时，调用这个方法开始解析该节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    _xmlelement = elementName;
}
// 当解析器找到开始标记和结束标记之间的字符时，调用这个方法解析当前节点的所有字符
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSMutableString *element = [[NSMutableString alloc]init];
    [element setString:@""];
    [element appendString:string];
    if ([_xmlelement isEqualToString:@"check"]) {
        [_parserStrArr addObject:element];
    }
    if ([_xmlelement isEqualToString:@"version"]) {
        [_parserStrArr addObject:element];
    }
    if ([_xmlelement isEqualToString:@"name"]) {
        [_parserStrArr addObject:element];
    }
    if ([_xmlelement isEqualToString:@"url"]) {
        [_parserStrArr addObject:element];
    }
}
//当解析器对象遇到xml的结束标记时，调用这个方法完成解析该节点
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    _xmlelement = nil;
//    NSLog(@"%@",_parserStrArr);
}
//解析xml出错的处理方法
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"xml解析出错: %@",[parseError description]);
}

#pragma mark - checkNetwork
//网络连接发生改变时调用
- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability* curReach = [notification object];
//    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    //获取当前网络状态
    _netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    switch (_netStatus) {
        case NotReachable:  {
//            [self showAlertView:YES];
            
//            [self showAlertTitle:@"温馨提示" WithMessage:@"网络连接已断开"];
            connectionRequired = NO;
//            NSLog(@"网络连接失败");
            break;
        }
        case ReachableViaWiFi:
        case ReachableViaWWAN:  {
//            NSLog(@"网络连接成功");
//            [self showAlertView:NO];
            break;
        }
        default:
            NSLog(@"unknow");
            break;
    }
}


#ifdef REDPACKET_AVALABLE

#pragma mark - Alipay

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:nil];
}

// NOTE: iOS9.0之前使用的API接口
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    return YES;
}

// NOTE: iOS9.0之后使用新的API接口
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    return YES;
}

#endif


#pragma mark - applicationDelegate
- (void)applicationWillResignActive:(UIApplication *)application {
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];

}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EMClient sharedClient] applicationWillEnterForeground:application];

}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end





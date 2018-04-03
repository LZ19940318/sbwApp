//
//  HrListViewController.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/21.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "HrListViewController.h"

#import "RedPacketChatViewController.h"
#import "ZHYJLoginViewController.h"
#import "RedpacketViewControl.h"

static NSString * const isContant = @"message/chat.html?account=";


@interface HrListViewController ()<UIWebViewDelegate, UINavigationControllerDelegate>
{
    UIWebView *_webView;
    UIButton *editButton;
    
}


@end

@implementation HrListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    self.title = _titleStr;
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

- (void)viewWillAppear:(BOOL)animated{
    
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}


#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);
    //根据
    
    
    
    NSString *transStr = [NSString stringWithString:[requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSArray *titleSeparate = [transStr componentsSeparatedByString:@"right_title="];
    if (titleSeparate.count > 1) {
        
        
        
        editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 44)];
        [editButton setTitle:titleSeparate.lastObject forState:UIControlStateNormal];
        [editButton setTitle:@"" forState:UIControlStateSelected];

        editButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [editButton setTintColor:[UIColor whiteColor]];
        editButton.selected = NO;
        
        
        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:editButton];
        self.navigationItem.rightBarButtonItem=rightBtn;
        
        
    }
    // hr/messagelist-document.html
    
    NSArray *listArr = [requestString componentsSeparatedByString:@"ZHYJAPP.app/hr/messagelist-document.html?unid="];
    if (listArr.count == 2) {
        [self getPhotoWithUnid:listArr[1]];
        return NO;
    }

    
    NSArray *playArray = [requestString componentsSeparatedByString:@"playSP"];
    if ([playArray[0] hasSuffix:@"Huanxin"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":playArray[1], @"type":[NSNumber numberWithInt:1]}];
    }
    
    NSRange range1 = [requestString rangeOfString:@"hr/messagelist-document.html"];

    if (range1.location != NSNotFound) {
        
         self.navigationItem.rightBarButtonItem= nil;

    }
    
    
    NSRange range = [requestString rangeOfString:isContant];
    if (range.location != NSNotFound) {
     

        //判断是否发送消息，隐藏tabbar
        NSArray *array = [requestString componentsSeparatedByString:isContant];
        if(![array[1] isEqualToString:@""]){
            
           
            if ([[DataManager sharedDataManager].userMsg[@"ImUserName"] isEqualToString:[array[1] lowercaseString]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"不能与自己聊天" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                });
            }else{
#ifdef REDPACKET_AVALABLE
                // 红包功能
                RedPacketChatViewController *chatController = [[RedPacketChatViewController alloc]
#else
                                                               
                                                               
                // 聊天功能
                ChatViewController *chatController = [[ChatViewController alloc]
#endif
                initWithConversationChatter:array[1] conversationType:EMConversationTypeChat];
                
                //遍历出名字
               EaseUserModel *model = [[EaseUserModel alloc] init];
                if ([DataManager sharedDataManager].IMUserlist) {
                    for (NSDictionary *dict in [DataManager sharedDataManager].IMUserlist) {
                        if ([dict[@"ImUserName"] isEqualToString:[array[1] lowercaseString]]) {
                                model.avatarURLPath = [dict[@"photo"] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
                                chatController.title = dict[@"cnName"];
                             if (![dict[@"photo"] isEqualToString:@""]) {
                                NSData *dataFromBase64Str = [[NSData alloc]initWithBase64EncodedString:[dict[@"photo"] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                model.avatarImage = [UIImage imageWithData:dataFromBase64Str];
//                                 model.avatarImage = [UIImage imageNamed:@"UsernameLeftView"];
                                                                    }
                                                                           
                                                                           break;
                                                                       }
                                                                   }
                                                               }
                           //隐藏tabbar
                           
                           self.hidesBottomBarWhenPushed=YES;
                           self.tabBarController.tabBar.hidden = YES;
                           [self.navigationController setNavigationBarHidden:NO animated:YES];
                           self.navigationItem.rightBarButtonItem=nil;
                           [self.navigationController pushViewController:chatController animated:YES];
                           self.hidesBottomBarWhenPushed=NO;
               }
               
               }else{
                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"不是环信用户" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                   [alert show];
               }
               }
               //提交数据,页面调用app.postData
               if ([requestString hasPrefix:@"posturl"]) {
                   [self postDataWithRequestStr:requestString];
                   return YES;
               }
               
               return YES;
}
      

- (void)getPhotoWithUnid:(NSString *)unid{
    
   [SVProgressHUD showWithStatus:@"正在加载,请稍后。"];


    __strong NSString *_unid = unid;

    NSString *urlStr = [NSString stringWithFormat:@"http://sbwoa.shengu.com.cn/combestbkc/combest_mopcontroller.nsf/CBXsp_getUserInfoByUserId.xsp?ImUserName=%@",_unid];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSString *cookie = [[DataManager sharedDataManager] cookieValue];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    request.HTTPMethod = @"get";
    request.HTTPBody = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
    [NetworkManager networkWithRequest:request completion:^(id responseObject, NSURLResponse *response, NSError *error) {
       if (error == nil) {
           
           
           NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableLeaves) error:nil];
           //            NSDictionary *returndic = [NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableLeaves) error:nil];
           
           dispatch_async(dispatch_get_main_queue(), ^{
               
               if(dataString != nil){
                   
                   
                   NSMutableArray *mArray = [[NSMutableArray alloc]initWithArray:[[DataManager sharedDataManager] IMUserlist] ];
                   //[[NSMutableArray alloc]initWithArray:[DataManager sharedDataManager] IMUserlist];
                   for (int i = 0; i < mArray.count; i++) {
                       
                       NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:mArray[i]];
                       
                       
                       if ([[dic[@"ImUserName"] lowercaseString] isEqualToString:_unid]) {
                           dic[@"photo"] = dataString[@"photo"];
                           mArray[i] = dic;
                       }
                       
                   }
             //[[DataManager sharedDataManager] saveUserMessageListSort:nil];
               
               
               [[DataManager sharedDataManager] saveUserPhoto:dataString[@"photo"]];
               HrListViewController *listVC = [[HrListViewController alloc] init];
               listVC.urlS = [NSString stringWithFormat:@"/hr/messagelist-document.html?unid=%@",_unid];
               listVC.titleStr = dataString[@"cnName"];
               [self.navigationController pushViewController:listVC animated:YES];
               [SVProgressHUD dismiss];
                   [[DataManager sharedDataManager] saveUserMessageList:mArray];

           }
           
           });
       }else{
           [SVProgressHUD dismiss];
           
           dispatch_async(dispatch_get_main_queue(), ^{
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络请求错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
               [alert show];
           });
       }
       
    }];



}
                                                            
//提交数据
- (void)postDataWithRequestStr:(NSString *)requestString{
    
            NSArray  *components = [requestString componentsSeparatedByString:@"$$$"];
            NSString *urlString = [components objectAtIndex:1];//请求路径
            NSString *params = [components objectAtIndex:2];//请求参数
            //    NSString *callback = [components objectAtIndex:3];//回调函数
            NSRange range = [params rangeOfString:@"back"];//匹配得到的下标

            //    NSLog(@"rang:%@",NSStringFromRange(range));
            if (range.length == 0) {
                
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
            //                       NSString *jsFunc=[@"callback" stringByAppendingFormat:@"%@%@",@"(",dataString,@")"];
            //                       NSString *jsFunc = [NSString stringWithFormat:@"callback(%@)",dataString];

            //                       [_webView stringByEvaluatingJavaScriptFromString:jsFunc];
            //                       NSLog(@"提交数据jsFunc: %@", jsFunc);
                                   dispatch_async(dispatch_get_main_queue(), ^{
            //                           [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"callback('%@');",dataString]];
                                          [_webView stringByEvaluatingJavaScriptFromString:dataString];
            //                           [_webView stringByEvaluatingJavaScriptFromString:jsFunc];
                                   });
                               }else{
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络请求错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                       [alert show];
                                   });
                               }
                           }];
               
            }else{
                
                
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
                               NSLog(@"88888%@   ----%@", responseObject, requestString);
                               if (error == nil) {
                                   NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                   NSLog(@"77777%@", dataString);
                                   NSString *jsFunc=[callback stringByAppendingFormat:@"%@%@%@",@"(",dataString,@")"];
                                   NSLog(@"提交数据jsFunc: %@", jsFunc);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
            //                           [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"callback1();"]];
                                       [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"callback1('%@');",dataString]];

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

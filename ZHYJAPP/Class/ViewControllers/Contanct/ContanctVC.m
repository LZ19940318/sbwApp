//
//  ContanctVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 16/9/28.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ContanctVC.h"

#import "DataEncoding.h"
#import "ChatViewController.h"
#import "TabBarVC.h"
#import "RedPacketChatViewController.h"
#import "ZHYJLoginViewController.h"
#import "RedpacketViewControl.h"
#import "HrListViewController.h"
#import "MyVC.h"

static NSString * const isContant = @"message/chat.html?account=";

static NSString *const sUserIconKey = @"UserIcon";

@interface ContanctVC ()<UIWebViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIWebView *_webView;
    NSString  *_urlString;
    NSMutableDictionary *_userIcon;
    NSMutableArray *userLocationArr;
}
@property (nonatomic,retain) NSURLConnection *aSynConnection;
@property (nonatomic,retain) NSInputStream *inputStreamForFile;
@property (nonatomic,retain) NSString *photoFilePath;
@end

@implementation ContanctVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通讯录";
    
    [self initWebView];
    
    self.navigationController.delegate = self;


   
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
    self.tabBarController.tabBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    //    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed=NO;
    self.tabBarController.tabBar.hidden = NO;
    ////    CGRect rect = self.navigationController.navigationBar.frame ;
    ////
    ////    self.navigationController.navigationBar.frame = CGRectMake (rect.origin.x, rect.origin.y, rect.size.width, 24) ;
    ////    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    ////    view.backgroundColor = [UIColor redColor];
    //    [self printViewHierarchy:self.navigationController.navigationBar];
    
    //修改NavigaionBar的高度
    //    [self.navigationController.navigationBar addSubview:view];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)initWebView{
    
    
    if (!_webView) {
        
         _webView = [UIWebView initWithSet];
         _webView.delegate = self;
         CGRect frame = _webView.frame;
         frame.origin.y = 0;
         frame.size.height = frame.size.height - 64;
        _webView.frame = frame;
        [self.view addSubview:_webView];
    }
    

    
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    //从mainBundle里取本地html文件
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:mainBundlePath isDirectory:YES];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/messagelist.html", mainBundlePath];
    NSLog(@"ssssss%@", htmlPath);
    NSString *htmlStr = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlStr baseURL:baseURL];
    //    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hostname"]]];
    
    _userIcon = [NSMutableDictionary dictionary];
    [DataManager sharedDataManager].putDic = [NSMutableDictionary dictionary];
    
}


//原生返回按钮
- (void)back{
    TabBarVC *webViewController = [TabBarVC new];
    webViewController.selectedIndex = 3;
    [UIApplication sharedApplication].keyWindow.rootViewController = webViewController;

}
- (void)createGroup{
    GroupListViewController *groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
//    self.hidesBottomBarWhenPushed=YES;
//    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController pushViewController:groupController animated:YES];


}
#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
        NSLog(@"--------requestString:%@", requestString);
    // 群组
    if ([requestString hasSuffix:@"qunzu.html"]) {
        [self createGroup];
    }
    
    // 
    if ([requestString hasSuffix:@"hr/messagelist-department.html"]) {
        HrListViewController *listVC = [[HrListViewController alloc] init];
        listVC.urlS = @"hr/messagelist-department.html";
        [self.navigationController pushViewController:listVC animated:YES];
        return NO;
    }
    
    // 用户搜索
    if ([requestString hasSuffix:@"hr/userSearch.html"]) {
        HrListViewController *listVC = [[HrListViewController alloc] init];
        listVC.urlS = @"hr/userSearch.html";
        [self.navigationController pushViewController:listVC animated:YES];
        return NO;
    }
    
    NSArray *listArr = [requestString componentsSeparatedByString:@"ZHYJAPP.app/hr/messagelist-document.html?unid="];
    if (listArr.count == 2) {
        [self getPhotoWithUnid:listArr[1]];
        return NO;
    }

    NSArray *playArray = [requestString componentsSeparatedByString:@"playSP"];
    if ([playArray[0] hasSuffix:@"Huanxin"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":playArray[1], @"type":[NSNumber numberWithInt:1]}];
        
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
                RedPacketChatViewController *chatController = [[RedPacketChatViewController alloc]
#else
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
                       NSData *dataFromBase64Str = [[NSData alloc]
                                                    initWithBase64EncodedString:[dict[@"photo"] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                       model.avatarImage = [UIImage imageWithData:dataFromBase64Str];
                   }
                   
                   break;
               }
           }
       }
       //隐藏tabbar
       
       self.hidesBottomBarWhenPushed=YES;
       self.tabBarController.tabBar.hidden = YES;
       [self.navigationController setNavigationBarHidden:NO animated:YES];
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

    //调用相机,页面调用jsFunc的photo.takePhoto方法
    if ([requestString hasPrefix:@"takephotourl"]) {
        [self takePhotoWithRequestStr:requestString];
        return YES;
    }
    //页面切换时调用
    if ([requestString hasPrefix:@"puturl"]) {
        [self putWithRequestStr:requestString];
        return YES;
    }
   //判断是否是红包跳转 是跳转到红包页面
   if ([requestString hasSuffix:@"hongbao.html"]) {
       UIViewController *controller = [RedpacketViewControl changeMoneyController];
       UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
       [self presentViewController:nav animated:YES completion:nil];
   }

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        //        NSLog(@"request:%@",[[request URL] absoluteString]);
        
        NSLog(@"可以聊天了");
    }
   //    退出登录,页面调用app.logout
   if ([requestString hasPrefix:@"logouturl"]) {
       NSLog(@"%@", requestString);
       [self logoutWithRequestStr:requestString];
       return YES;
   }
    return YES;
}
                                                               
//退出登录
- (void)logoutWithRequestStr:(NSString *)requestString
                {
                    //清除用户信息
                    [[DataManager sharedDataManager] clearUsername:nil andPwd:nil];
                    [[DataManager sharedDataManager] saveUserMsg:nil];
                    [[DataManager sharedDataManager] saveCookie:nil];//清除保存的cookie
                    [DataManager sharedDataManager].putDic = nil;
                    //退出登录环信账号
                    EMError *error = [[EMClient sharedClient] logout:YES];
                    if (!error) {
                        NSLog(@"退出成功");
                    }
                    
                    NSHTTPCookie *cookie;
                    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                    //遍历清除缓存机制里的所有cookie,有两个cookie元素
                    for (cookie in [storage cookies]) {
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                    }
                    NSArray *cookieArray = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
                    NSLog(@"清除后：%@, %@", cookie, cookieArray);
                    //清除UIWebView的缓存
                    [[NSURLCache sharedURLCache] removeAllCachedResponses];
                    
                    
                    
                    // 跳到登录界面
                    ZHYJLoginViewController *loginVC = [ZHYJLoginViewController new];
                    //切换rootViewController
                    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
                }

//开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
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
    [self.view bringSubviewToFront:_webView];
}

#pragma mark - 与JS交互

- (void)getPhotoWithUnid:(NSString *)unid{
   
    [SVProgressHUD showWithStatus:@"正在加载,请稍后。"];
    __strong NSString *_unid = unid;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://sbwoa.shengu.com.cn/combestbkc/combest_mopcontroller.nsf/CBXsp_getUserInfoByUserId.xsp?ImUserName=%@",_unid];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSString *cookie = [[DataManager sharedDataManager] cookieValue];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    request.HTTPMethod = @"get";
    //  request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
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
                    //            [[DataManager sharedDataManager] saveUserMessageListSort:nil];
                    
                    
                    [[DataManager sharedDataManager] saveUserPhoto:dataString[@"photo"]];
                    HrListViewController *listVC = [[HrListViewController alloc] init];
                    listVC.urlS = [NSString stringWithFormat:@"/hr/messagelist-document.html?unid=%@",_unid];
                   // listVC.titleStr = dataString[@"cnName"];
                    
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
                                                               
//页面切换
- (void)putWithRequestStr:(NSString *)requestString
{
    NSArray  *parts = [requestString componentsSeparatedByString:@"$$$"];
    NSString *key   = [parts objectAtIndex:1];
    NSString *value = [parts objectAtIndex:2];
    NSMutableDictionary *putDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:value, key, nil];
    //将取到的键值对累加到字典
    [[DataManager sharedDataManager].putDic addEntriesFromDictionary:putDic];
    //    NSLog(@"保存的key：%@", putDic[key]);
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
                NSString *jsFunc=[@"callback" stringByAppendingFormat:@"%@%@%@",@"(",dataString,@")"];
                NSLog(@"提交数据jsFunc: %@", jsFunc);
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

//导航栏



//拍照
- (void)takePhotoWithRequestStr:(NSString *)requestString
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 创建UIImagePickerController实例
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        // 设置代理
        imagePickerController.delegate = self;
        // 是否允许编辑（默认为NO）
        //        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 设置进入相机时使用前置或后置摄像头
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
// 完成拍照或图片选取后调用的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 从info中将图片取出
    UIImage  *photoImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData   *imageData = UIImageJPEGRepresentation(photoImage, 0.2);
    
    photoImage = [UIImage fixRotationImage:photoImage];
    //保存照片
    [self savePhoto:photoImage withImageData:imageData];
    [picker dismissViewControllerAnimated:YES completion:nil];
    //    UIImageOrientation xx = photoImage.imageOrientation;
    //转base64
    NSString *imageBase64Str = [imageData base64EncodedStringWithOptions:0];
    //取图片的元数据
    NSDictionary *imageInfo = [info objectForKey:UIImagePickerControllerMediaMetadata];
    //取图片的拍照时间
    NSDictionary *tiffDic = [imageInfo objectForKey:@"{TIFF}"];
    NSDate *dateTime  = [tiffDic objectForKey:@"DateTime"];
    //图片信息存入字典
    NSString *account = [[DataManager sharedDataManager] username];
    [_userIcon setObject:account forKey:@"userAccount"];
    [_userIcon setObject:dateTime forKey:@"photoTime"];
    [_userIcon setObject:imageBase64Str forKey:@"userPhoto"];
    //将字典保存到本地
    [[DataManager sharedDataManager] saveUserIcon:_userIcon];
    
    [self uploadPhotoImage];//上传图片
    
    /*重新调用js显示新的照片,但是me.html页面的方法调不到，因为
     webview当前加载的页面是index.html，me.html只是一个iframe子页面。
     所以只能重新加载me.html页面--通过调用index.html里iframe标签
     */
    [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('conter').src='me.html'"];
}

// 取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//保存照片
- (void)savePhoto:(UIImage *)photo withImageData:(NSData *)imageData
{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    _photoFilePath = [docPath stringByAppendingPathComponent:@"20160711.jpg"];
    [imageData writeToFile:_photoFilePath atomically:YES];
}
//上传照片
- (void)uploadPhotoImage
{
    NSString *serverAddr = [NetworkManager sHostURLString];
    NSString *ou = [DataManager sharedDataManager].userMsg[@"ou"];
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@%@%@", serverAddr, @"/", ou, @"/combest_hr.nsf/CBXsp_uploadImg.xsp"];
    NSURL *url = [NSURL URLWithString:urlString];
    // 初始化本地文件路径,并与NSInputStream链接
    self.inputStreamForFile = [NSInputStream inputStreamWithFileAtPath:self.photoFilePath];
    
    // 上传大小
    NSNumber *contentLength;
    contentLength = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:self.photoFilePath error:NULL] objectForKey:NSFileSize];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBodyStream:self.inputStreamForFile];
    //设置请求头头域
    [request setValue:@"image/jpg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[contentLength description] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"20160711.jpg" forHTTPHeaderField:@"ContentName"];
    //带cookie请求
    NSString *cookie = [[DataManager sharedDataManager] cookieValue];
    
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    //    NSLog(@"header:  %@", request.allHTTPHeaderFields);
    // 请求
    //    self.aSynConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [NetworkManager networkWithRequest:request completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            //            NSLog(@"上传成功！");
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请求错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
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

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}



//释放webview
- (void)dealloc
{
    _webView.delegate = nil;
    [_webView stopLoading];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

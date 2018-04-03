//
//  MyVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 16/9/28.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "MyVC.h"

#import "ZHYJLoginViewController.h"
#import "TwoViewController.h"

static NSString *const sUserIconKey = @"UserIcon";

@interface MyVC ()<UIWebViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    UIWebView *_webView;
    NSString  *_urlString;
    NSMutableDictionary *_userIcon;
    NSMutableArray *userLocationArr;
    NSString *imageBase64Str;

}
@property (nonatomic,retain) NSURLConnection *aSynConnection;
@property (nonatomic,retain) NSInputStream *inputStreamForFile;
@property (nonatomic,retain) NSString *photoFilePath;
@end

@implementation MyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的";
    
   
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    [self initWebView];

    
}
#pragma mark -- init
- (void)initWebView{
    
    if (!_webView) {
        
        _webView = [UIWebView initWithSet];
        _webView.delegate = self;

        
        CGRect frame = _webView.frame;
        frame.origin.y = 0;
        _webView.frame = frame;
        
        [self.view addSubview:_webView];
        
    }
    
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:mainBundlePath isDirectory:YES];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/myset.html", mainBundlePath];
    NSString *htmlStr = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlStr baseURL:baseURL];
    
    _userIcon = [NSMutableDictionary dictionary];
    [DataManager sharedDataManager].putDic = [NSMutableDictionary dictionary];
  
    
}



#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{ //多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
        NSLog(@"--------requestString:%@", requestString);

    
    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }
    //    退出登录,页面调用app.logout
    if ([requestString hasPrefix:@"logouturl"]) {
        NSLog(@"%@", requestString);
        [self logoutWithRequestStr:requestString];
        return YES;
    }
    //调用相机,页面调用jsFunc的photo.takePhoto方法
    if ([requestString hasPrefix:@"takephotourl"]) {
        //        [self takePhotoWithRequestStr:requestString];
        UIActionSheet *sheet =[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"相机",
                               nil];
        [sheet showInView:self.view];
        
        
        return YES;
    }
    //页面切换时调用
    if ([requestString hasPrefix:@"puturl"]) {
        [self putWithRequestStr:requestString];
        return YES;
    }

   
    // 个性设置
    NSString *tempStr = [NSString stringWithFormat:@"myset/personality.html?account=%@", [DataManager sharedDataManager].username];
    NSArray *array = @[@"Modify_password.html",
                      tempStr];
    
    for (NSString *strUrl in array) {
      
        if ([requestString hasSuffix:strUrl]) {
            
            TwoViewController *twoVC = [[TwoViewController alloc]init];
            twoVC.urlStr = strUrl;
            [self.navigationController pushViewController:twoVC animated:YES];
            return YES ;
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
    [self.view bringSubviewToFront:_webView];
}

#pragma mark - 与JS交互
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
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                
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
    
   
//    NSArray *array = [[DataManager sharedDataManager] IMUserlist];
    
    // 跳到登录界面
    ZHYJLoginViewController *loginVC = [ZHYJLoginViewController new];
    //切换rootViewController
    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
}

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
- (void)takePhotoWithRequestStr1:(NSString *)requestString
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        // 创建UIImagePickerController实例
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        // 设置代理
        imagePickerController.delegate = self;
        // 是否允许编辑（默认为NO）
        //        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 设置进入相机时使用前置或后置摄像头
//        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
// 完成拍照或图片选取后调用的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 从info中将图片取出
    UIImage  *photoImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData   *imageData = UIImageJPEGRepresentation(photoImage, 0.1);

    photoImage = [UIImage fixRotationImage:photoImage];
    //保存照片
    [self savePhoto:photoImage withImageData:imageData];
    [picker dismissViewControllerAnimated:YES completion:nil];
    //    UIImageOrientation xx = photoImage.imageOrientation;
    //转base64
     imageBase64Str = [imageData base64EncodedStringWithOptions:0];
    //取图片的元数据
    NSDictionary *imageInfo = [info objectForKey:UIImagePickerControllerMediaMetadata];
    //取图片的拍照时间
    NSDictionary *tiffDic = [imageInfo objectForKey:@"{TIFF}"];
    NSDate *dateTime  = [tiffDic objectForKey:@"DateTime"];
    
    if (dateTime == nil) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY:MM:dd HH:mm:ss"];
        dateTime = [NSDate date];

    }
    
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
    [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('conter').src='myset.html'"];
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
    [SVProgressHUD showWithStatus:@"上传头像"];
    NSMutableDictionary *msgArray = [[DataManager sharedDataManager] userMsg];
    NSString *serverAddr = [NetworkManager sHostURLString];
    NSString *ou = msgArray[@"ou"];
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
            
            [SVProgressHUD dismiss];
             [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"头像修改成功！"]];
            // photo
          
            NSMutableArray *mArray = [[NSMutableArray alloc]initWithArray:[[DataManager sharedDataManager] IMUserlist] ];
            //[[NSMutableArray alloc]initWithArray:[DataManager sharedDataManager] IMUserlist];
            for (int i = 0; i < mArray.count; i++) {
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:mArray[i]];
                
                
                if ([[dic[@"ImUserName"] lowercaseString] isEqualToString:[DataManager sharedDataManager].userMsg[@"ImUserName"]]) {
                    dic[@"photo"] = imageBase64Str;
                    mArray[i] = dic;
                }
                
            }
//            [[DataManager sharedDataManager] saveUserMessageListSort:nil];
            
#pragma mark -- 修改头像后，修改本地数据
            
            [[DataManager sharedDataManager] saveUserMessageList:mArray];
//            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请求错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            });
        }
        
    }];
}





#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"相册");
            [self takePhotoWithRequestStr1:nil];

            break;
            
        case 1:
            NSLog(@"相机");
            [self takePhotoWithRequestStr:nil];
            break;
            
        case 2:
            NSLog(@"取消");
            break;
            
            
        default:  
            break;  
    }
    
}
//释放webview
- (void)dealloc
{
    _webView.delegate = nil;
    [_webView stopLoading];
}


@end

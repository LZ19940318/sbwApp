//
//  Work_Document_VC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "Mail_Document_VC.h"

@interface Mail_Document_VC ()<UIWebViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    UIWebView *_webView;
    NSString *timeStr;
    
    NSMutableDictionary *_userIcon;

    
    NSString *callback;
    BOOL isShowButton;
    BOOL isChangeButton;
    UIButton *editButton;
    UIButton *leftButton;
    BOOL isClickBack;
}

@property (nonatomic,retain) NSURLConnection *aSynConnection;
@property (nonatomic,retain) NSInputStream *inputStreamForFile;
@property (nonatomic,retain) NSString *photoFilePath;


@end

@implementation Mail_Document_VC


- (void)viewDidLoad {
    [super viewDidLoad];
    isClickBack = NO;
    [self setNav];
  
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

    
    [self initWebView];
    
}

#pragma mark init
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
 
    // 发送按钮
    editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    [editButton setTitle:@"发送" forState:UIControlStateNormal];
    [editButton setTitle:@"确定" forState:UIControlStateSelected];
    [editButton setTintColor:[UIColor whiteColor]];
    [editButton addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem=rightBtn;
    
    
    
    // 重写返回按钮
    UIControl *leftControl = [[UIControl alloc]initWithFrame:CGRectMake(-25, (44-20)/2, 15, 20)];
    [leftControl addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 20)];
    imageView.image = [UIImage imageNamed:@"back.png"];
    [leftControl addSubview:imageView];
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 35, 20)];
    titleLable.text = @"返回";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont systemFontOfSize:16];
    [leftControl addSubview:titleLable];
    UIBarButtonItem *leftBarButon = [[UIBarButtonItem alloc]initWithCustomView:leftControl];
    self.navigationItem.leftBarButtonItem = leftBarButon;

    
}
#pragma mark Click
- (void)btnClicked{
    
       // isClickBack = yes ,即原生与h5交互，返回按钮无需返回到上个界面，而把地址页的数据带回到本页面
        if (isClickBack == YES) {
           [_webView stringByEvaluatingJavaScriptFromString:@"send2();"];
            [self setNav];
            editButton.selected = NO;
            isClickBack = NO;
            
        }else{
            
            [self.navigationController popViewControllerAnimated:YES];
        }

}

- (void)rightClick:(UIButton *)sender{
    
    
    
    if (sender.selected==YES) {
        
        [_webView stringByEvaluatingJavaScriptFromString:@"send1();"];
        sender.selected=NO;
        isClickBack = NO;
        
        
    }else{

        
        [_webView stringByEvaluatingJavaScriptFromString:@"send();"];

    }
  
    
    
}




#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"--------requestString:%@", requestString);
    
    //根据
    
//    if ([requestString hasSuffix:@"mail/search.html"]) {
//        
//        self.urlStr = @"mail/search.html";
//        [self initWebView];
//            return YES;
//    }
    //提交数据,页面调用app.postData
    if ([requestString hasPrefix:@"posturl"]) {
        [self postDataWithRequestStr:requestString];
        return YES;
    }

    // 根据原生与h5界面的交互，sendMainAdd1：添加发送人
    if ([requestString hasSuffix:@"sendMainAdd1"]) {
        
        isClickBack = YES;
//        [self setNav];
//        self.urlStr = @"address/userlist.html";
//        [self initWebView];
        editButton.selected = YES;
        return YES;
        
        
    }
    // 根据原生与h5界面的交互，sendMainAdd2：添加抄送人
    if ([requestString hasSuffix:@"sendMainAdd2"]) {
        
        isClickBack = YES;
//        [self setNav];
        editButton.selected = YES;
        return YES;
        
        
    }
    return YES;
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
//        //        [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '120%'"];
//    }else{
//    }
//    
//    //webview加载完成后移除黑色视图，否则会覆盖本地html的导航栏
//    //Html当中的js代码会引起内存泄露,设置缓存
//    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
//    // WebView放到最上层
    [self.view bringSubviewToFront:_webView];
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
                            
 
                            
                                if ([dataString isEqualToString:@"alert('发送成功!')"]) {

                                   [self.navigationController popViewControllerAnimated:YES];
                                }else{


                                }
//                                [_webView stringByEvaluatingJavaScriptFromString:@"userList.window.a()"];
                            NSString *tempStr = [NSString stringWithFormat:@"userList.window.%@",dataString];
                            [_webView stringByEvaluatingJavaScriptFromString:tempStr];
                            NSString *tempStr1 = [NSString stringWithFormat:@"userList.window.callback('%@')",dataString];
                            [_webView stringByEvaluatingJavaScriptFromString:tempStr1];
                           
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
    _photoFilePath = [docPath stringByAppendingPathComponent:@"20170605.jpg"];
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
    [request setValue:@"20170605.jpg" forHTTPHeaderField:@"ContentName"];
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

//释放webview
- (void)dealloc
{
    _webView.delegate = nil;
    [_webView stopLoading];
}



@end

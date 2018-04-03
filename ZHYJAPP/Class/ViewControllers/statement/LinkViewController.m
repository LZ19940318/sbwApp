//
//  WorkDetailVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/23.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "LinkViewController.h"
#import "WorkNavPushVC.h"
#import "Work_Document_VC.h"
#import "KNLocationConverter.h"


@interface LinkViewController ()<UIWebViewDelegate,CLLocationManagerDelegate, UIImagePickerControllerDelegate,CLLocationManagerDelegate,UIAlertViewDelegate>{
    
    UIWebView *_webView;
    NSString *timeStr;
    NSString *callback;
    NSString *NavButtonStr;
    BOOL isShowNavButton;
    NSMutableDictionary *_userIcon;
    
    
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D location1;
    BOOL isClickBack;
    
    NSString *lastResquestURL;
    
}


@property (nonatomic , strong)NSDictionary *titleDic;
@property (nonatomic , strong)UIButton *editButton;



@property (nonatomic,retain) NSURLConnection *aSynConnection;
@property (nonatomic,retain) NSInputStream *inputStreamForFile;
@property (nonatomic,retain) NSString *photoFilePath;

@end

@implementation LinkViewController


- (void)viewDidLoad {
    
    isClickBack = NO;
    [super viewDidLoad];
    
    [self setNav];
    
    
    
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    [self initWebViewWith:self.urlStr];
    [self initLocation];
    
    
}

#pragma mark -- init


- (NSDictionary *)titleDic{
    if (!_titleDic) {
        _titleDic = @{
                      @"oa/todo.html":@"待审批事项",
                      @"oa/newDoc.html?unid=B2C1D2303CF98E0C4825811F001FA515&wfpath=combestbkc/oa/combest_jtqxj.nsf&flowName=集团请销假管理":@"请销假管理",
                      @"work_signin/signIn.html":@"签到",
                      @"work/daily_list.html":@"我的日报",
                      @"oa/todo.html":@"我的审批",
                      @"todo/plan_list.html":@"资金计划列表",
                      @"todo/pay_list.html":@"付款申请列表",
                      @"oa/send_list.html":@"公告列表",
                      @"oa/readTodoList.html":@"待阅文件列表",
                      @"arc/arc.html":@"文件中心",
                      @"work/calendar.html":@"万年历",
                      
                      
                      };
    }
    return _titleDic;
}

- (UIButton *)editButton{
    
    if (!_editButton) {
        
        _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_editButton setTintColor:[UIColor whiteColor]];
        _editButton.selected = NO;
        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:_editButton];
        self.navigationItem.rightBarButtonItem=rightBtn;
        
    }
    return _editButton;
    
}

- (void)setNav{
    
    
    [_webView stringByEvaluatingJavaScriptFromString:@"theLocation();"];
    
    UIBarButtonItem *rightButton;
    self.title = self.titleDic[self.urlStr];
    
    // 我的日报
    if ([self.title isEqualToString:@"我的日报"]) {
        
        rightButton = [[UIBarButtonItem alloc]initWithTitle:@"新增" style:UIBarButtonItemStyleDone target:self action:@selector(rightClick)];
        
    }
    // 客户档案
    if ([self.title isEqualToString:@"客户档案"]) {
        
        rightButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(rightClick)];
        
    }
    
    
    [rightButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem=rightButton;
    
    
    // 重写返回按钮（有些界面需要控制返回按钮）
    UIControl *leftControl = [[UIControl alloc]initWithFrame:CGRectMake(-25, (44-20)/2, 15, 20)];
    [leftControl addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
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


- (void)initLocation{
    
    
    _locationManager = [[CLLocationManager alloc]init];
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"   定位服务当前可能尚未打开，请设置打开 ");
        
        return;
    }
    //    [_locationManager requestWhenInUseAuthorization];
    
    
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        [_locationManager requestWhenInUseAuthorization];
    }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways ){
        //设置代理
        _locationManager.delegate=self;
        //设置定位精度
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance=10.0;//十米定位一次
        _locationManager.distanceFilter=distance;
        
        
    }
    //启动跟踪定位
    [_locationManager startUpdatingLocation];
    
    
}


- (void)initWebViewWith:(NSString *)url{
    
    if (!_webView) {
        _webView = [UIWebView initWithSet];
        CGRect frame = _webView.frame;
        frame.origin.y = 0;
        _webView.frame = frame;
        
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    
    
    
    //从mainBundle里取本地html文件
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", mainBundlePath, url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",[htmlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    
    
    if ([self.urlStr hasPrefix:@"http"]) {
        
        request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlStr]];
        
    }
    
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    
    
    
}



#pragma mark -- Click



// 返回按钮
- (void)backClick{
    
    if (isClickBack) {
        [_webView stringByEvaluatingJavaScriptFromString:@"send1();"];
        [self setNav];
        isClickBack = NO;
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

// 导航栏右边按钮
- (void)rightClick{
    NSString *url;
    if ([self.title isEqualToString:@"我的日报"]) {
        
        url = @"work/daily_document.html";
    }
    
    if (url != nil) {
        
        WorkNavPushVC *workNavPushVC = [[WorkNavPushVC alloc]init];
        workNavPushVC.urlStr = url;
        [self.navigationController pushViewController:workNavPushVC animated:YES];
        
    }
    
}


//
- (void)rightClick:(UIButton *)sender{
    
    
    if ([sender.currentTitle isEqualToString:@"提交"]) {
        
        if ([self.title isEqualToString:@"请假流程"]) {
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否确认提交?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.delegate = self;
            [alert show];
            
            
        }else{
            
            [_webView stringByEvaluatingJavaScriptFromString:@"getdata1();"];
            
        }
        
        
    }else if ([sender.currentTitle isEqualToString:@"编辑"]) {
        [_webView stringByEvaluatingJavaScriptFromString:@"editData();"];
        
    }else {
        
    }
    
    
}

//

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        [_webView stringByEvaluatingJavaScriptFromString:@"getdata1();"];
        
    }
    else {
        
        
    }
}



#pragma mark CoreLocation 代理

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    
    CLLocation *location = [locations lastObject];
    CLGeocoder *genCoder = [[CLGeocoder alloc]init];
    location1=[KNLocationConverter transformFromWGSToGCJ:location.coordinate];
    [genCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        for (CLPlacemark *place in placemarks) {
            
            NSDictionary *location = [place addressDictionary];
            NSLog(@"name - %@",place.name);
            
            NSString *lat =  [NSString stringWithFormat:@"%f",location1.latitude] ;
            NSString *lng =  [NSString stringWithFormat:@"%f",location1.longitude];
            NSString *str1 = location[@"State"];
            NSString *str2 = location[@"SubLocality"];
            
            NSString *str3 = location[@"Street"];
            
            [_webView stringByEvaluatingJavaScriptFromString:
             
             [NSString stringWithFormat:@"theLocation(%@,%@,'%@','%@','%@');",lng,lat,str1,str2,str3]];
            
        }
        
        
    }];
    
    
    
    //    [_locationManager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    [_locationManager startUpdatingLocation];
    
    
}

#pragma mark -- UIWebViewDelegate
//准备加载，拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{//多次调用shouldStartLoad,是因为js文件里使用了自定义url的方式
    [SVProgressHUD showWithStatus:@"正在加载,请稍后。"];

    NSString *requestString = [[request URL] absoluteString];
    requestString = [requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([lastResquestURL isEqualToString:requestString]) {
        return YES;
    }
    lastResquestURL = requestString;
    
    NSLog(@"--------requestString:%@", requestString);
    
    
    
    // 判断是否显示标题，根据拦截的 right_title
    NSString *transStr = [NSString stringWithString:[requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSArray *titleSeparate = [transStr componentsSeparatedByString:@"right_title="];
    if (titleSeparate.count > 1) {
        // 文件中心 - > 选择文件 ，右边导航栏显示 right_title
        [self.editButton setTitle:titleSeparate.lastObject forState:UIControlStateNormal];
        
    }
    
    
    
    
    
    NSArray *unidArray = [requestString componentsSeparatedByString:@"?unid="];
    NSString *urlStr;
    BOOL isPush = false;
    
    
    if ([requestString hasSuffix:@"arc/arcList.html"]) {
        urlStr = @"arc/arcList.html";
        isPush = YES;
    }
    if ([requestString hasSuffix:@"arc/arcSearch.html"]) {
        urlStr = @"arc/arcSearch.html";
        isPush = YES;
    }
    
    
    // 如果为 资金计划、付款申请 URL里面有两个unid
    if ([self.urlStr isEqualToString:@"todo/pay_list.html"]||[self.urlStr isEqualToString:@"todo/plan_list.html"]) {
        
        unidArray = [requestString componentsSeparatedByString:@"?todounid="];
    }
    
    // 判断链接是否带有UnID，且在规定的URL跳转到下级界面
    if (unidArray.count > 1) {
        
        // 待审批
        if ( [self.urlStr isEqualToString:@"oa/todo.html"]) {
            
            if ([unidArray.firstObject hasSuffix:@"oa/doc.html"]) {
                urlStr = @"oa/doc.html";
                isPush = YES;
            }
            
        }
        
        // 日志
        if ([self.urlStr isEqualToString:@"work/daily_list.html"]) {
            
            if ([unidArray.firstObject hasSuffix:@"work/daily_document.html"]) {
                urlStr = @"work/daily_document.html";// 处理文件
                isPush = YES;
            }
            
        }
        
        
        // 审批
        if ([self.urlStr isEqualToString:@"oa/oa.html"]) {
            
            if ([unidArray.firstObject hasSuffix:@"oa/doc.html"]) {
                urlStr = @"oa/doc.html";// 处理文件
                isPush = YES;
            }
            //  oa/hadTodo.html
            if ([unidArray.firstObject hasSuffix:@"oa/hadDoc.html"]) {
                urlStr = @"oa/hadDoc.html";// 处理文件
                isPush = YES;
            }
            if ([unidArray.firstObject hasSuffix:@"oa/newDoc.html"]) {
                urlStr = @"oa/newDoc.html";// 处理文件
            }
            
        }
        
        // 公告
        if ([self.urlStr isEqualToString:@"oa/send_list.html"]) {
            
            if ([unidArray.firstObject hasSuffix:@"oa/send_document.html"]) {
                urlStr = @"oa/send_document.html";
                isPush = YES;
            }
        }
        
        
        // 待阅文件
        if ([self.urlStr isEqualToString:@"oa/readTodoList.html"]) {
            
            if ([unidArray.firstObject hasSuffix:@"oa/readDoc.html"]) {
                urlStr = @"oa/readDoc.html";
                isPush = YES;
            }
        }
        
        // 付款申请
        if ([self.urlStr isEqualToString:@"todo/pay_list.html"]) {
            // 采购类付款申请
            if ([unidArray.firstObject hasSuffix:@"todo/payment_purchase.html"]) {
                urlStr = @"todo/payment_purchase.html";
                isPush = YES;
                
            }
            
            // 费用类付款申请
            if ([unidArray.firstObject hasSuffix:@"todo/payment_cost.html"]) {
                urlStr = @"todo/payment_cost.html";
                isPush = YES;
                
            }
            
            // 专项类付款申请
            if ([unidArray.firstObject hasSuffix:@"todo/payment_special.html"]) {
                urlStr = @"todo/payment_special.html";
                isPush = YES;
                
            }
            
        }
        
        // 资金计划
        if ([self.urlStr isEqualToString:@"todo/plan_list.html"]) {
            
            if ([unidArray.firstObject hasSuffix:@"todo/fund_plan.html"]) {
                urlStr = @"todo/fund_plan.html";
                isPush = YES;
            }
        }
        
        
        
        
        
    }
    if (isPush) {
        
        Work_Document_VC *workDocumentVC = [[Work_Document_VC alloc]init];
        workDocumentVC.urlStr = [NSString stringWithFormat:@"%@?unid=%@",urlStr,unidArray.lastObject];
        
        // 如果为资金计划，付款申请，需要拼接两个unid
        if ([self.urlStr isEqualToString:@"todo/pay_list.html"]||[self.urlStr isEqualToString:@"todo/plan_list.html"]) {
            workDocumentVC.urlStr = [NSString stringWithFormat:@"%@?todounid=%@",urlStr,unidArray.lastObject];
            
        }
        
        [self.navigationController pushViewController:workDocumentVC animated:YES];
        return YES;
    }
    
    
    
    //根据
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
    
    
    //    if ([requestString hasSuffix:@"subClick"]) {
    //
    //        editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    //        [editButton setTitle:@"编辑" forState:UIControlStateSelected];
    //        [editButton setTitle:@"提交" forState:UIControlStateNormal];
    //        [editButton setTintColor:[UIColor whiteColor]];
    //        [editButton addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
    //        editButton.selected = NO;
    //
    //
    //        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:editButton];
    //        self.navigationItem.rightBarButtonItem=rightBtn;
    //
    //
    //
    //    }
    // 请假流程（显示或者隐藏提交按钮）
    if ([requestString hasSuffix:@"sub"]) {
        
        self.editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self.editButton  setTitle:@"提交" forState:UIControlStateSelected];
        [self.editButton  setTitle:@"提交" forState:UIControlStateNormal];
        [self.editButton  setTintColor:[UIColor whiteColor]];
        [self.editButton  addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
        self.editButton.selected = NO;
        
        
        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithCustomView:self.editButton ];
        self.navigationItem.rightBarButtonItem=rightBtn;
        
        isClickBack = YES;
        
    }
    
    
    return YES;
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.isLoading) {
        
        [SVProgressHUD dismiss];
      //  [self webViewDidFinishLoadCompletely];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
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
    // 设置请求
    
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    [NetworkManager networkWithRequest:request completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            
            NSLog(@"88888%@   ----%@", responseObject, requestString);
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 请假流程 提交成功后刷新界面
                if ([dataString isEqualToString:@"alert('提交成功!');location.href='todo.html'"]) {
                    [self initWebViewWith:@"oa/todo.html"];
                    self.urlStr = @"oa/todo.html";
                    self.navigationItem.rightBarButtonItem=nil;
                    isClickBack = NO;
                    [self setNav];
                }
                [_webView stringByEvaluatingJavaScriptFromString:dataString];
                [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"callback(%@)",dataString]];
                
                
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络请求错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            });
        }
    }];
    
    
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


@end

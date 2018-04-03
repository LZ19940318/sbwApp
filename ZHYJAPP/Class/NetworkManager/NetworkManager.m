//
//  NetworkManager.m
//  ZHYJAPP
//
//  Created by admin on 16/4/25.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetworking.h"
#import "Erro.h"
#import "DataEncoding.h"
#import "HrListViewController.h"

static NSString * const sErrorHintString = @"[combest]无效的用户名或密码";
//NSString * const APIBaseURLString = @"http://www.x-zhyj.net/";

@interface NetworkManager ()
@end

@implementation NetworkManager

+ (NSString *)sHostURLString
{
    NSString *hostURLString = [NSString stringWithFormat:@"http://%@", [DataManager sharedDataManager].hostString];
    return hostURLString;
}

+ (AFHTTPSessionManager *)userDefoaltHTTPHead{
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //    [manager setSecurityPolicy:[self customSecurityPolicy]];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *token = [user valueForKey:@"token"];
    NSString *jsessionId =[user valueForKey:@"myJsessionId"];
    //    [manager.requestSerializer setTimeoutInterval:10];
    
    
    //    [manager.requestSerializer setValue:[HTTPSessionManager getAPPVersion] forHTTPHeaderField:@"version"];
    
    
    
    [manager.requestSerializer setValue:jsessionId forHTTPHeaderField:@"jsessionid"];
    //APP版本号
    //    [manager.requestSerializer setValue:[HTTPSessionManager getAPPVersion] forHTTPHeaderField:@"version"];
    //系统版本号
    
    //    [manager.requestSerializer setValue:[HTTPSessionManager getIOSVersion] forHTTPHeaderField:@"system"];
    //手机唯一序列号
    //    [manager.requestSerializer setValue:[HTTPSessionManager getiphoneUUID] forHTTPHeaderField:@"imei"];
    //手机token号
    //    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    //
    
    return manager;
}

- (NSHTTPCookie *)cookieFromTask:(NSURLSessionDataTask *)task
{
    NSHTTPURLResponse *httpResponse = ((NSHTTPURLResponse *)task.response);
    NSHTTPCookie *cookie = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields forURL:httpResponse.URL].firstObject;
//    NSLog(@"cookieFromTask: %@", cookie);

    return cookie;
}

//cookie存入Storage
+ (void)setHTTPCookie:(NSHTTPCookie *)cookie
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookie:cookie];
}

+ (void)loginPost:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self sHostURLString]]];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //SessionManager默认解析的是json数据，所以在这里需要调用setResponseSerializer来对URL的处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 7.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager POST:[NSString stringWithFormat:@"%@/names.nsf?login", [self sHostURLString]] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"response---%@  ---  %@", responseObject, responseStr);
        NSRange range = [responseStr rangeOfString:sErrorHintString];
        
        if (NSEqualRanges(range, NSMakeRange(NSNotFound, 0))) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
          
            for (NSHTTPCookie *cookie in [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:response.URL]) {
                //                NSLog(@"%@", cookie);
                [self setHTTPCookie:cookie];
                //保存cookie
                [[DataManager sharedDataManager] saveCookie:cookie];
            }
            success(responseObject);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        failure(error);
    }];
    
    
}

//登录接口的网络请求
+ (void)loginWithUsename:(NSString *)username password:(NSString *)password completion:(completionType)completion
{
    //AFHTTPSessionManager默认解析的是JSON数据
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self sHostURLString]]];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    //SessionManager默认解析的是json数据，所以在这里需要调用setResponseSerializer来对URL的处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 7.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager POST:[NSString stringWithFormat:@"%@/names.nsf?login", [self sHostURLString]] parameters:@{@"username":username, @"password": password} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"response---%@  ---  %@", responseObject, responseStr);
        NSRange range = [responseStr rangeOfString:sErrorHintString];
 
        if (NSEqualRanges(range, NSMakeRange(NSNotFound, 0))) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//            NSLog(@"header: %@", response.allHeaderFields);
            
//            NSArray *cookieArray = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:response.URL];
//            NSLog(@"登录取出的cookieArray：%@", cookieArray);
            //在头域中取出cookie
            for (NSHTTPCookie *cookie in [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:response.URL]) {
//                NSLog(@"%@", cookie);
                [self setHTTPCookie:cookie];
                
                //保存cookie
                [[DataManager sharedDataManager] saveCookie:cookie];
            }
            completion(responseObject, nil, nil);
        }else{
            NSError *error;
            NSLog(@"error----%@", error);
            completion(nil, nil, error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        completion(nil, nil, error);
    }];
}

//+ (void)fetchOrgUnitWithUserName:(NSString *)username completion:(completionType)completion{
//
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self sHostURLString]]];
//    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    
//    //SessionManager默认解析的是json数据，所以在这里需要调用setResponseSerializer来对URL的处理
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    NSArray *cookieArray = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
//    NSString *cookieValue;
//    //遍历cookie数组，取出每个cookie的neme和value属性并拼接
//    for (NSHTTPCookie *cookie in cookieArray) {
//        NSString *key = cookie.name;
//        NSString *value = cookie.value;
//        if (cookieValue == nil) {
//            cookieValue = [NSString stringWithFormat:@"%@=%@", key, value];
//        }else{
//            cookieValue = [NSString stringWithFormat: @"%@;%@=%@", cookieValue, key, value];
//        }
//    }
//    NSLog(@"====%@", cookieValue);
//    
//    [manager.requestSerializer setValue:cookieValue forHTTPHeaderField:@"cookie" ];
//    NSString *requestStr = [NSString stringWithFormat:@"%@/domcfg.nsf/CBXsp_getServerMsg.xsp?sysName=%@", [self sHostURLString], username];
//    
//    [manager GET:requestStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
//        NSLog(@"%@", manager.requestSerializer.HTTPRequestHeaders);
////        NSDictionary *dicJson=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        completion(dataString, nil, nil);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
//        completion(nil, nil, error);
//    }];
////    [manager GET:@"domcfg.nsf/CBXsp_getzuzhidanyuan.xsp" parameters:@{@"sysName": username} success:^ void(NSURLSessionDataTask * task, id data) {
////        
////        NSError *error;
////      
////        
////    } failure:^(NSURLSessionDataTask * task, NSError * error) {
////        
////    }];
//}

//用户信息
+ (void)getUserMsgWithTime:(NSString *)time completion:(completionType)completion
{

#pragma mark 加载环信账号
  
  
   
    
    __weak typeof(self) wSelf = self;
    


    //combesterpdemo/外网hjxx   /内网/combestbkc
    NSLog(@"testOU%@", [DataManager sharedDataManager].ou);
    NSString *urlStr = [NSString stringWithFormat:@"%@/combestbkc/combest_mopcontroller.nsf/CBXsp_getUserMsg.xsp?", [self sHostURLString]];
    [[AFHTTPSessionManager manager] POST:urlStr parameters:@{@"time":time} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSString *str1 = [DataManager sharedDataManager].isFirst;
        
         // 如果已经登录了，加载后，就不需要再加载了
        if ([[DataManager sharedDataManager].isFirst isEqualToString:@"yes"]) {
            
            
            [[DataManager sharedDataManager] setIsFirst:@"yes"];

            
            
        }else{
            
            // 异步 并行队列 线程
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
//                [wSelf createData];
                [SVProgressHUD showWithStatus:@"环信用户加载！！"];
                
            });
            
        }
        
        
        
    //解析json
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
    NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        
    //删除照片base64字符串的多余的特殊字符
    NSString *photo = result[@"photo"];
        NSLog(@"poto====%@", result);
    photo = [photo stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSString *mail = result[@"mail"];
        mail = [mail stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    //需要通过新创建一个字典来修改，直接修改result[@"photo"]会造成越界
    NSMutableDictionary * resultCopy = [[NSMutableDictionary alloc] initWithDictionary:result];
    [resultCopy setObject:photo forKey:@"photo"];
    [resultCopy setObject:mail forKey:@"mail"];
    result = resultCopy;
        
    [[DataManager sharedDataManager] saveUserMsg:result];
    
    NSMutableDictionary *userIcon = [[DataManager sharedDataManager] userIcon];
    NSMutableDictionary *userIconCopy = [NSMutableDictionary dictionaryWithDictionary:userIcon];
    NSString *str = resultCopy[@"photo"];
    [userIconCopy setObject:str forKey:@"userPhoto"];
    [[DataManager sharedDataManager] saveUserIcon:userIconCopy];
    
    completion(responseObject, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        Erro *err = [[Erro alloc] initWithErro:error];
        NSLog(@"error-=-=%@----", error);
        completion(nil, nil, error);
    }];
}



/** 获取环信用户名 */
+ (void)createData{
  // [SVProgressHUD showWithStatus:@"环信用户加载！！"];

    NSString *requestUrl = [NSString stringWithFormat:@"http://%@/%@/combest_mopcontroller.nsf/CBXsp_getUserList.xsp", [DataManager sharedDataManager].hostString, [DataManager sharedDataManager].userMsg[@"ou"]];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NetworkManager sHostURLString]]];
    //SessionManager默认解析的是json数据，所以在这里需要调用setResponseSerializer来对URL的处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        
        //  [self getUserMessage];
        NSMutableArray *dataS1 = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
        NSLog(@"%@",dataS1);
        [[DataManager sharedDataManager] saveUserMessageList:dataS1];
        
        
        // 线程后台排序用户
        
        dispatch_queue_t queue= dispatch_queue_create("test.queue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(queue, ^{
            
            [NetworkManager sort];
            
        });
        
        
        
        
        
        [[DataManager sharedDataManager] setIsFirst:@"yes"];
//        [SVProgressHUD showWithStatus:@"环信缓存成功。"];
        NSLog(@"环信缓存成功");
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        
        
        
    }];
    
    
   
    
    
}


// 环信用户名排序

+(void)sort{
    
   // [SVProgressHUD showProgress:3.0];
    
    NSArray *sortArrayData = [[DataManager sharedDataManager] IMUserlist];
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:sortArrayData.count];
    NSMutableArray *indexArray = [[NSMutableArray alloc]init];
    NSMutableArray *letterResultArr = [[NSMutableArray alloc]init];
    NSMutableArray *copyLetter = [[NSMutableArray alloc]init];
    // 取出字典中的名字，进行排序
    for (int i = 0; i < sortArrayData.count; i++) {
        
        NSDictionary *dic = sortArrayData[i];
        [tempArray addObject:dic[@"cnName"]];
    }
    
    // 暂时去掉重复的名字
    NSMutableArray *listAry = [[NSMutableArray alloc]init];
    for (NSString *str in tempArray) {
        if (![listAry containsObject:str]) {
            [listAry addObject:str];
        }
    }
    
    //  名字排序，字母排序
    indexArray = [ChineseString IndexArray:listAry];
    letterResultArr = [ChineseString LetterSortArray:listAry];

    
    //  根据排序好的名字，把字典的值取出来
    for (int i = 0; i < letterResultArr.count; i++) {

        NSMutableArray *array1 = letterResultArr[i];
        NSMutableArray *array2 = [NSMutableArray array];
        
        for (int j = 0; j< array1.count; j++) {
            for (int k = 0; k < sortArrayData.count; k++) {
                NSDictionary *dic = sortArrayData[k];
                if ([dic[@"cnName"] isEqualToString:array1[j]]) {
//                    array2[j] = [dic copy] ;
                
                    [array2 addObject:dic];
                }
                
            }
            
        }
        
        copyLetter[i]=array2;
    }
    [[DataManager sharedDataManager] saveUserMessageListTitle:indexArray] ;
    [[DataManager sharedDataManager] saveUserMessageListSort:copyLetter];
    
    
}

+ (void)getUpdateVersion:(completionType)completion
{
    //NSURLSession默认是异步的
    NSString *urlString = [NSString stringWithFormat:@"%@/app/iosversion.xml", [self sHostURLString]];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            completion(data, nil, nil);
        }else{
            completion(nil, nil, error);
        }
    }];
    [task resume];
}

//cookie失效,掉线重连
//判断返回的数据是否包含错误提示字段，不包含则返回当前的结果，包含则需要重新发送登录请求，成功后重新转发当前请求。
//+ (void)networkWithRequest:(NSMutableURLRequest *)request completion:(completionType)completion
//{
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self sHostURLString]]];
//    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    
//    //SessionManager默认解析的是json数据，所以在这里需要调用setResponseSerializer来对URL的处理
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager POST:[request.URL absoluteString] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            
//            NSString *resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//            NSRange range = [resultStr rangeOfString:sErrorHintString];
//            if (range.location == NSNotFound) {
//                completion(responseObject, task.response, nil);
//            }else{
//                NSString *password = [[DataManager sharedDataManager] password];
//                password = [DataEncoding decodeInBase64:password];
//                password = [DataEncoding decryptUseDES:password key:@"password"];
//                [self loginWithUsename:[[DataManager sharedDataManager] username] password:password completion:^(id responseObject, NSURLResponse *response, NSError *error) {
//                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//                    NSLog(@"statusCode: %ld", (long)httpResponse.statusCode);
//                    if (error == nil) {
//                        //登录后重新发送该请求
//                        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response,  NSError * _Nullable error) {
//                            if (error == nil) {
//                                completion(data, response, nil);
//                            }
//                        }];
//                        [task resume];
//                    }
//                    
//                    }];
//            }
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        completion(@"", nil, error);
//    }];
//}
//获取环信用户的信息
+ (void)requireUserMessageWithRequest:(NSString *)request completion:(completionType)completion
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self sHostURLString]]];
//    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

    //SessionManager默认解析的是json数据，所以在这里需要调用setResponseSerializer来对URL的处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager POST:request parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            NSString *resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSRange range = [resultStr rangeOfString:sErrorHintString];
            if (range.location == NSNotFound) {
                completion(responseObject, task.response, nil);
            }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(@"", nil, error);
    }];
}


+ (void)networkWithRequest:(NSMutableURLRequest *)request completion:(completionType)completion
{
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"测试是否会死循环：！！！");
        if (error == nil) {
            if (data) {
                NSRange range = [resultStr rangeOfString:sErrorHintString];
                if (range.location == NSNotFound) {
                    completion(data, response, nil);
                }else{
                    NSString *username = [[DataManager sharedDataManager] username];
                    NSString *password = [[DataManager sharedDataManager] password];
                    password = [DataEncoding decodeInBase64:password];
                    password = [DataEncoding decryptUseDES:password key:@"password"];
                    [self loginWithUsename:username password:password completion:^(id responseObject, NSURLResponse *response, NSError *error) {
                        if (error == nil) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                            NSLog(@"statusCode: %ld", (long)httpResponse.statusCode);
                            
                            //登录后重新发送该请求
                            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response,  NSError * _Nullable error) {
                                completion(data, response, nil);
                            }];
                            [task resume];
                        }
                        
                    }];
                }
            }else{
                completion(@"", nil, error);
            }
        }else{
            completion(@"", nil, error);
        }
    }];
    [task resume];
}



+ (void)CheckThefastID{
    
   
    __block NSInteger c1,c2,c3;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    //判断域名
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 5.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager POST:[NSString stringWithFormat:@"http://%@", testIP1]  parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDate* dat1 = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval b=[dat1 timeIntervalSince1970]*1000;
        NSInteger c = b - a;
        c1 = c;
        
        NSDate* dat2 = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a1=[dat2 timeIntervalSince1970]*1000;
        //判断域名
        AFHTTPSessionManager *manager1 = [AFHTTPSessionManager manager];
        manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager1.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager1.requestSerializer.timeoutInterval = 5.f;
        [manager1.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        [manager1 POST:[NSString stringWithFormat:@"http://%@", testIP2]  parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDate* dat2 = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval b2=[dat2 timeIntervalSince1970]*1000;
            NSInteger c = b2 - a1;
            c2 = c;
            
            //判断域名
            NSDate* dat3 = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a3=[dat3 timeIntervalSince1970]*1000;
            AFHTTPSessionManager *manager3 = [AFHTTPSessionManager manager];
            manager3.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager3.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            manager3.requestSerializer.timeoutInterval = 3.f;
            [manager3.requestSerializer didChangeValueForKey:@"timeoutInterval"];
            [manager3 POST:[NSString stringWithFormat:@"http://%@", testIP3]  parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDate* dat3 = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval b3=[dat3 timeIntervalSince1970]*1000;
                NSInteger c = b3 - a3;
                c3 = c;
                
                
                if (c1 < c2) {
                    if (c1 < c3) {
                        [[DataManager sharedDataManager] testIDSave:testIP1];
                    }else{
                        [[DataManager sharedDataManager] testIDSave:testIP3];
                    }
                    
                    
                }else{
                    if (c2 < c3) {
                        [[DataManager sharedDataManager] testIDSave:testIP2];
                    }else{
                        [[DataManager sharedDataManager] testIDSave:testIP3];
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                c3 = 10000;
                if (c1 < c2) {
                    if (c1 < c3) {
                        [[DataManager sharedDataManager] testIDSave:testIP1];
                    }else{
                        [[DataManager sharedDataManager] testIDSave:testIP3];
                    }
                    
                }else{
                    if (c2 < c3) {
                        [[DataManager sharedDataManager] testIDSave:testIP2];
                    }else{
                        [[DataManager sharedDataManager] testIDSave:testIP3];
                    }
                }
                
            }];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [[DataManager sharedDataManager] testIDSave:testIP1];
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        c1 = 1000;
        //        [[DataManager sharedDataManager] testIDSave:testIP2];
        NSDate* dat2 = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a1=[dat2 timeIntervalSince1970]*1000;
        //判断域名
        AFHTTPSessionManager *manager1 = [AFHTTPSessionManager manager];
        manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager1.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager1.requestSerializer.timeoutInterval = 5.f;
        [manager1.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        [manager1 POST:[NSString stringWithFormat:@"http://%@", testIP2]  parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDate* dat2 = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval b2=[dat2 timeIntervalSince1970]*1000;
            NSInteger c = b2 - a1;
            c2 = c;
            
            //判断域名
            NSDate* dat3 = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a3=[dat3 timeIntervalSince1970]*1000;
            AFHTTPSessionManager *manager3 = [AFHTTPSessionManager manager];
            manager3.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager3.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            manager3.requestSerializer.timeoutInterval = 3.f;
            [manager3.requestSerializer didChangeValueForKey:@"timeoutInterval"];
            [manager3 POST:[NSString stringWithFormat:@"http://%@", testIP3]  parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDate* dat3 = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval b3=[dat3 timeIntervalSince1970]*1000;
                NSInteger c = b3 - a3;
                c3 = c;
                
                
                if (c1 < c2) {
                    if (c1 < c3) {
                        [[DataManager sharedDataManager] testIDSave:testIP1];
                    }else{
                        [[DataManager sharedDataManager] testIDSave:testIP3];
                    }
                    
                    
                }else{
                    if (c2 < c3) {
                        [[DataManager sharedDataManager] testIDSave:testIP2];
                    }else{
                        [[DataManager sharedDataManager] testIDSave:testIP3];
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [[DataManager sharedDataManager] testIDSave:testIP2];
                
            }];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //            [self showAlertTitle:@"温馨提示" WithMessage:@"当前网路不可用，请检查网络"];
        }];
        
        NSLog(@"%@==", error);
    }];
}




+ (NSURLSessionTask *)get:(NSString *)url andJsessionId:(NSString *)jsessionId params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    
    
    //    /**  如果没有网络，直接return  */
    //    NSString *netWorkFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"AFNetworkReachabilityStatusNotReachable"];
    //    /**  1为没有网络  */
    //    if ([netWorkFlag isEqualToString:@"1"]) {
    //        [self loadViewAnimation:@"没有网络，请检查网络情况"];
    //        return nil;
    //    }
    
    
    
    AFHTTPSessionManager *session = [NetworkManager userDefoaltHTTPHead];
    
    
    
    NSURLSessionTask *task = [session GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        
        success(responseObject);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
    
    return task;
}

- (NSString *)getTime{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
    
}



@end






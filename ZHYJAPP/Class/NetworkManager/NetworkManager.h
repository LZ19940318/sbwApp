//
//  NetworkManager.h
//  ZHYJAPP
//
//  Created by admin on 16/4/25.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Erro.h"

typedef void (^completionType)(id responseObject, NSURLResponse *response, NSError *error);//登录后必须有请求成功但是数据错误的返回，所以不使用

@interface NetworkManager : NSObject


+ (void)loginPost:(NSString *)url  params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;


+ (NSString *)sHostURLString;

//登录
+ (void)loginWithUsename:(NSString *)username password:(NSString *)password completion:(completionType)completion;

//获取用户信息
+ (void)getUserMsgWithTime:(NSString *)time completion:(completionType)completion;

+ (void)getUpdateVersion:(completionType)completion;

+ (void)networkWithRequest:(NSMutableURLRequest *)request completion:(completionType)completion;
//获取用户环信的信息
+ (void)requireUserMessageWithRequest:(NSString *)request completion:(completionType)completion;

+ (void)fetchOrgUnitWithUserName:(NSString *)username completion:(completionType)completion;

+ (void)CheckThefastID;

+ (NSURLSessionTask *)get:(NSString *)url andJsessionId:(NSString *)jsessionId params:(NSDictionary *)params
                  success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

//获取用户环信的信息
+ (void)createData;
+ (void)sort;


+ (void)PushListHRWithUNID:(NSString *)unid;
@end



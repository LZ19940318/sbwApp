//
//  Erro.h
//  ZHYJAPP
//
//  Created by admin on 16/4/25.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NetworkErrorCode)
{
    ZHYJNetworkErrorNetwork        = 8202,
    ZHYJNetworkErrorCodeNotFound   = 1001,
    ZHYJNetworkErrorCodeNotAuth    = 8192,
    ZHYJNetworkErrorJSONDataFormat = 8201,
    ZHYJNetworkErrorAccount        = 8205
};

@interface Erro : NSObject

@property (nonatomic, assign)NSInteger errorCode;
@property (nonatomic, copy)id reason;

//自定义的封装错误代码的方法
- (instancetype)initWithCode:(NSInteger)code;
- (instancetype)initWithErro:(NSError *)error;
- (instancetype)errorWithCode:(NSInteger)code;



@end












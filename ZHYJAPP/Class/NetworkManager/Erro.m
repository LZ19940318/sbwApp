//
//  Erro.m
//  ZHYJAPP
//
//  Created by admin on 16/4/25.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "Erro.h"


NSString * const ZHYJNetworkErrorDomain = @"www.x-zhyj.net";

@implementation Erro

- (instancetype)initWithCode:(NSInteger)code
{
    if (self = [super init]) {
        _errorCode = code;
    }
    return self;
}

- (instancetype)initWithErro:(NSError *)error
{
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)errorWithCode:(NSInteger)code
{
    return [[[self class] alloc] initWithCode:code];
}

- (NSString *)explainErrorCode
{
    id reason = nil;
    switch (ZHYJNetworkErrorNetwork) {
        case ZHYJNetworkErrorNetwork:
            reason = [NSError errorWithDomain:ZHYJNetworkErrorDomain code:ZHYJNetworkErrorNetwork userInfo:@{NSLocalizedDescriptionKey: @"网络异常，请稍后重试！"}];
            break;
        case ZHYJNetworkErrorCodeNotAuth:
            reason = @"没有登录";
            break;
        case ZHYJNetworkErrorJSONDataFormat:
            reason = [NSError errorWithDomain:ZHYJNetworkErrorDomain code:ZHYJNetworkErrorJSONDataFormat userInfo:@{NSLocalizedDescriptionKey: @"接收到的数据格式错误！"}];
            break;
        case ZHYJNetworkErrorAccount:
            reason = [NSError errorWithDomain:ZHYJNetworkErrorDomain code: ZHYJNetworkErrorAccount userInfo:@{NSLocalizedDescriptionKey:@"用户名或密码错误！"}];
        default:
            break;
    }
    return reason;
}

//- (BOOL)isChinese
//{
//    NSString *regex = @"^[\u4e00-\u9fa5]{0,}$";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    
//    return [predicate evaluateWithObject:self];
//}

- (NSString *)reason
{
    if (!_reason ) {
        _reason = [self explainErrorCode];
    }
    return _reason;
}




@end



//
//  DataManager.m
//  ZHYJAPP
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "DataManager.h"
#import "DataEncoding.h"

static NSString *const sUsernameKey = @"UsernameKey";
static NSString *const sPasswordKey = @"PasswordKey";
static NSString *const sUserMsgKey  = @"UserMsgKey";
static NSString *const sUserIconKey = @"UserIcon";
static NSString *const sUserImage = @"UserIMImage";
static NSString *const sUserIMUserList = @"UserIMUserList";
static NSString *const sUserIMUserListSort = @"UserIMUserListSort";
static NSString *const sUserIMUserListTitle = @"sUserIMUserListTitle";
static NSString *const sUserID = @"UserID";
static NSString *const sUserOU = @"UserOU";
static NSString *const sUserPhoto = @"sUserPhoto";

static NSString *const sAccess_token = @"sAccess_token";
static NSString *const sClloctionDic = @"sClloctionDic";


@interface DataManager ()

@end

@implementation DataManager

+ (DataManager *)sharedDataManager
{
    static DataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DataManager alloc] init];
    });
    return sharedManager;
}

//保存用户名密码，加密密码，用户名不加密，方便获取account
- (void)saveUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUsernameKey];
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:sUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//获取用户名
- (NSString *)username
{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:sUsernameKey];
    return name;
}

- (void)savePassword:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sPasswordKey];
    password = [DataEncoding encryptUseDES:password key:@"password"];//base64编码
    password = [DataEncoding stringEncodeInBase64:password]; //DES加密
    //将加密后的密码保存
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:sPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//获取密码
- (NSString *)password
{
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:sPasswordKey];
    return pwd;
}
//保存用户的头像图片路径
- (void)saveUserImage:(NSString *)ImagePath
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserImage];
    [[NSUserDefaults standardUserDefaults] setObject:ImagePath forKey:sUserImage];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//获取头像
- (NSString *)IMImagePath
{
    NSString *imageIM = [[NSUserDefaults standardUserDefaults] objectForKey:sUserImage];
    return imageIM;
}

/**
 
 //保存用户头像
 - (void)saveUserPhoto:(NSString *)userPhoto;
 //获取头像
 - (NSString *)userPhoto;
 */


//保存用户的头像图片路径
- (void)saveUserPhoto:(NSString *)ImagePath
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserPhoto];
    [[NSUserDefaults standardUserDefaults] setObject:ImagePath forKey:sUserPhoto];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//获取头像
- (NSString *)userPhoto
{
    NSString *imageIM = [[NSUserDefaults standardUserDefaults] objectForKey:sUserPhoto];
    return imageIM;
}

//保存域名
- (void)testIDSave:(NSString *)testID{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserID];
    [[NSUserDefaults standardUserDefaults] setObject:testID forKey:sUserID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)testID{
    
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:sUserID];
    return name;
}

- (void)saveOU:(NSString *)ou{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserOU];
    [[NSUserDefaults standardUserDefaults] setObject:ou forKey:sUserOU];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
// get方法，获取 OU
- (NSString *)ou{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:sUserOU];
    return name;
}

//获取yonghu
- (NSArray *)IMUserlist{
    
    NSArray *IMList = [[NSUserDefaults standardUserDefaults] objectForKey:sUserIMUserList];
    
    if (IMList.count == 0) {
        //1. 创建一个plist文件
       /*
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [path objectAtIndex:0];
        NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"test.plist"];
        */
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"plist"];
        NSArray *data = [[NSArray alloc] initWithContentsOfFile:plistPath];
       // NSLog(@"%@", data);//直接打印数据。
//        [self saveUserMessageList:data];
        return data;
    }

    return IMList;
}

//获取yonghu排序
- (NSArray *)IMUserlistSort{
    NSArray *IMList = [[NSUserDefaults standardUserDefaults] objectForKey:sUserIMUserListSort];
    return IMList;
}

//获取yonghu字母排序
- (NSArray *)IMUserTitle{
    
    NSArray *IMList = [[NSUserDefaults standardUserDefaults] objectForKey:sUserIMUserListTitle];
    return IMList;
}

//保存用户列表信息
- (void)saveUserMessageList:(NSArray *)IMUserlist{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserIMUserList];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"test1.plist"];
    [IMUserlist writeToFile:plistPath atomically:YES];
    
    
    
    [[NSUserDefaults standardUserDefaults] setObject:IMUserlist forKey:sUserIMUserList];
    
    
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
  //  [NetworkManager sort];

}
//保存用户列表信息排序
- (void)saveUserMessageListSort:(NSArray *)IMUserlistSort{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserIMUserListSort];
    [[NSUserDefaults standardUserDefaults] setObject:IMUserlistSort forKey:sUserIMUserListSort];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveUserMessageListTitle:(NSArray *)IMUserlistTitle{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserIMUserListTitle];
    [[NSUserDefaults standardUserDefaults] setObject:IMUserlistTitle forKey:sUserIMUserListTitle];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//清空用户名密码
- (void)clearUsername:(NSString *)username andPwd:(NSString *)pwd
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:sUsernameKey];
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:sPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//get方法
//设置主机名//盛大金禧：10.130.10.35
//@"192.168.10.202";
- (NSString *)hostString
{
//    return [self testID];
//    return @"www.x-zhyj.net";
//    return @"192.168.10.202";
    return @"sbwoa.shengu.com.cn";
//    return @"mobile.x-zhyj.net";
//    return @"hjxx.x-zhyj.net";
//    return @"mails.shengu.com.cn";// 沈鼓测试内网
//      return @"192.168.10.52";
}

static NSHTTPCookie *sCookie;
- (void)saveCookie:(NSHTTPCookie *)cookie
{
    sCookie = cookie;
}

- (NSHTTPCookie *)cookie
{
    return sCookie;
}

- (void)saveUserMsg:(NSMutableDictionary *)userMsg
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserMsgKey];
    [[NSUserDefaults standardUserDefaults] setObject:userMsg forKey:sUserMsgKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableDictionary *)userMsg
{
    NSMutableDictionary *userMessage = [[NSUserDefaults standardUserDefaults] objectForKey:sUserMsgKey];
    return userMessage;
}

- (void)saveUserIcon:(NSMutableDictionary *)userIcon
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sUserIconKey];
    [[NSUserDefaults standardUserDefaults] setObject:userIcon forKey:sUserIconKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableDictionary *)userIcon
{
    NSMutableDictionary *userIconInfo = [[NSUserDefaults standardUserDefaults] objectForKey:sUserIconKey];
    return userIconInfo;
}

- (NSString *)cookieValue
{
    //1.取出cookie
    NSArray *cookieArray = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    NSString *cookieValue;
    //遍历cookie数组，取出每个cookie的neme和value属性并拼接
    for (NSHTTPCookie *cookie in cookieArray) {
        NSString *key = cookie.name;
        NSString *value = cookie.value;
        if (cookieValue == nil) {
            cookieValue = [NSString stringWithFormat:@"%@=%@", key, value];
        }else{
            cookieValue = [NSString stringWithFormat: @"%@;%@=%@", cookieValue, key, value];
        }
    }
    return cookieValue;
}


//

- (void)saveaccess_token:(NSString *)access_token{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sAccess_token];
    [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:sAccess_token];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (NSString *)access_token{
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:sAccess_token];
    return token;
    
    
}


- (void)saveClloction:(NSDictionary *)clloctionDic{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sClloctionDic];
    [[NSUserDefaults standardUserDefaults] setObject:clloctionDic forKey:sClloctionDic];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

- (NSDictionary *)clloctionDic{
    
    NSDictionary *clloctionDic = [[NSUserDefaults standardUserDefaults]objectForKey:sClloctionDic];
    return  clloctionDic;
}
- (void)setIsFirst:(NSString *)isFirst{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isFirst"];
    [[NSUserDefaults standardUserDefaults] setObject:isFirst forKey:@"isFirst"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}
- (NSString *)isFirst{
    
    NSString *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"isFirst"];
    return temp;
}

@end




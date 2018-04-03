//
//  DataManager.h
//  ZHYJAPP
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSString *hostString;
@property (nonatomic, strong) NSMutableDictionary *putDic;
@property (nonatomic, strong) NSMutableArray *userLocation;
@property (nonatomic, strong)  NSString *isFirst;

+ (DataManager *)sharedDataManager;

// set方法，保存 username
- (void)saveUsername:(NSString *)username;
// get方法，获取 username
- (NSString *)username;


// set方法，保存 OU
- (void)saveOU:(NSString *)ou;
// get方法，获取 OU
- (NSString *)ou;

// set方法，保存  password
- (void)savePassword:(NSString *)password;
// get方法，获取  password
- (NSString *)password;

//清除用户名密码
- (void)clearUsername:(NSString *)username andPwd:(NSString *)pwd;

- (void)saveCookie:(NSHTTPCookie *)cookie;
- (NSHTTPCookie *)cookie;

- (void)saveUserMsg:(NSMutableDictionary *)userMsg;
- (NSMutableDictionary *)userMsg;

- (void)saveUserIcon:(NSMutableDictionary *)userIcon;
- (NSMutableDictionary *)userIcon;

//保存用户头像
- (void)saveUserImage:(NSString *)ImagePath;
//获取头像
- (NSString *)IMImagePath;


//保存用户头像
- (void)saveUserPhoto:(NSString *)userPhoto;
//获取头像
- (NSString *)userPhoto;


//保存用户列表信息
- (void)saveUserMessageList:(NSArray *)IMUserlist;
- (void)saveUserMessageListSort:(NSMutableArray *)IMUserlistSort;
- (void)saveUserMessageListTitle:(NSArray *)IMUserlistTitle;

//获取yonghu
- (NSArray *)IMUserlist;
- (NSMutableArray *)IMUserlistSort;
- (NSArray *)IMUserTitle;

//保存域名
- (void)testIDSave:(NSString *)testID;
- (NSString *)testID;
//- (void)savePutDic:(NSMutableDictionary *)putDic;
//- (NSMutableDictionary *)putDic;

- (NSString *)cookieValue;

//- (void)saveUserLocation:(NSArray *)userLocation;
//- (NSArray *)userLocation;




// set方法，保存 access_token
- (void)saveaccess_token:(NSString *)access_token;
// get方法，获取 access_token
- (NSString *)access_token;



// set方法，保存 Clloction
- (void)saveClloction:(NSDictionary *)clloctionDic;
// get方法，获取 Clloction
- (NSDictionary *)clloctionDic;





@end





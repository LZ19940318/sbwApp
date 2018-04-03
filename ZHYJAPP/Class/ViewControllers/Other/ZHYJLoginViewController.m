//
//  ZHYJLoginViewController.m
//  ZHYJAPP
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ZHYJLoginViewController.h"
#import "ZHYJWebViewController.h"
#import "DataEncoding.h"
#import "Erro.h"

#import "TabBarVC.h"

#import "AFNetworking.h"



@interface ZHYJLoginViewController () {
    
    NSMutableArray *dataS;
 
}


@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (assign, nonatomic) BOOL isSwitchOn;
@property (strong, nonatomic) UISwitch *isRememberPwd;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

@end

@implementation ZHYJLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //输入框的清除按钮设置
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTextField.clearButtonMode  = UITextFieldViewModeWhileEditing;

    self.loginBtn.layer.cornerRadius = 1.0f;
    self.switchBtn.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
    _isSwitchOn = YES;

    
#ifdef DEBUG
//    self.nameTextField.text = @"admin";
//    self.pwdTextField.text  = @"1";
#endif
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_nameTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
}

- (IBAction)switchBtn:(UISwitch *)sender {
    _isRememberPwd = sender;
    _isSwitchOn = [sender isOn];
    if (_isSwitchOn) {
        _isRememberPwd.tag = 1;
    }else{
        _isRememberPwd.tag = 0;
    }
}
- (IBAction)registAction:(id)sender {

    
//    NSLog(@"需要注册");
//    RegistVC *registVc = [[RegistVC alloc] init];
//    [self presentViewController:registVc animated:YES completion:nil];
}

- (IBAction)loginClick:(UIButton *)sender {
    
//    
//    self.nameTextField.text = @"sgjt";
//    self.pwdTextField.text = @"1234sgjt";
    
    //两个都不能为空，条件合并再取反
    if (!(self.nameTextField.text.length > 0 && (self.pwdTextField.text.length > 0)))
    {
        [MsgToolBox controller:self showAlert:@"登录失败" content:@"用户名或密码不能为空"];

        return;
    }
    self.view.userInteractionEnabled = NO;//设置页面不能点击
    [SVProgressHUD showWithStatus:@"正在加载中，请稍后。"];
    
    
    //登录
    /** 用户名*/
    NSString *nameStr = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    /** 密码 */
    NSString *passWordStr = [self.pwdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    

    __weak typeof(self) wSelf = self;

    
    
    [NetworkManager loginWithUsename:nameStr password:passWordStr completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"denglu %@  %@", dataString, error);
        
        // 登录成功
        if (responseObject && ![responseObject isEqual:@""] && responseObject != nil) {
            [SVProgressHUD dismiss];
            
           
            
            // 登录成功，获取用户的信息
            
            [wSelf getUserMessage];

//            [wSelf createData];
          
        }else{
            [SVProgressHUD dismiss];
            
            if ([responseObject isEqualToString:@""] || responseObject == nil) {
                [MsgToolBox controller:self showAlert:@"登录失败" content:@"账号或密码错误，请重新输入。"];
//                [MsgToolBox controller:self showAlert:@"登录失败" content:@"网络似乎开了点小差"];


            }else{
               [MsgToolBox controller:self showAlert:@"登录失败" content:@"网络似乎开了点小差"];

                
            }
        }
        self.view.userInteractionEnabled = YES;
    }];
    

}


// 获取用户的个人信息
-(void)getUserMessage{

    [SVProgressHUD showWithStatus:@"加载用户信息。"];
    //登录成功后从后台获取用户信息
    [NetworkManager getUserMsgWithTime:@"0" completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        NSLog(@"-----%@    %@", responseObject, error);
        if (error == nil) {
            //用户信息请求成功
            //环信注册 登录
            EMError *error1 = [[EMClient sharedClient] loginWithUsername:[DataManager sharedDataManager].userMsg[@"ImUserName"] password:[DataManager sharedDataManager].userMsg[@"ImPassWord"]];
            NSLog(@"登录error%@", error1);
            
            if (error1 ==nil || error == NULL) {
                [[DataManager sharedDataManager] saveUsername:[self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                //记住密码并保存到本地
                [[DataManager sharedDataManager] savePassword:self.pwdTextField.text];
                
                NSLog(@"%@  %@", [DataManager sharedDataManager].username, [DataManager sharedDataManager].password);
                //            BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
                //            if (!isAutoLogin) {
                //                EMError *error = [[EMClient sharedClient] loginWithUsername:[DataManager sharedDataManager].username password:@"111111"];
                //            }else{
                //
                //            }
            }else{
                switch (error1.code)
                {
                    case EMErrorNetworkUnavailable:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                        break;
                    case EMErrorServerNotReachable:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                        break;
                    case EMErrorUserAuthenticationFailed:
                        TTAlertNoTitle(error1.errorDescription);
                        break;
                    case EMErrorServerTimeout:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                        break;
                    default:
                        TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
                        break;
                }
                
            }
            
            TabBarVC *webViewController = [TabBarVC new];
            [ChatDemoHelper shareHelper].mainVC = webViewController;
            
            [[ChatDemoHelper shareHelper] asyncGroupFromServer];
            [[ChatDemoHelper shareHelper] asyncConversationFromDB];
            [[ChatDemoHelper shareHelper] asyncPushOptions];
            [SVProgressHUD dismiss];
            [UIApplication sharedApplication].keyWindow.rootViewController = webViewController;
        }else{
            [SVProgressHUD dismiss];
            [MsgToolBox controller:self showAlert:@"登录失败" content:@"网络似乎开了点小差"];
            
        }
        
    }];
    
    
}




@end






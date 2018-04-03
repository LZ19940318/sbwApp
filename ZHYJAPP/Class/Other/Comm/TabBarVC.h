//
//  TabBarVC.h
//  ZHYJAPP
//
//  Created by shuang wu on 16/9/28.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallViewController.h"
#import "EMCallSession.h"
@interface TabBarVC : UITabBarController
{
        EMConnectionState _connectionState;
    
}
@property (strong, nonatomic) CallViewController *callController;
@property (strong, nonatomic) EMCallSession *callSession;
- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;

- (void)setupUnreadMessageCount;

- (void)networkChanged:(EMConnectionState)connectionState;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)playSoundAndVibration;

- (void)showNotificationWithMessage:(EMMessage *)message;

@end

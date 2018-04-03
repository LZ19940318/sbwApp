//
//  AppDelegate.h
//  ZHYJAPP
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) NetworkStatus netStatus;

//- (void)showAlertTitle:(NSString *)title WithMessage:(NSString *)message;

@end


//
//  BeseViewController.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MESBeseViewController.h"
#import "CustomURLProtocol.h"
#import "RNCachingURLProtocol.h"

@interface MESBeseViewController ()

@end

@implementation MESBeseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 注册与js交互的协议 
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

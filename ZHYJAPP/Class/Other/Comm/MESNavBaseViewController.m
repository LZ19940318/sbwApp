//
//  MESNavBaseViewController.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/29.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MESNavBaseViewController.h"

@interface MESNavBaseViewController ()

@end

@implementation MESNavBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setBackButton];
}


- (void)setBackButton{
    
    
    
    UIControl *leftControl = [[UIControl alloc]initWithFrame:CGRectMake(-25, (44-20)/2, 15, 20)];
    [leftControl addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];//设置按钮点击事件
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 20)];
    imageView.image = [UIImage imageNamed:@"back.png"];
    [leftControl addSubview:imageView];
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 35, 20)];
    titleLable.text = @"返回";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont systemFontOfSize:16];
    [leftControl addSubview:titleLable];
    
//    [leftControl setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];//设置按钮正常状态图片
    
    UIBarButtonItem *leftBarButon = [[UIBarButtonItem alloc]initWithCustomView:leftControl];
    self.navigationItem.leftBarButtonItem = leftBarButon;
    
    
}

- (void)btnClicked{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

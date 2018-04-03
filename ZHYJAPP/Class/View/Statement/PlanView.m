//
//  PlanView.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/21.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "PlanView.h"

@implementation PlanView{
    
    BackButtonTagBlock tempButtloTagBlock;
    CGFloat width;
}

- (instancetype)initWithFrame:(CGRect)frame withButtonTag:(BackButtonTagBlock)buttonTagBlock{
    
    tempButtloTagBlock = [buttonTagBlock copy];
    
    if (self = [super initWithFrame:frame]) {
        width = frame.size.width;
        [self createView];
        self.backgroundColor = [UIColor colorWithRed:158.0/255 green:161.0/255 blue:166.0/255 alpha:1];
    }
    return self;
}

- (void)createView{
    
    
    // 出售计划
    UIControl *button4 = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, width, 40)];
    button4.tag = 24;
    UIImageView *imageView3 =[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 25, 25)];
    imageView3.image = [UIImage imageNamed:@"youjian.png"];
    imageView3.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView3.frame) + 5, 0, 80, 40)];
    label3.text = @"已读邮件";
    [button4 addSubview:imageView3];
    [button4 addSubview:label3];
    [button4 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button4];
    
    // 生产计划
    UIControl *produceButton = [[UIControl alloc]initWithFrame:CGRectMake(0, 40, width, 40)];
    produceButton.tag = 21;
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 25, 25)];
    imageView.image = [UIImage imageNamed:@"fa.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, 80, 40)];
    label.text = @"发件箱";
    [produceButton addSubview:imageView];
    [produceButton addSubview:label];
    [produceButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:produceButton];
    
    
    // 出售计划
    UIControl *saleButton = [[UIControl alloc]initWithFrame:CGRectMake(0, 80, width, 40)];
    saleButton.tag = 22;
    UIImageView *imageView1 =[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 25, 25)];
    imageView1.image = [UIImage imageNamed:@"cao.png"];
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView1.frame) + 5, 0, 80, 40)];
    label1.text = @"草稿箱";
    [saleButton addSubview:imageView1];
    [saleButton addSubview:label1];
    [saleButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saleButton];
    
    // 出售计划
    UIControl *button3 = [[UIControl alloc]initWithFrame:CGRectMake(0, 120, width, 40)];
    button3.tag = 23;
    UIImageView *imageView2 =[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 25, 25)];
    imageView2.image = [UIImage imageNamed:@"xie.png"];
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView2.frame) + 5, 0, 80, 40)];
    label2.text = @"写信";
    [button3 addSubview:imageView2];
    [button3 addSubview:label2];
    [button3 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button3];
    
   
    
}
- (void)click:(UIButton *)sender{
    tempButtloTagBlock(sender.tag);

    [self removeFromSuperview];

}

@end

//
//  PopViewController.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/6/17.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "PopViewController.h"

@interface PopViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *_talbelview;
    NSArray *_dataArray;
    NSArray *_imageArray;
    NSArray *_titleArray;
}

@end

@implementation PopViewController

- (instancetype)init{
    if (self = [super init]) {
//        CGRect rect = CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height);
//        self.view.frame = rect;
//        
        
    }
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initView];
}

- (void)initView{
    self.view.backgroundColor = [UIColor whiteColor];
    _imageArray = @[@"邮件.png",@"发件箱.png",@"草稿箱.png",@"写信.png"];
    _titleArray = @[@"已读邮件",@"发件箱",@"草稿箱",@"写信"];
    _talbelview = [[UITableView alloc]initWithFrame:self.view.bounds];
    _talbelview.delegate = self;
    _talbelview.dataSource = self;
    _talbelview.backgroundColor = [UIColor grayColor];
    _talbelview.scrollEnabled = YES;
    _talbelview.bounces = NO;
    [self.view addSubview:_talbelview];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *popCell = @"popCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:popCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:popCell];
    }
    
    cell.textLabel.text = _titleArray[indexPath.row];
    CGRect rect = cell.imageView.frame;
    rect.size.width = 20;
    rect.size.height = 20;
    cell.imageView.frame = rect;

    cell.imageView.image = [UIImage imageNamed:_imageArray[indexPath.row]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"popClick" object:indexPath];
}


//重置本控制器的大小
-(CGSize)preferredContentSize{
    
    if (self.popoverPresentationController != nil) {
        CGSize tempSize ;
        tempSize.height = self.view.frame.size.height;
        tempSize.width  = 155;
        CGSize size = [_talbelview sizeThatFits:tempSize];  //返回一个完美适应tableView的大小的 size
        return size;
    }else{
        return [super preferredContentSize];
    }
    
}


- (void)setPreferredContentSize:(CGSize)preferredContentSize{
    
    super.preferredContentSize = preferredContentSize;
}

@end

//
//  ChooseDataView.h
//  ZHYJAPP
//
//  Created by shuang wu on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetTagBlock)(NSInteger buttonTag);
typedef void(^GetTimeStrBlock)(NSString *timeString);

@interface ChooseDataView : UIView

- (instancetype)initWithFrame:(CGRect)frame withTagBlock:(GetTagBlock)tagBlock withTimeStr:(GetTimeStrBlock) timeStrBlock;

@end

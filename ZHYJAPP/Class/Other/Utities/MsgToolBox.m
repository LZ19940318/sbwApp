//
//  MsgToolBox.m
//  ZHYJAPP
//
//  Created by admin on 16/8/30.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "MsgToolBox.h"

@implementation MsgToolBox

+(void)controller:(id)vc showAlert :(NSString *)title content:(NSString *)content{
    
    float systemVersion =  [[UIDevice currentDevice].systemVersion floatValue];
    if (systemVersion > 8) {
        UIAlertController *alertVCtrl = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
        
       [vc presentViewController:alertVCtrl animated:YES completion:nil];
        
        
        
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVCtrl addAction:cancel];
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    }
    

    
    
}




@end

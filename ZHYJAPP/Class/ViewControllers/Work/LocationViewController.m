//
//  LocationViewController.m
//  ZHYJAPP
//
//  Created by shuang wu on 17/4/19.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "LocationViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

//#import "KCAnnotation.h"

#import "KNLocationConverter.h"

@interface LocationViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>{
    
    CLLocationManager *_locationManager;
    MKMapView *_mapView;
    NSString *title1;
    CLLocationCoordinate2D coordinate;
    
//    KCAnnotation *annotation1;
    NSString *title2;
   
    
}

@end

@implementation LocationViewController

- (void)viewDidLoad {
    
    _locationManager = [[CLLocationManager alloc]init];
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"   定位服务当前可能尚未打开，请设置打开 ");
        
        return;
    }
//    [_locationManager requestWhenInUseAuthorization];

    
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        [_locationManager requestWhenInUseAuthorization];
    }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways ){
        //设置代理
        _locationManager.delegate=self;
        //设置定位精度
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance=10.0;//十米定位一次
        _locationManager.distanceFilter=distance;
        
       
    }
    //启动跟踪定位
    [_locationManager startUpdatingLocation];
    
    [self initGUI];
    
    [self initWeb];
}

- (void)initWeb{
    
}
- (void)initGUI{
    
    _mapView = [[MKMapView alloc]initWithFrame:self.view.frame];
    _mapView.delegate = self;
    //    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    _mapView.mapType = MKMapTypeStandard;
    
    
    [self.view addSubview:_mapView];
    //    [self addAnnotation];
    
    UIButton *sureButton = [[UIButton alloc]initWithFrame:CGRectMake(MainWidth / 2 - 75, MainHeight - 200, 150, 40)];
    sureButton.backgroundColor = [UIColor orangeColor];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    sureButton.layer.cornerRadius = 20;
    [_mapView addSubview:sureButton];
    
    
}

- (void)sureClick{
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.10.202/combestwp/combest_mopcontroller.nsf/CBXsp_saveDocSign.xsp?form=CBFrm_signInManage&db=combestwp/combest_wpportal.nsf"]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSString *args = [NSString stringWithFormat:@"longitude=%f&latitude=%f&address=%@&addressDetail=%@",coordinate.longitude,coordinate.latitude,[title2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[title1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"从服务器获取到数据");
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:returnData options:(NSJSONReadingMutableLeaves) error:nil];
        
        
        if ([dict[@"msg"] isEqualToString:@"true"]) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [self.navigationController popViewControllerAnimated:YES];
                [SVProgressHUD showSuccessWithStatus:@"签到成功！"];
                [SVProgressHUD
                 setBackgroundColor:[UIColor
                                     colorWithRed:206.0/255 green:206.0/255 blue:201.0/255 alpha:1]];
                [SVProgressHUD dismissWithDelay:2.0];
                
                
            });
            
            
            
            
        }
        /*
         对从服务器获取到的数据data进行相应的处理.
         */
    
        NSLog(@"%@",dict);
    }];
    //5.最后一步，执行任务，(resume也是继续执行)。
    [sessionDataTask resume];
    
    
    
}

#pragma mark 添加大头针
//-(void)addAnnotationWith:(NSString *) title22 withName:(NSString *)name{
//    
//    
//    
//    CLLocationCoordinate2D location1=[KNLocationConverter transformFromWGSToGCJ:coordinate];
//    annotation1=[[KCAnnotation alloc]init];
//    annotation1.title= [NSString stringWithFormat:@"在%@附近",name];
//    annotation1.subtitle= title22;
//    annotation1.coordinate=location1;
//    
//    [_mapView addAnnotation:annotation1];
//    [_mapView selectAnnotation:annotation1 animated:YES];
//    
//    
//    
//}

#pragma mark CoreLocation 代理

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    
    CLLocation *location = [locations lastObject];
    coordinate = location.coordinate;
    NSLog(@"--- %lf,%lf",coordinate.latitude,coordinate.longitude);
    
    
    CLGeocoder *genCoder = [[CLGeocoder alloc]init];
    [genCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        for (CLPlacemark *place in placemarks) {
            
            NSDictionary *location = [place addressDictionary];
            NSLog(@"name - %@",place.name);
            
            NSArray *ti = location[@"FormattedAddressLines"];
            NSString *title = ti[0];
            title1 = title;
            title2 = place.name;
            
//            [self addAnnotationWith:title withName:place.name];
            
        }
        
        
    }];
    
    
    
    [_locationManager stopUpdatingLocation];
    
}

#pragma mark mapView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
   
    
    
    return nil;
    
}




@end

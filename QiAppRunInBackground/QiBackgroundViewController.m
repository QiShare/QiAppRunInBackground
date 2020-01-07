//
//  QiBackgroundViewController.m
//  QiAppRunInBackground
//
//  Created by wangyongwang on 2019/12/28.
//  Copyright © 2019 WYW. All rights reserved.
//

#import "QiBackgroundViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface QiBackgroundViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation QiBackgroundViewController

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTimer];
    [self setupUI];
}

- (void)setupUI {
    
    self.title = @"定位持续运行";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initLocation];
}

- (void)initLocation {
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    // [self.locationManager requestWhenInUseAuthorization];
    @try {
        // 后台定位依然可用
       self.locationManager.allowsBackgroundLocationUpdates = YES;
    } @catch (NSException *exception) {
        NSLog(@"异常：%@", exception);
    } @finally {
        
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    NSLog(@"%s：位置信息：%@", __FUNCTION__, locations);
}

#pragma mark - 定时器
- (void)setupTimer {
    
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerEvent:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

- (void)timerEvent:(id)sender {
    
    NSLog(@"定时器运行中");
}

- (void)readMe {
    
    /**
     * 参考学习网址：
     * App 接入 iOS 11 的 Files App：https://www.jianshu.com/p/61b4e26ab413
     * iOS 后台挂起的一些坑：https://www.cnblogs.com/saytome/p/7080056.html
     * iOS如何实时查看App运行日志：http://www.cocoachina.com/articles/19933
     * iOS 版微信推送即时消息是如何实现的：https://www.zhihu.com/question/20654687
     * iPhone在一个小时内，接受推送的次数有限制吗：https://community.jiguang.cn/t/iphone/2511
     * 为什么 iOS 的微信没有常驻后台，也能收到新消息通知：https://mlog.club/article/45386
     * iOS后台运行的相关方案总结：https://ctinusdev.github.io/2016/05/10/BackgroundTask/
     * iOS之原生地图的使用详解：https://blog.csdn.net/u011146511/article/details/51245469
     * iOS项目技术还债之路《一》后台下载趟坑：https://juejin.im/post/5cf7eb0351882576710e5c15
     */
}

@end

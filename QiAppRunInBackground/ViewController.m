//
//  ViewController.m
//  QiAppRunInBackground
//
//  Created by wangyongwang on 2019/12/28.
//  Copyright © 2019 WYW. All rights reserved.
//

#import "ViewController.h"
#import "QiBackgroundViewController.h"
#import "QiPlayVideoViewController.h"
#import "QiDownloadViewController.h"
#import "QiTimerViewController.h"
#import "QiAudioPlayer.h"

NSString *const AppViewControllerRefreshNotificationName = @"AppViewControllerRefreshNotificationName";

@interface ViewController ()

@property (nonatomic, strong) UIColor *buttonBackgroundColor;
@property (nonatomic, strong) NSMutableArray<UIButton *> *mButtonArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initAudioSession];
    [self addNotification];
    [self setupUI];
}

#pragma mark - UI
- (void)setupUI {
    
    self.title = @"首页";
    [self setupButtons];
}

#pragma mark - 按钮
- (void)setupButtons {
    
    CGFloat topMargin = 200.0;
    CGFloat leftMargin = 20.0;
    CGFloat verticalMargin = 30.0;
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width - leftMargin * 2;
    CGFloat btnH = 44.0;
    UIColor *btnColor = [UIColor grayColor];
    _buttonBackgroundColor = btnColor;
    _mButtonArray = [NSMutableArray array];
    
    UIButton *locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, topMargin, btnW, btnH)];
    [locationBtn setTitle:@"地图" forState:UIControlStateNormal];
    locationBtn.backgroundColor = btnColor;
    [self.view addSubview:locationBtn];
    [locationBtn addTarget:self action:@selector(locationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_mButtonArray addObject:locationBtn];
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(locationBtn.frame) + verticalMargin, btnW, btnH)];
    [playBtn setTitle:@"播放音乐" forState:UIControlStateNormal];
    playBtn.backgroundColor = btnColor;
    [self.view addSubview:playBtn];
    [playBtn addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_mButtonArray addObject:playBtn];
    
    UIButton *needRunInBgBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(playBtn.frame) + verticalMargin, btnW, btnH)];
    [needRunInBgBtn setTitle:@"需要后台运行" forState:UIControlStateNormal];
    needRunInBgBtn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:needRunInBgBtn];
    [needRunInBgBtn addTarget:self action:@selector(needRunInBackgroundButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(needRunInBgBtn.frame) + verticalMargin, btnW, btnH)];
    [downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    downloadBtn.backgroundColor = btnColor;
    [self.view addSubview:downloadBtn];
    [downloadBtn addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_mButtonArray addObject:downloadBtn];
    
    UIButton *timerBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(downloadBtn.frame) + verticalMargin, btnW, btnH)];
    [timerBtn setTitle:@"定时器" forState:UIControlStateNormal];
    timerBtn.backgroundColor = btnColor;
    [self.view addSubview:timerBtn];
    [timerBtn addTarget:self action:@selector(timerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_mButtonArray addObject:timerBtn];
}

#pragma mark - 地图视图
- (void)locationButtonClicked:(UIButton *)sender {
    
    NSURL *url = [NSURL URLWithString:@"https://www.so.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"错误信息：%@", error);
        } else {
            NSLog(@"数据长度：%lu", (unsigned long)data.length);
        }
    }];
    
    [dataTask resume];
    return;
    
    QiBackgroundViewController *backgroundVC = [QiBackgroundViewController new];
    [self.navigationController pushViewController:backgroundVC animated:YES];
}

#pragma mark - 播放音乐
- (void)playButtonClicked:(UIButton *)sender {
    
    QiPlayVideoViewController *playVieoVC = [QiPlayVideoViewController new];
    [self.navigationController pushViewController:playVieoVC animated:YES];
}

#pragma mark - 需要后台运行
- (void)needRunInBackgroundButtonClicked:(UIButton *)sender {
    
    [QiAudioPlayer sharedInstance].needRunInBackground = YES;
}

#pragma mark - 下载
- (void)downloadButtonClicked:(UIButton *)sender {
    
    QiDownloadViewController *downloadVC = [QiDownloadViewController new];
    [self.navigationController pushViewController:downloadVC animated:YES];
}

#pragma mark - 定时器
- (void)timerButtonClicked:(UIButton *)sender {
    
    QiTimerViewController *timerVC = [QiTimerViewController new];
    [self.navigationController pushViewController:timerVC animated:YES];
}

- (void)initAudioSession {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark - 添加通知
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appRefreshNoti:) name:AppViewControllerRefreshNotificationName object:nil];
}

- (void)appRefreshNoti:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *btnColor = [UIColor colorWithRed:(arc4random() % 256 / 255.0) green:(arc4random() % 256 / 255.0) blue:(arc4random() % 256 / 255.0) alpha:1.0];
        [self.mButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = btnColor;
        }];
    });
}

#pragma mark - 移除通知
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppViewControllerRefreshNotificationName object:nil];
}


@end

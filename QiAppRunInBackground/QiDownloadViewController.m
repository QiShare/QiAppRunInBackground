//
//  QiDownloadViewController.m
//  QiAppRunInBackground
//
//  Created by wangyongwang on 2019/12/30.
//  Copyright © 2019 WYW. All rights reserved.
//

#import "QiDownloadViewController.h"

@interface QiDownloadViewController () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation QiDownloadViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.session invalidateAndCancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDownloadTask];
    // [self setupTimer];
    [self setupUI];
}

- (void)initDownloadTask {
    NSURLSessionConfiguration *sessionConfig;
    @try {
        sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.qishare.ios.wyw.backgroundDownloadTask"];
    } @catch (NSException *exception) {
        NSLog(@"异常信息：%@", exception);
    } @finally {
        
    }
    
    // sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURL *url = [NSURL URLWithString:@"https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg"];
    // 资源下载完后 可以得到通知 AppDelegate.m 文件中的 - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
    sessionConfig.sessionSendsLaunchEvents = YES;
    // 当传输大数据量数据的时候，建议将此属性设置为YES，这样系统可以安排对设备而言最佳的传输时间
    sessionConfig.discretionary = YES;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    self.session = session;
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
    
    /*
     NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
     NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         if (error) {
             NSLog(@"错误信息：%@", error);
         } else {
             NSLog(@"response：%lld", response.expectedContentLength);
             dispatch_async(dispatch_get_main_queue(), ^{

                 // self.backgroundImageView.image = [UIImage imageWithData:response];
             });
         }
     }];
     [downloadTask resume];
     
     */
}

- (void)setupUI {
    
    self.title = @"下载任务";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:bgImageView];
    bgImageView.backgroundColor = [UIColor grayColor];
    self.backgroundImageView = bgImageView;
    
    // [self setupButtons];
}

- (void)setupButtons {
    
    CGFloat topMargin = 200.0;
    CGFloat leftMargin = 20.0;
    CGFloat verticalMargin = 30.0;
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width - leftMargin * 2;
    CGFloat btnH = 44.0;
    UIColor *btnColor = [UIColor grayColor];
    
    UIButton *downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, topMargin, btnW, btnH)];
    [downloadBtn setTitle:@"开始下载" forState:UIControlStateNormal];
    downloadBtn.backgroundColor = btnColor;
    [self.view addSubview:downloadBtn];
    [downloadBtn addTarget:self action:@selector(startDownloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(downloadBtn.frame) + verticalMargin, btnW, btnH)];
    [pauseBtn setTitle:@"暂停下载" forState:UIControlStateNormal];
    pauseBtn.backgroundColor = btnColor;
    [self.view addSubview:pauseBtn];
    [pauseBtn addTarget:self action:@selector(pauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 播放音乐
- (void)startDownloadButtonClicked:(UIButton *)sender {
    
    [self initDownloadTask];
}

#pragma mark - 暂停播放
- (void)pauseButtonClicked:(UIButton *)sender {
    
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

#pragma mark - Delegates
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSLog(@"下载结束%@", location.path);
    [self.session invalidateAndCancel];
    NSError *error = nil;
    NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:documentPath error:nil];
    } 
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:documentPath error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *data = [[NSData alloc] initWithContentsOfFile:documentPath];
        self.backgroundImageView.image = [UIImage imageWithData:data];
    });
    if (error) {
        NSLog(@"错误信息:%@", error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSLog(@"下载进度%f", totalBytesWritten * 1.0 / totalBytesExpectedToWrite);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    NSLog(@"部分进度%f", fileOffset * 1.0 / expectedTotalBytes);
}

@end

//
//  QiPlayVideoViewController.m
//  QiAppRunInBackground
//
//  Created by wangyongwang on 2019/12/30.
//  Copyright © 2019 WYW. All rights reserved.
//

#import "QiPlayVideoViewController.h"
#import "QiAudioPlayer.h"

@interface QiPlayVideoViewController () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation QiPlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [self initAudioPlayer];
    [self setupUI];
    [self setupTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_timer invalidate];
    _timer = nil;
}

- (void)setupUI {
    
    self.title = @"播放音乐";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupButtons];
}

- (void)setupButtons {
    
    CGFloat topMargin = 200.0;
    CGFloat leftMargin = 20.0;
    CGFloat verticalMargin = 30.0;
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width - leftMargin * 2;
    CGFloat btnH = 44.0;
    UIColor *btnColor = [UIColor grayColor];
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, topMargin, btnW, btnH)];
    [playBtn setTitle:@"开始播放" forState:UIControlStateNormal];
    playBtn.backgroundColor = btnColor;
    [self.view addSubview:playBtn];
    [playBtn addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(playBtn.frame) + verticalMargin, btnW, btnH)];
    [pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    pauseBtn.backgroundColor = btnColor;
    [self.view addSubview:pauseBtn];
    [pauseBtn addTarget:self action:@selector(pauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initAudioPlayer {
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"SomethingJustLikeThis" withExtension:@"mp3"];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    audioPlayer.numberOfLoops = NSUIntegerMax;
    audioPlayer.delegate = self;
    [audioPlayer prepareToPlay];
    _audioPlayer = audioPlayer;
}

#pragma mark - 播放音乐
- (void)playButtonClicked:(UIButton *)sender {
    
    // [_audioPlayer play];
    [[QiAudioPlayer sharedInstance].player play];
}

#pragma mark - 暂停播放
- (void)pauseButtonClicked:(UIButton *)sender {
    
    // [self.audioPlayer pause];
    [[QiAudioPlayer sharedInstance].player pause];
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


@end

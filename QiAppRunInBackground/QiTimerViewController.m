//
//  QiTimerViewController.m
//  QiAppRunInBackground
//
//  Created by wangyongwang on 2019/12/31.
//  Copyright © 2019 WYW. All rights reserved.
//

#import "QiTimerViewController.h"

@interface QiTimerViewController ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation QiTimerViewController

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
    
    self.title = @"普通定时器";
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - 定时器
- (void)setupTimer {
    
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerEvent:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

- (void)timerEvent:(id)sender {
    
    NSLog(@"普通定时器运行中");
}

@end

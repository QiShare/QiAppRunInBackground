//
//  AppDelegate.m
//  QiAppRunInBackground
//
//  Created by wangyongwang on 2019/12/28.
//  Copyright © 2019 WYW. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "QiAudioPlayer.h"

@interface AppDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

static NSString *const kBgTaskName = @"com.qishare.ios.wyw.QiAppRunInBackground";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (@available(iOS 13.0, *)) {
        
    } else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

#pragma mark - MARK: - 需要后台下载的情况需要实现如下方法
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    
    NSLog(@"标识：%@ 后台任务下载完成", identifier);
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"%s： 创建新的场景会话", __FUNCTION__);
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
   
    NSLog(@"%s：已丢弃一个场景会话didDiscardSceneSessions", __FUNCTION__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    NSLog(@"%s：应用将进入前台WillEnterForeground", __FUNCTION__);
    if ([QiAudioPlayer sharedInstance].needRunInBackground) {
        [[QiAudioPlayer sharedInstance].player pause];
    }
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTaskIdentifier];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"%s：已进入活跃状态DidBecomeActive", __FUNCTION__);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSLog(@"%s：将进入非活跃状态WillResignActive", __FUNCTION__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    NSLog(@"%s：应用进入后台DidEnterBackground", __FUNCTION__);
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:kBgTaskName expirationHandler:^{

       if ([QiAudioPlayer sharedInstance].needRunInBackground) {
           [[QiAudioPlayer sharedInstance].player play];
       }
       if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
           [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
           self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
       }
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSLog(@"%s：应用终止：WillTerminate", __FUNCTION__);
}

@end

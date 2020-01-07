#import "SceneDelegate.h"
#import "ViewController.h"
#import "QiAudioPlayer.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import <PushKit/PushKit.h>

@interface SceneDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

static NSString *const kBgTaskName = @"com.qishare.ios.wyw.QiAppRunInBackground";
static NSString *const kRefreshTaskId = @"com.qishare.ios.wyw.background.refresh";
static NSString *const kCleanTaskId = @"com.qishare.ios.wyw.background.db_cleaning";

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)){
    
    UIWindowScene *windowScene = [[UIWindowScene alloc] initWithSession:session connectionOptions:connectionOptions];
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    [self.window makeKeyAndVisible];
    NSLog(@"%s： 场景将要连接会话willConnectToSession", __FUNCTION__);
    
    [self registerBgTask];
}

- (void)registerBgTask {
    
    if (@available(iOS 13.0, *)) {
        BOOL registerFlag = [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:kRefreshTaskId usingQueue:nil launchHandler:^(__kindof BGTask * _Nonnull task) {
            [self handleAppRefresh:task];
        }];
        if (registerFlag) {
            NSLog(@"注册成功");
        } else {
            NSLog(@"注册失败");
        }
    } else {
        // Fallback on earlier versions
    }
    
    if (@available(iOS 13.0, *)) {
        [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:kCleanTaskId usingQueue:nil launchHandler:^(__kindof BGTask * _Nonnull task) {
            [self handleAppRefresh:task];
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)handleAppRefresh:(BGAppRefreshTask *)appRefreshTask  API_AVAILABLE(ios(13.0)){
    
    [self scheduleAppRefresh];
    
    NSLog(@"App刷新====================================================================");
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AppViewControllerRefreshNotificationName object:nil];
        
        NSLog(@"操作");
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *timeString = [dateFormatter stringFromDate:date];
        
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"QiLog.txt"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData *data = [timeString dataUsingEncoding:NSUTF8StringEncoding];
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
        } else {
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            NSString *originalContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *content = [originalContent stringByAppendingString:[NSString stringWithFormat:@"\n时间：%@\n", timeString]];
            data = [content dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:filePath atomically:YES];
        }
    }];
    
    appRefreshTask.expirationHandler = ^{
        [queue cancelAllOperations];
    };
    [queue addOperation:operation];
    
    __weak NSBlockOperation *weakOperation = operation;
    operation.completionBlock = ^{
        [appRefreshTask setTaskCompletedWithSuccess:!weakOperation.isCancelled];
    };
}

- (void)scheduleAppRefresh {
    
    if (@available(iOS 13.0, *)) {
        BGAppRefreshTaskRequest *request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:kRefreshTaskId];
        // 最早15分钟后启动后台任务请求
        request.earliestBeginDate = [NSDate dateWithTimeIntervalSinceNow:15.0 * 60];
        NSError *error = nil;
        [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
        if (error) {
            NSLog(@"错误信息：%@", error);
        }
        
    } else {
        // Fallback on earlier versions
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"%s：场景已断开Unattach", __FUNCTION__);
}

- (void)sceneDidBecomeActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
   
    NSLog(@"%s：不活跃到活跃Inactive -> Active", __FUNCTION__);
}

- (void)sceneWillResignActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"%s：活跃到不活跃Active -> Inactive", __FUNCTION__);
}

- (void)sceneWillEnterForeground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){

    if ([QiAudioPlayer sharedInstance].needRunInBackground) {
        [[QiAudioPlayer sharedInstance].player pause];
    }
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTaskIdentifier];
    
    NSLog(@"%s：应用将进入前台WillEnterForeground", __FUNCTION__);
}

- (void)sceneDidEnterBackground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){

    [self scheduleAppRefresh];
    // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier: @"com.qishare.ios.wyw.background.refresh"]
    NSLog(@"%s：应用已进入后台DidEnterBackground", __FUNCTION__);

    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:kBgTaskName expirationHandler:^{
        if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            if ([QiAudioPlayer sharedInstance].needRunInBackground) {
                [[QiAudioPlayer sharedInstance].player play];
            }
            NSLog(@"终止后台任务");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
}

@end

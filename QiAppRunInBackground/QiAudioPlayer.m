//
//  QiAudioPlayer.m
//  QiAppRunInBackground
//
//  Created by wangyongwang on 2019/12/30.
//  Copyright © 2019 WYW. All rights reserved.
//

#import "QiAudioPlayer.h"

static QiAudioPlayer *instance = nil;

@interface QiAudioPlayer ()

@end

@implementation QiAudioPlayer

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QiAudioPlayer alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    [self initPlayer];
    return self;
}

- (void)initPlayer {
    
    [self.player prepareToPlay];
}

- (AVAudioPlayer *)player {
    
    if (!_player) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"SomethingJustLikeThis" withExtension:@"mp3"];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        audioPlayer.numberOfLoops = NSUIntegerMax;
        _player = audioPlayer;
    }
    return _player;
}


@end

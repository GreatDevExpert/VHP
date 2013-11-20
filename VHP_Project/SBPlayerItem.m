//
//  SBPlayerItem.m
//  SongBooth
//
//  Created by Eric Yang on 10/11/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "SBPlayerItem.h"
#import "SBAudioManager.h"

@implementation SBPlayerItem {
    NSURL *_url;
}

@synthesize delegate;
@synthesize avPlayerItem = _avPlayerItem;
@synthesize progress;

+ (SBPlayerItem *)playerItemWithURL:(NSURL *)URL {
    return [[SBPlayerItem alloc] initWithURL:URL];
}

- (id)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        _url = URL;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(releaseAVPlayerItem)
                                                     name:@"AVPlayerWillDealloc"
                                                   object:[SBAudioManager sharedInstance]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setForwardPlaybackEndTime:(CMTime)time
{
    _avPlayerItem.forwardPlaybackEndTime = time;
}


#pragma mark - Interface

- (void)seekToTime:(CMTime)time {
    if (!_avPlayerItem) {
        return;
    }
    [_avPlayerItem seekToTime:time];
}


#pragma mark - Internal

- (void)releaseAVPlayerItem {
    float p = self.progress;
    if (p > 0.0 && p < 1.0) {
        if ([self.delegate respondsToSelector:@selector(playerItemDidStopPlaying:finished:)]) {
            [self.delegate playerItemDidStopPlaying:self finished:NO];
        }
    }
    _avPlayerItem = nil;
}


#pragma mark - Properties

- (float)progress {
    if (!_avPlayerItem) {
        return 0.0;
    }
    float p = CMTimeGetSeconds(_avPlayerItem.currentTime) / CMTimeGetSeconds(_avPlayerItem.duration);
    return MAX(0.0, MIN(1.0, p));
}

- (AVPlayerItem *)avPlayerItem {
    if (!_avPlayerItem) {
        _avPlayerItem = [AVPlayerItem playerItemWithURL:_url];
    }
    return _avPlayerItem;
}

- (float)currentTime
{
    return CMTimeGetSeconds(_avPlayerItem.currentTime);

}

- (float)totalTime
{
    return CMTimeGetSeconds(_avPlayerItem.duration);
}

@end

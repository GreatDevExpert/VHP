//
//  SBAudioManager.m
//  SongBooth
//
//  Created by Eric Yang on 10/11/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "SBAudioManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SBAudioManager.h"
#import "SBRecordingManager.h"


@interface SBAudioManager ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) SBPlayerItem *currentItem;

@end


@implementation SBAudioManager {
    id _timeObserverRef;
    AVAudioSession *_audioSession;
}

@synthesize player = _player;
@synthesize recorder = _recorder;
@synthesize currentItem = _currentItem;

+ (SBAudioManager *)sharedInstance {
    static SBAudioManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SBAudioManager alloc] init];
    });
    return _sharedInstance;
}


- (id)init {
    self = [super init];
    if (self) {
        _audioSession = [AVAudioSession sharedInstance];
        _audioSession.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventForAudioRouteStatusChanged:) name:kAudioRouteDidChangedNotification object:nil];
    }
    return self;
}

- (void)setupDefaultSession {
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setActive:YES error:nil];
    [self addAudioRouteListener];
    [self resetAudioSessionRoute];
    [self resetAudioCategoryForPlayAndRecord:NO];
    
}

- (void)seekToTime:(CMTime)time
{
    [self.player seekToTime:time];
}


#pragma mark route methods

#define kActiveAudioRouteDidChange_NewDetailedRoute @"ActiveAudioRouteDidChange_NewDetailedRoute"
#define kRouteDetailedDescription_Inputs @"RouteDetailedDescription_Inputs"
#define kRouteDetailedDescription_PortType @"RouteDetailedDescription_PortType"
#define kRouteDetailedDescription_Outputs @"RouteDetailedDescription_Outputs"

#define vMicrophoneWired @"MicrophoneWired"
#define vMicrophoneBuiltIn @"MicrophoneBuiltIn"
#define vHeadphones @"Headphones"
#define vReceiver @"Receiver"

static NSString *_currentInputPortType = nil;
static NSString *_currentOutputPortType = nil;

void audioRouteChangeListenerCallback (
                                       void                   *inUserData,
                                       AudioSessionPropertyID inPropertyID,
                                       UInt32                 inPropertyValueSize,
                                       const void             *inPropertyValue
                                       )
{
    NSDictionary *dict = (__bridge NSDictionary *)inPropertyValue;
    //NSLog(@"audioRouteChange %@", [dict description]);
    if (![dict objectForKey:kActiveAudioRouteDidChange_NewDetailedRoute]) {
        return;
    }
    NSDictionary *subDict = [dict objectForKey:kActiveAudioRouteDidChange_NewDetailedRoute];
    if ([subDict objectForKey:kRouteDetailedDescription_Inputs]) {
        NSArray *inputs = [subDict objectForKey:kRouteDetailedDescription_Inputs];
        if (!inputs.count) {
            return;
        }
        NSDictionary *aInput = [inputs objectAtIndex:0];
        _currentInputPortType = [aInput objectForKey:kRouteDetailedDescription_PortType];
    }
    if ([subDict objectForKey:kRouteDetailedDescription_Outputs]) {
        NSArray *outputs = [subDict objectForKey:kRouteDetailedDescription_Outputs];
        if (!outputs.count) {
            return;
        }
        NSDictionary *aOutput = [outputs objectAtIndex:0];
        _currentOutputPortType = [aOutput objectForKey:kRouteDetailedDescription_PortType];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAudioRouteDidChangedNotification object:nil];
}

- (void)addAudioRouteListener
{
    AudioSessionPropertyID routeChangeID =  kAudioSessionProperty_AudioRouteChange;
    AudioSessionAddPropertyListener(routeChangeID, audioRouteChangeListenerCallback, nil);
}

- (BOOL)isMicrophonePluggedIn
{
    return [_currentInputPortType isEqualToString:vMicrophoneWired];
}

- (void)resetAudioSessionRoute
{
    UInt32 audioRoute = [self isMicrophonePluggedIn] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
}

- (void)resetAudioCategoryForPlayAndRecord:(BOOL)playAndRecord
{
    
    NSString * category = playAndRecord ? AVAudioSessionCategoryPlayAndRecord : AVAudioSessionCategoryPlayback;
    if (![_audioSession.category isEqualToString:category]) {
        [_audioSession setCategory:category error:nil];
        
    }
}

#pragma mark - Interface: Playback

- (void)preparePlayerForItem:(SBPlayerItem *)playerItem
{
    
    AVPlayer *player = self.player;
    [self resetAudioCategoryForPlayAndRecord:YES];
    self.currentItem = playerItem;
    [player replaceCurrentItemWithPlayerItem:playerItem.avPlayerItem];
}

- (void)playItem:(SBPlayerItem *)playerItem {
    AVPlayer *player = self.player;
    
    // Is this item already loaded into the player?
    if (_currentItem == playerItem) {
        if (player.rate > 0.0) {
            // Already playing
            return;
        } else {
            // Paused, can start immediately
            [self playerItemDidStartPlaying:_currentItem];
            [player play];
            return;
        }
    }
    [self preparePlayerForItem:playerItem];
    [self playItem:playerItem];
}

- (void)pauseItem:(SBPlayerItem *)playerItem {
    if (_player && _currentItem == playerItem && _player.rate > 0.0) {
        [_player pause];
        [self playerItemDidPausePlaying:playerItem];
    }
}

- (void)stopItem:(SBPlayerItem *)playerItem
{
    if (_player && _currentItem == playerItem && _player.rate > 0.0) {
        [_player pause];
        [_player seekToTime:CMTimeMake(0, 1)];
        [self playerItemDidStopPlaying:playerItem];
    }
}

- (void)removeItem:(SBPlayerItem *)playerItem {
    if (_player && _currentItem == playerItem) {
        self.player = nil;
    }
}

- (BOOL)isPlaying
{
    return _player.rate > 0.0f;
}


#pragma mark - Interface: Recording

- (BOOL)isRecording
{
    return _recorder.isRecording;
}

- (NSDictionary *)recordingSettings
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithCapacity:6];
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
	[settings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
	[settings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
	[settings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	[settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
	[settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
//    [settings setObject:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
//    [settings setObject:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
//    [settings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
//    [settings setObject:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    return settings;
}

- (void)prepareRecordForItem:(NSString *)itemKey inDelegate:(NSObject<SBAudioRecorderDelegate> *)delegate
{
    if (_recorder) {
        if ([_recorder.url isEqual:[SBRecordingManager audioRecordingUrlForItem:itemKey]]) {
            [delegate audioRecorderDidPrepare:_recorder];
            return;
        }
        if (_recorder.isRecording) {
            [_recorder stop];
        }
        _recorder = nil;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Create a new recorder
        NSError *error;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:[SBRecordingManager audioRecordingUrlForItem:itemKey] settings:[self recordingSettings] error:&error];
        if (error) {
            NSLog(@"[MMAudioManager] Error creating recorder: %@", error);
            [delegate performSelectorOnMainThread:@selector(audioRecorderDidPrepare:)
                                       withObject:nil
                                    waitUntilDone:NO];
            return;
        }
        
        // Prepare
        if ([_recorder prepareToRecord]) {
            [delegate performSelectorOnMainThread:@selector(audioRecorderDidPrepare:)
                                       withObject:_recorder
                                    waitUntilDone:NO];
        } else {
            NSLog(@"Recorder failed to prepare");
            [delegate performSelectorOnMainThread:@selector(audioRecorderDidPrepare:)
                                       withObject:nil
                                    waitUntilDone:NO];
        }
    });
}

- (void)releaseRecorder:(AVAudioRecorder *)recorder {
    if (_recorder == recorder) {
        self.recorder = nil;
        //        NSLog(@"Released _recorder");
    }
}

- (void)startRecording
{
    if (_recorder) {
        [_recorder record];
    }
}

- (void)pauseRecording
{
    if (_recorder) {
        [_recorder pause];
    }
}

- (void)stopRecording
{
    if (_recorder) {
        [_recorder stop];
    }
}


#pragma mark - Internal

- (void)addObserversForPlayerItem:(SBPlayerItem *)playerItem {
    AVPlayerItem *avPlayerItem = playerItem.avPlayerItem;
    [avPlayerItem addObserver:self
                   forKeyPath:@"status"
                      options:NSKeyValueObservingOptionOld
                      context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidPlayToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:avPlayerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemFailedToPlayToEnd:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:avPlayerItem];
}

- (void)removeObserversForPlayerItem:(SBPlayerItem *)playerItem {
    AVPlayerItem *avPlayerItem = playerItem.avPlayerItem;
    [avPlayerItem removeObserver:self forKeyPath:@"status"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:avPlayerItem];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:avPlayerItem];
}

- (void)playerItemDidStartPlaying:(SBPlayerItem *)playerItem {
    if ([playerItem.delegate respondsToSelector:@selector(playerItemDidStartPlaying:)]) {
        [playerItem.delegate playerItemDidStartPlaying:playerItem];
    }
}

- (void)playerItemDidPausePlaying:(SBPlayerItem *)playerItem {
    if ([playerItem.delegate respondsToSelector:@selector(playerItemDidPausePlaying:)]) {
        [playerItem.delegate playerItemDidPausePlaying:playerItem];
    }
}

- (void)playerItemDidFailToPlay:(SBPlayerItem *)playerItem {
    if ([playerItem.delegate respondsToSelector:@selector(playerItemDidFailToPlay:)]) {
        [playerItem.delegate playerItemDidFailToPlay:playerItem];
    }
}

- (void)playerItemDidStopPlaying:(SBPlayerItem *)playerItem {
    if ([playerItem.delegate respondsToSelector:@selector(playerItemDidStopPlaying:finished:)]) {
        [playerItem.delegate playerItemDidStopPlaying:playerItem finished:YES];
    }
}

#pragma mark - Properties

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        
        void (^timeObserver)(CMTime) = ^(CMTime time) {
            if (_player && _currentItem) {
                if ([_currentItem.delegate respondsToSelector:@selector(playerItem:updatedCurrentTime:)]) {
                    [_currentItem.delegate playerItem:_currentItem updatedCurrentTime:time];
                }
            }
        };
        _timeObserverRef = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30)
                                                                 queue:nil
                                                            usingBlock:timeObserver];
    }
    return _player;
}

- (void)setPlayer:(AVPlayer *)player {
    if (_player) {
        [_player removeTimeObserver:_timeObserverRef];
        _timeObserverRef = nil;
        self.currentItem = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerWillDealloc" object:self];
    }
    _player = player;
}

- (void)setCurrentItem:(SBPlayerItem *)currentItem {
    if (_currentItem) {
        [self removeObserversForPlayerItem:_currentItem];
    }
    _currentItem = currentItem;
    if (_currentItem) {
        [self addObserversForPlayerItem:_currentItem];
    }
}


#pragma mark - Notifications

- (void)itemDidPlayToEnd:(NSNotification *)notification {
    AVPlayerItem *avPlayerItem = (AVPlayerItem *)notification.object;
    if (!_currentItem || _currentItem.avPlayerItem != avPlayerItem) {
        return;
    }
    
    if ([_currentItem.delegate respondsToSelector:@selector(playerItemDidStopPlaying:finished:)]) {
        [_currentItem.delegate playerItemDidStopPlaying:_currentItem finished:YES];
    }
    self.currentItem = nil;
}

- (void)itemFailedToPlayToEnd:(NSNotification *)notification {
    AVPlayerItem *avPlayerItem = (AVPlayerItem *)notification.object;
    if (!_currentItem || _currentItem.avPlayerItem != avPlayerItem) {
        return;
    }
    
    if ([_currentItem.delegate respondsToSelector:@selector(playerItemDidFailToPlay:)]) {
        [_currentItem.delegate playerItemDidFailToPlay:_currentItem];
    }
    self.currentItem = nil;
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // We may have torn down the player at this poing
    if (!_player || !_currentItem) {
        return;
    }
    
    if (object == _currentItem.avPlayerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (_currentItem.avPlayerItem.status == AVPlayerStatusReadyToPlay && _player.rate > 0.0) {
                [self playerItemDidStartPlaying:_currentItem];
            }
        }
    }
}

#pragma mark Notification methods

- (void)eventForAudioRouteStatusChanged:(NSNotification *)notification
{
    NSLog(@"eventForAudioRouteStatusChanged");
    [self resetAudioSessionRoute];
}

@end

//
//  SBAudioManager.h
//  SongBooth
//
//  Created by Eric Yang on 10/11/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBPlayerItem.h"

#define kAudioRouteDidChangedNotification @"AudioRouteDidChangedNotification"

@protocol SBAudioRecorderDelegate;


@interface SBAudioManager : NSObject <AVAudioSessionDelegate>

@property(readwrite, nonatomic) BOOL recordedViaWiredMic;
@property(readwrite, nonatomic) float staredTime;
@property(readwrite, nonatomic) float endedTime;
@property(readwrite, nonatomic) float audioVolume;
@property(readwrite, nonatomic) BOOL videoHasBeenTrimed;
@property(strong, nonatomic) NSString *originSongAwsId;
@property(strong, nonatomic) NSString *originSongParseId;
@property(strong, nonatomic) NSString *originMPMediaItemId;

+ (SBAudioManager *)sharedInstance;

- (void)setupDefaultSession;
- (void)seekToTime:(CMTime)time;

- (void)preparePlayerForItem:(SBPlayerItem *)playerItem;
- (void)playItem:(SBPlayerItem *)playerItem;
- (void)pauseItem:(SBPlayerItem *)playerItem;
- (void)stopItem:(SBPlayerItem *)playerItem;
- (void)removeItem:(SBPlayerItem *)playerItem;
- (BOOL)isPlaying;

- (void)prepareRecordForItem:(NSString *)itemKey inDelegate:(NSObject<SBAudioRecorderDelegate> *)delegate;
- (void)releaseRecorder:(AVAudioRecorder *)recorder;
- (void)startRecording;
- (void)pauseRecording;
- (void)stopRecording;
- (BOOL)isRecording;

#pragma mark audio route & category methods
- (void)addAudioRouteListener;
- (BOOL)isMicrophonePluggedIn;
- (void)resetAudioSessionRoute;
- (void)resetAudioCategoryForPlayAndRecord:(BOOL)playAndRecord;

@end


@protocol SBAudioRecorderDelegate <NSObject>

- (void)audioRecorderDidPrepare:(AVAudioRecorder *)recorder;

@end

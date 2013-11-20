//
//  SBRecordingManager.m
//  SongBooth
//
//  Created by Eric Yang on 10/12/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "SBRecordingManager.h"
#import <AVFoundation/AVFoundation.h>
#import "SBIpodSongMethods.h"
#import "SBEffectMetaDataManager.h"
//#import "SBVideoCapturer.h"
//#import "SBAudioManager.h"
#define CALAYER_OFFSET_FRACTOR 0.563

@implementation SBRecordingManager
{
}

static SBRecordingManager *_manager = nil;
+ (SBRecordingManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[SBRecordingManager alloc] init];
    });
    return _manager;
}


+ (void)mixVideoAndAudioWithDict:(NSDictionary *)itemDict withBlock:(void(^)(NSError *error))block
{
    NSString *itemKey = [itemDict objectForKey:kItemKey];
    BOOL isViaWiredMic = [[itemDict objectForKey:kRecordedViaWiredMic] boolValue];
    __block NSError *error = nil;
    NSURL *ipodSongAssetUrl = nil;
    
    if (isViaWiredMic) {
        if ([itemDict objectForKey:kOriginMPMediaItemId]) {
            ipodSongAssetUrl = [[SBIpodSongMethods instance] assetUrlForItem:[itemDict objectForKey:kOriginMPMediaItemId]];
            if (!ipodSongAssetUrl) {
                NSLog(@"Mix video & audio failed for wired mic recording. song in ipod library is not existing.");
                error = [NSError errorWithDomain:@"www.lognllc.com" code:-1 userInfo:@{@"msg" : @"song in ipod library is not existing"}];
                block(error);
                return;
            }
        }
        else {
            NSString *path = [self cachedSongPathForSongId:[itemDict objectForKey:kOriginSongAwsId]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSLog(@"Mix video & audio failed for wired mic recording. origin file not existing.");
                error = [NSError errorWithDomain:@"www.lognllc.com" code:-1 userInfo:@{@"msg" : @"origin file not existing"}];
                block(error);
                return;
            }
        }
    }
    
    BOOL videoIsTrimed = [[itemDict objectForKey:kVideoHasBeenTrimed] boolValue];
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    NSURL *videoURL;
    BOOL shouldScaleRenderSize = YES;
    
    if ([[SBEffectMetaDataManager sharedManager] isVideoFilterEnabledForSettings:[itemDict objectForKey:kVideoFilterSettings]]) {
        NSString *filterKey = [[SBEffectMetaDataManager sharedManager] videoFilterKeyForSettings:[itemDict objectForKey:kVideoFilterSettings]];
        videoURL = [self filteredVideoUrlForItem:itemKey filterKey:filterKey];
        shouldScaleRenderSize = NO;
    }
    else if (videoIsTrimed) {
        videoURL = [self videoTrimedUrlForItem:itemKey];
    }
    else {
        videoURL = [self videoWaterMarkedForItem:itemKey];
    }
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    if (!videoAsset || ![[videoAsset tracksWithMediaType:AVMediaTypeVideo] count]) {
        error = [NSError errorWithDomain:@"www.lognllc.com" code:-1 userInfo:@{@"msg" : @"video file is not exsiting or invalid video file"}];
        block(error);
        return;
    }
    
    //NSURL *audioURL = [self audioRecordingUrlForItem:itemKey];
    
    //AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[SBRecordingManager videoCapturingUrlForItem:itemKey] options:nil];
    if (!videoAsset || ![[videoAsset tracksWithMediaType:AVMediaTypeAudio] count]) {
        error = [NSError errorWithDomain:@"www.lognllc.com" code:-1 userInfo:@{@"msg" : @"audio file is not exsiting or invalid audio file"}];
        block(error);
        return;
    }

    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    if (shouldScaleRenderSize) {
        videoComposition.renderSize = CGSizeMake(VIDEO_RENDER_WIDTH * CALAYER_OFFSET_FRACTOR, VIDEO_RENDER_HEIGHT * CALAYER_OFFSET_FRACTOR);
    } else {
        videoComposition.renderSize = CGSizeMake(VIDEO_RENDER_WIDTH, VIDEO_RENDER_HEIGHT);
    }
    videoComposition.frameDuration = CMTimeMake(1,24);
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    [layerInstruction setOpacityRampFromStartOpacity:0.0f toEndOpacity:1.0f timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 2))];
    [layerInstruction setOpacityRampFromStartOpacity:1.0f toEndOpacity:0.0f timeRange:CMTimeRangeMake(CMTimeMake(CMTimeGetSeconds(videoAsset.duration) * 2 - 1, 2), videoAsset.duration)];
//    [layerInstruction setTransform:CGAffineTransformMakeTranslation(0.0f, -(VIDEO_CAPTURE_HEIGHT - VIDEO_RENDER_HEIGHT) / 2.0f) atTime:kCMTimeZero];
    
    AVAssetTrack *sourceVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    [compositionVideoTrack insertTimeRange:sourceVideoTrack.timeRange ofTrack:sourceVideoTrack atTime:[mixComposition duration] error:&error];
    
    float startedTime = [[itemDict objectForKey:kStartedTime] floatValue];
    float endedTime = [[itemDict objectForKey:kEndedTime] floatValue];
//    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    CMTimeRange audio_timeRange;
    if (startedTime >= CMTimeGetSeconds(videoAsset.duration)) {
         audio_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    }
    else {
      audio_timeRange = CMTimeRangeMake(CMTimeMake(startedTime, 1), CMTimeMake(MIN(endedTime, CMTimeGetSeconds(videoAsset.duration)) - startedTime, 1));
    }

    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    if ([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count])
    [audioTrack insertTimeRange:audio_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    // add origin audio of played song
    AVMutableAudioMix *audioMix = nil;
    if (isViaWiredMic) {
        NSLog(@"recorded from mic");
        NSURL *originSongURL;
        if (ipodSongAssetUrl) {
            originSongURL = ipodSongAssetUrl;
        }
        else {
            originSongURL = [NSURL fileURLWithPath:[self cachedSongPathForSongId:[itemDict objectForKey:kOriginSongAwsId]]];
        }
        AVURLAsset *originAudioAsset = [AVURLAsset URLAssetWithURL:originSongURL options:nil];
//        float startedTime = [[itemDict objectForKey:kStartedTime] floatValue];
//        float endedTime = [[itemDict objectForKey:kEndedTime] floatValue];
//        CMTimeRange originAudioTimeRange = CMTimeRangeMake(CMTimeMake(startedTime, 1), CMTimeMake(endedTime, 1));
        AVMutableCompositionTrack *originAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        if ([[originAudioAsset tracksWithMediaType:AVMediaTypeAudio] count])
        [originAudioTrack insertTimeRange:audio_timeRange ofTrack:[[originAudioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        // adjust volume
        float volume = [[itemDict objectForKey:kAudioVolume] floatValue];
        NSMutableArray *allAudioParams = [NSMutableArray array];
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[originAudioTrack trackID]];
        [allAudioParams addObject:audioInputParams];        
        audioMix = [AVMutableAudioMix audioMix];
        [audioMix setInputParameters:allAudioParams];
    }
    
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    NSURL *outputURL = [self videoExportingUrlForItem:itemKey];
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil]; // if a file existing already, remove it
    
    AVAssetExportSession* exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset640x480];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = outputURL;
    exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    exportSession.videoComposition = videoComposition;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.fileLengthLimit = 3 * 1024 * 1024 * (CMTimeGetSeconds(videoAsset.duration) / 30.0f);
    if (audioMix) {
        exportSession.audioMix = audioMix;
    }
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
       // NSLog(@"estimatedOutputFileLength %lld", exportSession.estimatedOutputFileLength);
        int exportStatus = exportSession.status;
        if (exportStatus != AVAssetExportSessionStatusCompleted) {
            NSLog(@"AVAsset Export Failed");
            error = [NSError errorWithDomain:@"www.lognllc.com" code:-1 userInfo:@{@"msg" : @"export video file failed"}];
        }
        block(error);
    }];
    
}

+ (void)deleteAllRecordingFiles
{
    [[NSFileManager defaultManager] removeItemAtPath:[self dirPathForRecordingFiles] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[self dirPathForThumbnail] error:nil];
}

+ (void)trimVideoFileWithDict:(NSDictionary *)itemDict withBlock:(void (^)(NSError *))block
{
     NSString *itemKey = [itemDict objectForKey:kItemKey];
    NSURL *videoUrl = [self videoWaterMarkedForItem:itemKey];
 //   NSURL *videoUrl = [SBAppSharedInstance testingLocalMovieUrl];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    NSURL *trimedUrl = [self videoTrimedUrlForItem:itemKey];
    [[NSFileManager defaultManager] removeItemAtURL:trimedUrl error:nil]; // if a file existing already, remove it

    float startedTime = [[itemDict objectForKey:kStartedTime] floatValue];
    float endedTime = [[itemDict objectForKey:kEndedTime] floatValue];
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMake(startedTime, 1), CMTimeMake(endedTime - startedTime, 1));

    AVAssetExportSession* exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.outputURL = trimedUrl;
    exportSession.timeRange = timeRange;
    exportSession.shouldOptimizeForNetworkUse = YES;
    __block NSError *error = nil;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        // NSLog(@"estimatedOutputFileLength %lld", exportSession.estimatedOutputFileLength);
        int exportStatus = exportSession.status;
        if (exportStatus != AVAssetExportSessionStatusCompleted) {
            NSLog(@"AVAsset Export Failed");
            error = [NSError errorWithDomain:@"www.lognllc.com" code:-1 userInfo:@{@"msg" : @"trim from origin video file failed"}];
        }
        block(error);
    }];

}

#pragma mark Common dir methods

+ (NSString *)fileDirectoryPathForSubDirName:(NSString *)subDirName;
{
    // use documents for dev
    // need change to a temp dir for app store
    NSString *path = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(), subDirName];
    //NSString *path = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(), subDirName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)dirPathForRecordingFiles
{
    return [self fileDirectoryPathForSubDirName:@"recording_files"];
}

+ (NSString *)dirPathForCachedSongs
{
    return [self fileDirectoryPathForSubDirName:@"cached_songs"];
}

+ (NSString *)dirPathForThumbnail
{
    return [self fileDirectoryPathForSubDirName:@"thumb_files"];
}

#pragma mark Recording file urls

+ (NSURL *)originAudioSavingUrlForItem:(NSString *)itemKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_origin_audio.wav", [self dirPathForRecordingFiles], itemKey]];
    else return [[NSURL alloc]initWithString:itemKey];
}

+ (NSURL *)audioRecordingUrlForItem:(NSString *)itemKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_recorded_audio.wav", [self dirPathForRecordingFiles], itemKey]];
        else return [[NSURL alloc]initWithString:itemKey];
}

+ (NSURL *)videoCapturingUrlForItem:(NSString *)itemKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_captured_video.mov", [self dirPathForRecordingFiles], itemKey]];
        else return [[NSURL alloc]initWithString:itemKey];
}

+ (NSURL *)videoTrimedUrlForItem:(NSString *)itemKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_captured_trimed.mov", [self dirPathForRecordingFiles], itemKey]];
        else return [[NSURL alloc]initWithString:itemKey];
}

+ (NSURL *)videoExportingUrlForItem:(NSString *)itemKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_exported_video.mp4", [self dirPathForRecordingFiles], itemKey]];
        else return [[NSURL alloc]initWithString:itemKey];
}

+ (NSURL *)videoWaterMarkedForItem:(NSString *)itemKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_watermarked_video.mov", [self dirPathForRecordingFiles], itemKey]];
        else return [[NSURL alloc]initWithString:itemKey];
}

+ (NSURL *)filteredVideoUrlForItem:(NSString *)itemKey filterKey:(NSString *)filterKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_filtered_%@_video.mov", [self dirPathForRecordingFiles], itemKey, filterKey]];
        else return [[NSURL alloc]initWithString:itemKey];
}

#pragma mark Caching file paths
+ (NSString *)cachedSongPathForSongId:(NSString *)songAwsId
{

    return [NSString stringWithFormat:@"%@/%@", [self dirPathForCachedSongs], songAwsId];
}

#pragma mark temp saving file path
+ (NSString *)tempThumbnailSavingPathForItem:(NSString *)itemKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
    return [NSString stringWithFormat:@"%@/%@_thumbnail.png", [self dirPathForThumbnail], itemKey];
        else return [[NSURL alloc]initWithString:itemKey];
}


@end

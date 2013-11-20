//
//  SBRecordingManager.h
//  SongBooth
//
//  Created by Eric Yang on 10/12/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kSavedUploadingData @"savedUploadingData"
#define kItemKey @"itemKey"
#define kThumbnailAwsId @"thumbnailAwsId"
#define kVideoAwsId @"videoAwsId"
#define kOriginSongAwsId @"originSongAwsId"
#define kOriginSongParseId @"originSongParseId"
#define kOriginMPMediaItemId @"originMPMediaItemId"
#define kTitle @"title"
#define kDescription @"description"
#define kLocationName @"locationName"
#define kLatitude @"latitude"
#define kLongitude @"longitude"
#define kFinished @"finished"
#define kRecordedViaWiredMic @"viaWiredMic"
#define kStartedTime @"startedTime"
#define kEndedTime @"endedTime"
#define kVideoFilterSettings @"videoFilterSettings"
#define kVideoHasBeenTrimed @"videoIsTrimed"
#define kAudioVolume @"audioVolume"


#define VIDEO_CAPTURE_WIDTH 640.0f
#define VIDEO_CAPTURE_HEIGHT 640.0f//VIDEO_CAPTURE_WIDTH * (4.0f / 3.0f)
#define VIDEO_RENDER_WIDTH 640.0f
#define VIDEO_RENDER_HEIGHT 640.0f//VIDEO_RENDER_WIDTH * (4.0f / 3.0f)

@interface SBRecordingManager : NSObject

#pragma Class methods

+ (void)mixVideoAndAudioWithDict:(NSDictionary *)itemDict withBlock:(void(^)(NSError *error))block;

+ (void)deleteAllRecordingFiles;

+ (void)trimVideoFileWithDict:(NSDictionary *)itemDict withBlock:(void (^) (NSError *error))block;

#pragma mark Recording file urls
+ (NSURL *)originAudioSavingUrlForItem:(NSString *)itemKey;
+ (NSURL *)audioRecordingUrlForItem:(NSString *)itemKey;
+ (NSURL *)videoCapturingUrlForItem:(NSString *)itemKey;
+ (NSURL *)videoTrimedUrlForItem:(NSString *)itemKey;
+ (NSURL *)videoExportingUrlForItem:(NSString *)itemKey;
+ (NSURL *)videoWaterMarkedForItem:(NSString *)itemKey;
+ (NSURL *)filteredVideoUrlForItem:(NSString *)itemKey filterKey:(NSString *)filterKey;

#pragma mark Caching file path
+ (NSString *)cachedSongPathForSongId:(NSString *)songAwsId;

#pragma mark temp saving file path
+ (NSString *)tempThumbnailSavingPathForItem:(NSString *)itemKey;

@end

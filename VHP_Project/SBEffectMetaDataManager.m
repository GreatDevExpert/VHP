//
//  SBEffectMetaDataManager.m
//  SongBooth
//
//  Created by Eric Yang on 11/22/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "SBEffectMetaDataManager.h"
#import "GPUImage.h"
#import "SBVintageVideoFilter.h"

#define SB_EFFECT_VIDEO_META_DATA_FILE @"videoEffects.plist"
#define SB_EFFECT_VIDEO_DIR_KEY @"dirName"
#define SB_EFFECT_VIDEO_NAME_KEY @"name"

@implementation SBEffectMetaDataManager
{
    NSArray *_allMetaDataForVideoFilters;
}

static SBEffectMetaDataManager *_manager = nil;

+ (SBEffectMetaDataManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[SBEffectMetaDataManager alloc] init];
    });
    return _manager;
}


- (id)init
{
    if (self = [super init]) {
        _allMetaDataForVideoFilters = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SB_EFFECT_VIDEO_META_DATA_FILE ofType:nil]];
    }
    return self;
}

- (NSString *)previewImagePathForVideoEffectData:(NSDictionary *)videoEffectData
{
    return [[NSBundle mainBundle] pathForResource:@"thumb.png" ofType:nil inDirectory:[NSString stringWithFormat:@"videoEffects/%@", [videoEffectData objectForKey:SB_EFFECT_VIDEO_DIR_KEY]]];

}

- (NSString *)videoEffectNameForEffectMetaData:(NSDictionary *)videoEffectMetaData
{
    return [videoEffectMetaData objectForKey:SB_EFFECT_VIDEO_NAME_KEY];
}

- (NSString *)videoFilterKeyForSettings:(NSDictionary *)settings
{
    return [settings objectForKey:@"key"];
}

- (id)videoFilterForKey:(NSString *)filterKey
{
    if ([filterKey isEqualToString:@"soho"]) {
        return [[GPUImageAmatorkaFilter alloc] init];
    }
    else if ([filterKey isEqualToString:@"vintage"]) {
        return [[SBVintageVideoFilter alloc] init];
    }
    else if ([filterKey isEqualToString:@"bw"]) {
        return [[GPUImageGrayscaleFilter alloc] init];
    }
    else if ([filterKey isEqualToString:@"sepia"]){
        return [[GPUImageSepiaFilter alloc] init];
    }
    else if ([filterKey isEqualToString:@"haze"]){
        return [[GPUImageHazeFilter alloc] init];
    }
    else if ([filterKey isEqualToString:@"missetikate"]){
        return [[GPUImageMissEtikateFilter alloc] init];
    }
    else if ([filterKey isEqualToString:@"posterize"]){
        return [[GPUImagePosterizeFilter alloc] init];
    }
    else if ([filterKey isEqualToString:@"softelegance"]){
        return [[GPUImageSoftEleganceFilter alloc] init];
    }
    else if ([filterKey isEqualToString:@"falsecolor"]){
        return [[GPUImageFalseColorFilter alloc] init];
    }

    return nil;
}

- (BOOL)isVideoFilterEnabledForSettings:(NSDictionary *)settings
{
    return [[settings objectForKey:@"effectEnabled"] boolValue];
}

- (NSDictionary *)videoFilterConfigurationForSettings:(NSDictionary *)settings
{
    NSDictionary *dic = [settings objectForKey:@"configure"];
    return dic;
}

#pragma mark Getter methods

- (NSArray *)allMetaDataForVideoFilters
{
    return _allMetaDataForVideoFilters;
}


@end

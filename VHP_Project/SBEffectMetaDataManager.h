//
//  SBEffectMetaDataManager.h
//  SongBooth
//
//  Created by Eric Yang on 11/22/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBEffectMetaDataManager : NSObject
@property(readonly, nonatomic)NSArray *allMetaDataForVideoFilters;

+ (SBEffectMetaDataManager *)sharedManager;
- (NSString *)previewImagePathForVideoEffectData:(NSDictionary *)videoEffectData;
- (NSString *)videoEffectNameForEffectMetaData:(NSDictionary *)videoEffectMetaData;
- (NSString *)videoFilterKeyForSettings:(NSDictionary *)settings;
- (id)videoFilterForKey:(NSString *)filterKey;
- (BOOL)isVideoFilterEnabledForSettings:(NSDictionary *)settings;
- (NSDictionary *)videoFilterConfigurationForSettings:(NSDictionary *)settings;

@end

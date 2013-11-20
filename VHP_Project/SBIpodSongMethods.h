//
//  SBIpodSongMethods.h
//  SongBooth
//
//  Created by Eric Yang on 11/16/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBIpodSongMethods : NSObject

+ (SBIpodSongMethods *)instance;

- (NSArray *)pickedSongs;
- (void)addSongs:(NSArray *)array;
- (void)removeSongAtIndex:(NSInteger)index;
- (NSURL *)assetUrlForItem:(NSString *)itemId;

@end

//
//  SBIpodSongMethods.m
//  SongBooth
//
//  Created by Eric Yang on 11/16/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "SBIpodSongMethods.h"
#import <MediaPlayer/MediaPlayer.h>

#define SB_PICKED_IPOD_SONG_DATA_FILE @"ipod_songs.plist"

@implementation SBIpodSongMethods
{
    NSMutableArray *_pickedSongs;
}

static SBIpodSongMethods *_methods = nil;

+ (SBIpodSongMethods *)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _methods = [[SBIpodSongMethods alloc] init];
    });
    return _methods;
}

- (NSArray *)pickedSongs
{
    return _pickedSongs;
}

- (void)addSongs:(NSArray *)array
{
    for(MPMediaItem *item in array) {
        if (![_pickedSongs containsObject:item]) {
            [_pickedSongs addObject:item];
        }
    }
    [self savePickedSongIds];
}

- (void)removeSongAtIndex:(NSInteger)index
{
    [_pickedSongs removeObjectAtIndex:index];
    [self savePickedSongIds];
}

- (NSURL *)assetUrlForItem:(NSString *)itemId
{
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:itemId forProperty:MPMediaItemPropertyPersistentID];
    [query addFilterPredicate:predicate];
    NSArray *songs = [query items];
    if (songs && songs.count) {
        MPMediaItem *item = [songs lastObject];
        return [item valueForProperty:MPMediaItemPropertyAssetURL];
    }
    return nil;
}

#pragma mark

- (id)init
{
    if (self = [super init]) {
        _pickedSongs = [[NSMutableArray alloc] init];
        [self loadPickedIpodSongsFromSavedData];
    }
    return self;
}

- (NSString *)filePath
{
    return [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), SB_PICKED_IPOD_SONG_DATA_FILE];
}

- (NSArray *)getSavedSongIds
{
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:[self filePath]];
    return array;
}

- (BOOL)saveSongIds:(NSArray *)array
{
    return [array writeToFile:[self filePath] atomically:NO];
}

- (void)loadPickedIpodSongsFromSavedData
{
    NSArray *songIds = [self getSavedSongIds];
    if (!songIds || !songIds.count) {
        return;
    }
    for (NSString *songId in songIds) {
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:songId forProperty:MPMediaItemPropertyPersistentID];
        [query addFilterPredicate:predicate];
        NSArray *songs = [query items];
        [_pickedSongs addObjectsFromArray:songs];
    }
}

- (void)savePickedSongIds
{
    if (!_pickedSongs.count) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSMutableArray *itemIds = [[NSMutableArray alloc] init];
        for (MPMediaItem *item in _pickedSongs) {
            [itemIds addObject:[item valueForProperty:MPMediaItemPropertyPersistentID]];
        }
        [self saveSongIds:itemIds];
    });
}


@end

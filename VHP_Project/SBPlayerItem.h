//
//  SBPlayerItem.h
//  SongBooth
//
//  Created by Eric Yang on 10/11/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol SBPlayerItemDelegate;

@interface SBPlayerItem : NSObject

@property (nonatomic, weak) id<SBPlayerItemDelegate> delegate;
@property (nonatomic, readonly) AVPlayerItem *avPlayerItem;
@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) float currentTime;
@property (nonatomic, readonly) float totalTime;

+ (SBPlayerItem *)playerItemWithURL:(NSURL *)URL;

- (id)initWithURL:(NSURL *)URL;
- (void)seekToTime:(CMTime)time;
- (void)setForwardPlaybackEndTime:(CMTime)time;

@end


@protocol SBPlayerItemDelegate <NSObject>

@optional
- (void)playerItemDidStartPlaying:(SBPlayerItem *)playerItem;
- (void)playerItemDidPausePlaying:(SBPlayerItem *)playerItem;
- (void)playerItemDidStopPlaying:(SBPlayerItem *)playerItem finished:(BOOL)flag;
- (void)playerItemDidFailToPlay:(SBPlayerItem *)playerItem;

- (void)playerItem:(SBPlayerItem *)playerItem updatedCurrentTime:(CMTime)time;

@end

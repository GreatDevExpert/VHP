//
//  SBMoviePlayerController.h
//  SongBooth
//
//  Created by Eric Yang on 10/24/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SBMoviePlayerController : MPMoviePlayerController
@property(readwrite, nonatomic)BOOL hideViewWhenStopped;
@property(readwrite, nonatomic)BOOL needShowLoadingIndicator;
@property(readwrite, nonatomic)NSNumber *preCacheLength;

- (void)setViewFrame:(CGRect)frame;
- (void)playContentUrl:(NSURL *)url autoPlay:(BOOL)autoPlay;
- (void)stopPlaying;

- (void)setProgressCallBackBlock:(dispatch_block_t)block;
- (void)setPlayingDidFinishedBlock:(dispatch_block_t)block;

- (void)setProgressBarHidden : (bool) hidden;

@end

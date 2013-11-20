//
//  SBMoviePlayerController.m
//  SongBooth
//
//  Created by Eric Yang on 10/24/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "SBMoviePlayerController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "SBAudioManager.h"

#define SBRGBColor(a,b,c) [UIColor colorWithRed:((a) / 255.0) green:((b) / 255.0) blue:((c) / 255.0) alpha:1]


@interface SBMoviePlayerController()
@property UIImageView *playIcon;
@end
@implementation SBMoviePlayerController
{
    UIView *_tapView;
    NSTimer *_timer;
    UIActivityIndicatorView *_indicator;
    UIButton *_playBtn;
    
    UIView *_controlView;
    BOOL _controlShown;
    UILabel *_timeLabel;
    UIButton *_pauseBtn;
    UIButton *_stopBtn;
    
    BOOL _needAutoPlay;
    
    BOOL _fullscreenMode;
    BOOL _playing;
    CGRect _normalFrame;
    UIView *_normalSuperView;
    UIView *_progress;
    UIView *_progressBack;
    CGFloat _playProgress;
    
    
    UITapGestureRecognizer* rec1, *rec2, *rec3, *rec4;
    dispatch_block_t _progressBlock;
    dispatch_block_t _finishedBlock;
}

@synthesize preCacheLength = _preCacheLength;

- (id)init
{
    if (self = [super init]) {
        self.scalingMode = MPMovieScalingModeAspectFit;
        self.controlStyle = MPMovieControlStyleNone;
        self.view.backgroundColor = [UIColor blackColor];
        self.view.layer.masksToBounds = YES;
        self.shouldAutoplay = NO;
        self.repeatMode = MPMovieRepeatModeNone;
        _hideViewWhenStopped = YES;
        _needShowLoadingIndicator = YES;
                
        _tapView = [[UIView alloc] initWithFrame:CGRectZero];
        _tapView.userInteractionEnabled = YES;
        _tapView.backgroundColor = [UIColor clearColor];
        rec1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        rec1.numberOfTapsRequired = 1;
        [_tapView addGestureRecognizer:rec1];
        
        rec2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        rec2.numberOfTapsRequired = 2;
        [_tapView addGestureRecognizer:rec2];

        [rec1 requireGestureRecognizerToFail:rec2];
        
        [self.view addSubview:_tapView];
        _fullscreenMode = NO;
        _playing = NO;
        _playProgress = 0;
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = YES;
        [self.view addSubview:_indicator];
        
        _playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnPlay.png"]];
        [self.view addSubview:_playIcon];
        _playIcon.hidden = NO;
        _playIcon.userInteractionEnabled = YES;
        rec3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_playIcon addGestureRecognizer:rec3];
        [_playIcon setCenter:CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f)];

/*
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.frame = CGRectMake(0.0f, 0.0f, 43.0f, 43.0f);
        [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setImage:[UIImage imageNamed:@"button_play.png"] forState:UIControlStateNormal];
        [self.view addSubview:_playBtn];

        
        _controlShown = NO;
        _controlView = [[UIView alloc] initWithFrame:CGRectZero];
        _controlView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4];
        [self.view addSubview:_controlView];
        
        _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pauseBtn.frame = CGRectMake(10.0f, 2.0f, 16.0f, 16.0f);
        [_pauseBtn setImage:[UIImage imageNamed:@"player_icon_pause.png"] forState:UIControlStateNormal];
        [_pauseBtn addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
        [_controlView addSubview:_pauseBtn];
        
        _stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopBtn.frame = CGRectMake(40.0f, 2.0f, 16.0f, 16.0f);
        [_stopBtn setImage:[UIImage imageNamed:@"player_icon_stop.png"] forState:UIControlStateNormal];
        [_stopBtn addTarget:self action:@selector(stopPlaying) forControlEvents:UIControlEventTouchUpInside];
        [_controlView addSubview:_stopBtn];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:10.0f];
        [_controlView addSubview:_timeLabel];
*/
        _progressBack = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 6, self.view.frame.size.width, 6)];

        _progressBack.backgroundColor = SBRGBColor(0, 0, 0);
        _progressBack.alpha = 0.8;
        
        _progress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _progressBack.frame.size.width * _playProgress, 6)];
        _progress.backgroundColor = SBRGBColor(194, 194, 194);
        _progress.alpha = 0.8;
        
        [self.view addSubview:_progressBack];
        [_progressBack addSubview:_progress];
        
        self.preCacheLength = [NSNumber numberWithFloat:5.0f];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventForPlaybackDidFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventForPlaybackStatusChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventForPlaybackLoadStatusChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventForPlaybackStatusChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    }
    return self;
}

- (void)pauseAction:(id)sender
{
    if (self.playbackState != MPMoviePlaybackStatePaused)
        [self pause];
    
//    [self needTimerTrack:NO];
//    _playIcon.hidden = NO;
    //[self.view bringSubviewToFront:_playIcon];

/*
    if (self.playbackState != MPMoviePlaybackStatePlaying) {
        [self play];
        [self needTimerTrack:YES];
        [_pauseBtn setImage:[UIImage imageNamed:@"player_icon_pause.png"] forState:UIControlStateNormal];
        
        _playIcon.hidden = YES;
    }
    else {
        [self needTimerTrack:NO];
        [self pause];
        [_pauseBtn setImage:[UIImage imageNamed:@"player_icon_play.png"] forState:UIControlStateNormal];
    
        _playIcon.hidden = NO;
        [self.view bringSubviewToFront:_playIcon];
    }
 */
}

- (void)playAction:(id)sender
{
    if (self.playbackState == MPMoviePlaybackStatePlaying)
        return;
    
    [self play];
    [self needTimerTrack:YES];
    
    _playIcon.hidden = YES;
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    [_indicator stopAnimating];
    
    if (_playing)
        [self pauseAction:nil];
    else
        [self playAction:nil];
    
    _playing = !_playing;
    NSLog(@"user set play state = %d", _playing);
}

- (void) doubleTapAction : (UITapGestureRecognizer *)tap
{
    if (_fullscreenMode)
    {
        [self setViewFrame:_normalFrame];
        [self.view removeFromSuperview];
        [self setViewFrame:_normalFrame];
        [_normalSuperView addSubview:self.view];
    }
    else
    {
        _normalSuperView = self.view.superview;
        _normalFrame = self.view.frame;
        [self.view removeFromSuperview];
        [self setViewFrame:[UIApplication sharedApplication].keyWindow.frame];
        [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    }
    
    _fullscreenMode = !_fullscreenMode;
}

- (void)setCurrentProgress : (CGFloat) progress
{
    _playProgress = progress;
    
    _progress.frame = CGRectMake(0, 0, _progressBack.frame.size.width * _playProgress, 6);
}

- (void)setViewFrame:(CGRect)frame
{
    self.view.frame = frame;

//    _playBtn.center = CGPointMake(frame.size.width / 2.0f, frame.size.height / 2.0f);
    _indicator.center = CGPointMake(frame.size.width / 2.0f, frame.size.height / 2.0f);
    [_tapView setFrame:self.view.bounds];
//    _controlView.frame = CGRectMake(0.0f, frame.size.height, frame.size.width, 20.0f);
//    _timeLabel.frame = CGRectMake(_controlView.frame.size.width - 80.0f - 10.0f, 0.0f, 80.0f, 20.0f);

    _progressBack.frame = CGRectMake(0, self.view.frame.size.height - 6, self.view.frame.size.width, 6);
    _progress.frame = CGRectMake(0, 0, _progressBack.frame.size.width * _playProgress, 6);
    
    [_playIcon setCenter:CGPointMake(frame.size.width / 2.0f, frame.size.height / 2.0f)];
}

- (void)showControlView:(BOOL)show animated:(BOOL)animate
{
    return;
    CGRect frame  = _controlView.frame;
    if (show) {
        frame.origin.y = self.view.frame.size.height - frame.size.height;
    }
    else {
        frame.origin.y = self.view.frame.size.height;
    }
    _controlShown = show;
    [UIView animateWithDuration:animate ? 0.3f : 0.0f animations:^ {
        _controlView.frame = frame;
    }];
}

- (void)playContentUrl:(NSURL *)url autoPlay:(BOOL)autoPlay
{
    _needAutoPlay = autoPlay;
    //[_playBtn setHidden:YES];
    if (_needShowLoadingIndicator) {
        [_indicator startAnimating];
    }
    [self stop];
    _timeLabel.text = @"--:-- / --:--";
    self.contentURL = url;
    [self prepareToPlay];
    
    if (autoPlay)
    {
        _playing = YES;
        _playIcon.hidden = YES;
    }
    
    [[SBAudioManager sharedInstance] resetAudioCategoryForPlayAndRecord:NO];
    [[SBAudioManager sharedInstance] resetAudioSessionRoute];
    [self needTimerTrack:YES];
}

- (void)setProgressBarHidden : (bool) hidden
{
    _progressBack.hidden = hidden;
}

- (void)stopPlaying
{
//    [self stop];
    //[self needTimerTrack:NO];
    if (_finishedBlock) {
        _finishedBlock();
    }
/*    if ([self.view superview] && _hideViewWhenStopped) {
        [self.view removeFromSuperview];
    }
    else {
        [self prepareToPlay];
        _timeLabel.text = @"--:-- / --:--";
    }
 */
    [self pauseAction:nil];
    _playing = NO;
}

- (void)setProgressCallBackBlock:(dispatch_block_t)block
{
    _progressBlock = block;
}

- (void)setPlayingDidFinishedBlock:(dispatch_block_t)block
{
    _finishedBlock = block;
}

#pragma mark Timer Action

- (void)needTimerTrack:(BOOL)needTimer
{
    if (needTimer && !_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    }
    else if (_timer && _timer.isValid && !needTimer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timerAction:(id)sender
{
    float currentTime = self.currentPlaybackTime;
    float movieLength = self.duration;
    float playable = self.playableDuration;
    
    if (!_playing && !_needAutoPlay)//skip when user pauses
        return;
    
    if (playable > currentTime)//change play state
    {
        if (_needAutoPlay)//first time end bufferring
        {
            _needAutoPlay = NO;
            _playing = YES;
        }
        
        if ([self playbackState] != MPMoviePlaybackStatePlaying)
            [self play];
    }
    
    if (self.playbackState == MPMoviePlaybackStatePlaying)//change indicator state
    {
        [self setCurrentProgress:currentTime / movieLength];
        if (_progressBlock) {
            _progressBlock();
        }
        [_indicator stopAnimating];
    }
    else
    {
        [_indicator startAnimating];
    }
/*
    if ([self canPlayAtTime:currentTime withPlayableDuration:playable andVideoLength:movieLength])
    {
        if (!_playing)//user tap for pausing
            return;
        
        [_indicator stopAnimating];
        if (_needAutoPlay)
        {
            if (self.playbackState != MPMoviePlaybackStatePlaying)
                [self play];
        }
    }
    else
    {
        [_indicator startAnimating];
        if (self.playbackState == MPMoviePlaybackStatePlaying)
            [self pause];
    }
 */
}

- (bool) canPlayAtTime : (float) currentTime withPlayableDuration : (float) playable andVideoLength : (float) length
{
//    NSLog(@"current playable[%f], time[%f], length[%f]", playable, currentTime, length);
    if (length == 0)
        return NO;//first time begin caching
    
    if (currentTime >= length)//end playing
        return NO;
    
    if (playable >= length)
        return YES;//finish downloading
    
    if ([_indicator isAnimating])//caching
    {
        if (playable - currentTime < [self.preCacheLength floatValue])
            return NO;
        
        return YES;
    }
    else//playing
    {
        if (playable <= currentTime)
            return NO;
        
        return YES;
    }
}

#pragma mark notification methods
- (void)eventForPlaybackDidFinished:(NSNotification *)notification
{
    NSObject *obj = [notification object];
    if (obj != self) {
        return;
    }
    [self stopPlaying];
}

- (void)eventForPlaybackStatusChanged:(NSNotification *)notification
{
    NSObject *obj = [notification object];
    if (obj != self) {
        return;
    }
    if (self.playbackState == MPMoviePlaybackStatePaused || self.playbackState == MPMoviePlaybackStateInterrupted || self.playbackState == MPMoviePlaybackStateStopped) {
        [_playIcon setHidden:NO];
    }
    else {
        [_playIcon setHidden:YES];
    }
}

- (void)setVideoFrameInBoundsOfVideoListCell:(CGSize)naturalSize
{
    double cellWidth = [[UIScreen mainScreen] bounds].size.width;
    double cellHeight = 140.0f;
    if (naturalSize.height == 0) {
        // this should never happen though
        [self setViewFrame:CGRectMake(0.0f, 0.0f, cellWidth, cellHeight)];
        return;
    }
    
    CGSize boundsSize = CGSizeMake(cellWidth, cellHeight);
    double boundsRatio = boundsSize.width / boundsSize.height;
    double nativeRatio = naturalSize.width / naturalSize.height;
    double viewX, viewY, viewWidth, viewHeight;
    if (boundsRatio > nativeRatio) {
        viewY = 0;
        viewHeight = cellHeight;
        viewWidth = cellHeight * nativeRatio;
        viewX = (cellWidth - viewWidth ) / 2;
    } else {
        viewX = 0;
        viewWidth = cellWidth;
        viewHeight = cellWidth / nativeRatio;
        viewY = (cellHeight - viewHeight) / 2;
    }
    [self setViewFrame:CGRectMake(viewX, viewY, viewWidth, viewHeight)];
}

//- (void)eventForPlaybackLoadStatusChanged:(NSNotification *)notification
//{
//    NSObject *obj = [notification object];
//    if (obj != self) {
//        return;
//    }
//    NSLog(@"new load staus %d", self.loadState);
//}

@end

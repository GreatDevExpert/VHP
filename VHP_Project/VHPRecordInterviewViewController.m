//
//  VHPRecordInterviewViewController.m
//  VHP_Project
//
//  Created by Steve on 4/16/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPRecordInterviewViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VHPTagListViewController.h"
#import "SVProgressHUD.h"
#import "SCRecorder.h"
#import "SCRecordSessionManager.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#define DOCUMENTS_FOLDER NSTemporaryDirectory()

#define VIDEO_SIZE_WIDTH    320
#define VIDEO_SIZE_HEIGHT    320
#define SCREEN_WIDTH   ([[UIScreen mainScreen]bounds].size.width)
#define SCREEN_HEIGHT   ([[UIScreen mainScreen]bounds].size.height)
#define MARGIN_TOP          64

@interface VHPRecordInterviewViewController () <AVAudioRecorderDelegate, SCRecorderDelegate, UIAlertViewDelegate>
{
    AVPlayer *_player;
    id _observer;
    
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
}

@property NSURL* exportUrl;
@property (weak, nonatomic) IBOutlet UIView *cntView;
@property UIImagePickerController *videoRecorder;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property NSMutableArray* questionArray;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property AppDelegate *app;
@property int index;
@property BOOL recording;
@property UILabel* timeLabel;
@property int recordingTime;
@property NSTimer* recordingTimer;
@property UIView *circleView;
@property NSMutableArray* files;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property NSMutableDictionary* tagArray;
@property UINavigationController* nc;
@property UIStoryboard* sb;
@property int recordingMode;
@property UILabel* statusRecordingLabel, *statusRecordingView;
@property AVAudioRecorder* audioRecorder;
@property NSString* recorderFilePath;
@property UIGestureRecognizer* recordRecognizer;
@end

@implementation VHPRecordInterviewViewController
@synthesize videoRecorder, exportUrl;
@synthesize nc, sb;

- (void)viewDidLoad {
    [super viewDidLoad];
    nc = self.navigationController;
    sb = self.storyboard;   
    
    [SVProgressHUD dismiss];
    _recordingMode = 0; //Video
    _app = [[UIApplication sharedApplication]delegate];
    
    int width = [[UIScreen mainScreen]bounds].size.width;
    int height = _previewView.frame.size.height - (64 + _cntView.frame.size.height);
    
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.maxRecordDuration = CMTimeMake(3600 * 5, 1);
    _recorder.fastRecordMethodEnabled = YES;
    _recorder.delegate = self;
    [_recorder setVideoOrientation:AVCaptureVideoOrientationPortrait];

    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    _recording = NO;
    
    UITapGestureRecognizer* recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onRecord:)];
    recog.numberOfTapsRequired = 1;
    
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(width / 2 - 25, 5, 50, 50)];
    imageView.image = [UIImage imageNamed:@"record.png"];
    imageView.layer.cornerRadius = 25;
    imageView.clipsToBounds = YES;
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(35, 35);
    imageView.layer.shadowRadius = 55;
    imageView.layer.borderColor = [UIColor grayColor].CGColor;
    imageView.layer.borderWidth = 0.5;
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:(_recordRecognizer = recog)];
    
    UIImageView* tagButton = [[UIImageView alloc]initWithFrame:CGRectMake(width - 60, 10, 40, 40)];
    tagButton.image = [UIImage imageNamed:@"notepad.png"];
    tagButton.clipsToBounds = YES;
    tagButton.userInteractionEnabled = YES;
    tagButton.layer.opacity = 0.6;
    
    UIImageView* quoteButton = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 40, 40)];
    quoteButton.image = [UIImage imageNamed:@"quote.png"];
    quoteButton.clipsToBounds = YES;
    quoteButton.userInteractionEnabled = YES;
    quoteButton.layer.opacity = 0.6;
    
    
    UITapGestureRecognizer* recogTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTag:)];
    recogTap.numberOfTapsRequired = 1;
    
    UIView* viewTagButton = [[UIView alloc]initWithFrame:CGRectMake(width-60, 0, 60, 60)];
    viewTagButton.userInteractionEnabled = YES;

    UITapGestureRecognizer* recogTap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTagQuote:)];
    recogTap1.numberOfTapsRequired = 1;

    UIView* viewTagButton1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    viewTagButton1.userInteractionEnabled = YES;
    
    UIView* grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, width, 40)];
    grayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    UIView* grayBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, height - 60 + 64, width, 60)];
    grayBottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [grayBottomView addSubview:imageView];
    [grayBottomView addSubview:tagButton];
    [grayBottomView addSubview:viewTagButton];
    [grayBottomView addSubview:quoteButton];
    [grayBottomView addSubview:viewTagButton1];

    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 40)];
    [_timeLabel setTextColor:[UIColor whiteColor]];
    [_timeLabel setText:@"00:00"];
    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    [grayView addSubview:_timeLabel];
    _recordingTime = 0;
    
    _circleView = [[UIView alloc]initWithFrame:CGRectMake(width - 25, 15, 10, 10)];
    [_circleView setBackgroundColor:[UIColor redColor]];
    [_circleView setHidden:YES];
    _circleView.layer.cornerRadius = 5;
    [grayView addSubview:_circleView];
    
    [previewView addSubview:grayView];
    [previewView addSubview:grayBottomView];
    
    CGPoint cp;
    cp.x = (grayView.center.x + grayBottomView.center.x) / 2;
    cp.y = (grayView.center.y + grayBottomView.center.y) / 2;
    
    _statusRecordingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width - 30, 60)];
    _statusRecordingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width - 30, 60)];
    [_statusRecordingLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:13]];
    [_statusRecordingLabel setCenter:cp];
    [_statusRecordingView setCenter:cp];
    [_statusRecordingLabel setText:@"Please tap the record button \nto start recording"];
    [_statusRecordingLabel setNumberOfLines:2];
    [_statusRecordingLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusRecordingLabel setTextColor:[UIColor whiteColor]];
    [_statusRecordingView setBackgroundColor:[UIColor blackColor]];
    _statusRecordingView.layer.opacity = 0.5;
    [previewView addSubview: _statusRecordingView];
    [previewView addSubview: _statusRecordingLabel];
    _questionArray = [[NSMutableArray alloc]initWithArray:[_app.tempData objectForKey:@"questions"]];
   
    _index = 0;
    
    _files = [[NSMutableArray alloc]init];
    [self updateQuestionDisplay];
    _tagArray = [[NSMutableDictionary alloc]init];
    [self.view sendSubviewToBack:previewView];
    
    _previewView.userInteractionEnabled = YES;
    UITapGestureRecognizer* recog2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTag:)];
    recog2.numberOfTapsRequired = 1;
    [_previewView addGestureRecognizer:recog2];
    
    tagButton.hidden = YES;
    quoteButton.hidden = YES;
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Interview" message:@"Select Mode" delegate:self cancelButtonTitle:@"Video Interview" otherButtonTitles:@"Audio Interview", nil];
    alertView.tag = CHOOSE_INTERVIEW_MODE_AUDIO_OR_VIDEO;
    [alertView show];
    
    UIImageView* speakerView = [[UIImageView alloc]initWithFrame:CGRectMake(-100, -100, 50, 50)];
    [speakerView setCenter:CGPointMake(SCREEN_WIDTH / 2, (grayBottomView.frame.origin.y + grayView.frame.size.height + grayView.frame.origin.y) / 2)];
    [speakerView setImage:[UIImage imageNamed:@"speaker.png"]];
    [speakerView setHidden:YES];
    speakerView.tag = 72;
    [previewView addSubview:speakerView];
}
-(void)pauseRecord
{
    if (_recording)
    {
        [self onRecord:_recordRecognizer];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseRecord) name:@"pause_record" object:nil];
    [_recorder startRunning];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"pause_record" object:nil];
    [_recorder stopRunning];
}
- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    NSLog(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void) handleStopButtonTapped:(id)sender {
    [_recorder pause:^{
        [self saveAndShowSession:_recorder.session];
    }];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    
    _recordSession = recordSession;
}

- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    [self updateGhostImage];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
    [self saveAndShowSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
    

    [_files addObject:segment.url];
}

- (void)updateGhostImage {
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareSession];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

-(void)onRemoveTag:(id)sender
{
    [SVProgressHUD dismiss];
}

-(void)onTagQuote:(UIGestureRecognizer*)recognizer
{
    if (_recordingTime == 0) return;
    if ([_tagArray objectForKey:[NSNumber numberWithInteger:_recordingTime]] == nil)
    {
        [SVProgressHUD showSuccessWithStatus:@"Quoted"];
        [self performSelector:@selector(onRemoveTag:) withObject:nil afterDelay:0.25];
        [_tagArray setObject:_questionLabel.text forKey:[NSString stringWithFormat:@"%d", -_recordingTime]];
    }
}

-(void)onTag:(UIGestureRecognizer*)recognizer
{
    if (_recordingTime == 0) return;
    if ([_tagArray objectForKey:[NSNumber numberWithInteger:_recordingTime]] == nil)
    {
        [SVProgressHUD showSuccessWithStatus:@"Tagged"];
        [self performSelector:@selector(onRemoveTag:) withObject:nil afterDelay:0.25];
        [_tagArray setObject:_questionLabel.text forKey:[NSString stringWithFormat:@"%d", _recordingTime]];
    }
}

-(void)onTimer:(id)timer
{
    _recordingTime++;
    
    if (_recordingTime % 5 == 0)
        _circleView.hidden = !_circleView.hidden;
    if (_recordingTime % 20 == 0)
    {
        NSString* timeString;
        int seconds = _recordingTime / 20;
        if (seconds >= 3600)
            timeString = [NSString stringWithFormat:@"%d:%02d:%02d", seconds / 3600, (seconds / 60) % 60, seconds % 60];
        else
            timeString = [NSString stringWithFormat:@"%02d:%02d", (seconds / 60) % 60, seconds % 60];
        [_timeLabel setText:timeString];
    }
}

-(void)onRecord:(UIGestureRecognizer*)recog
{
    UIImageView* recordImageView = (UIImageView*)(recog.view);
    [_statusRecordingLabel setText:@"Please tap the record button \nto resume recording"];
    if (_recordingMode == 0) {
        if (_recording)
        {
            [_recorder pause];
            _recording = NO;
            [recordImageView setImage:[UIImage imageNamed:@"record.png"]];
            if (_recordingTimer != nil) [_recordingTimer invalidate];
            _recordingTimer = nil;
            [_circleView setHidden:YES];
            
            [_statusRecordingView setHidden:NO];
            [_statusRecordingLabel setHidden:NO];
            
        }
        else
        {
            _recording = YES;
            
            [_statusRecordingView setHidden:YES];
            [_statusRecordingLabel setHidden:YES];
            
            [recordImageView setImage:[UIImage imageNamed:@"pause.png"]];
            
            [_recorder record];
            if (_recordingTimer)
                [_recordingTimer invalidate];
            
            {
                [self performSelector:@selector(startTimer:) withObject:nil afterDelay:0.5];
            }
        }
    }
    else {
        if (_recording)
        {
            [self stopRecording];
            _recording = NO;
            [recordImageView setImage:[UIImage imageNamed:@"record.png"]];
            if (_recordingTimer != nil) [_recordingTimer invalidate];
            _recordingTimer = nil;
            [_circleView setHidden:YES];
            [_statusRecordingView setHidden:NO];
            [_statusRecordingLabel setHidden:NO];
        }
        else
        {
            _recording = YES;
            [recordImageView setImage:[UIImage imageNamed:@"pause.png"]];
            [self startRecording];
            [_statusRecordingView setHidden:YES];
            [_statusRecordingLabel setHidden:YES];
            if (_recordingTimer)
                [_recordingTimer invalidate];
            
            {
                [self performSelector:@selector(startTimer:) withObject:nil afterDelay:0.5];
            }
        }

    }
}

-(void)startTimer:(id)sender
{
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)RecordVideoButton:(id)sender
{
    if (_recordingMode == 0)
    {
        if (_recordingTime == 0)
        {
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"You didn't record any video. Would you like to load existing video?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alertView.tag = LOAD_EXISTING_VIDEO_DIALOG;
            [alertView show];
            return;
        }
        if (_recording) return;
        
        NSURL *url;
        
        if ([_files count] == 1)
        {
            url = _files[0];
            [self cropVideo:url];
        }
        else {
            //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
            AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
            AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
            
            CMTime tempDuration = kCMTimeZero;
            for (int i = 0; i < [_files count]; i ++) {
                AVAsset* tempAsset = [AVAsset assetWithURL:[_files objectAtIndex:i]];
                if(tempAsset !=nil){

                    //VIDEO TRACK
                    if ([[tempAsset tracksWithMediaType:AVMediaTypeVideo]count])
                    {
                        
                        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, tempAsset.duration) ofTrack:[[tempAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:tempDuration error:nil];
                        firstTrack.preferredTransform = [[[tempAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform];
                    }
                    //AUDIO TRACK
                    if ([[tempAsset tracksWithMediaType:AVMediaTypeAudio] count])
                        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, tempAsset.duration) ofTrack:[[tempAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:tempDuration error:nil];
                    
                    tempDuration.value += tempAsset.duration.value;
                    tempDuration.timescale = tempAsset.duration.timescale;
                    tempDuration.flags = tempAsset.duration.flags;
                    tempDuration.epoch = tempAsset.duration.epoch;
                }
            }
            
            NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject];

            url = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingString:@"output.mov" ]];
            
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
            exporter.outputURL=url;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
                NSError* error;
                [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&error];
                
            }
            
            exporter.outputFileType = AVFileTypeQuickTimeMovie;
            exporter.shouldOptimizeForNetworkUse = YES;
            
            id selfObject = self;
            __block BOOL goOnFlag = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int count = 0;
                while(fabs(exporter.progress - 1.0)>0.01&&goOnFlag){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Merging... : %d%%",(int)(100 * exporter.progress)] maskType:SVProgressHUDMaskTypeGradient];
                    });
                    sleep(1);
                    if(exporter.progress==0)
                        count++;
                    if(count>8){
                        
                            [exporter cancelExport];
                            goOnFlag = NO;
                            NSLog(@"save failed");
                        
                    }
                }
            });
            
            [exporter exportAsynchronouslyWithCompletionHandler:^(void)
             {
                 if (exporter.status == AVAssetExportSessionStatusCompleted)
                 {
                     NSFileManager *fm = [NSFileManager defaultManager];
                     for (NSURL *url1 in _files) {
                         NSError* err = nil;
                         [fm removeItemAtPath:[url1 path] error:&err];
                         if(err)
                             NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
                     }
                     [selfObject cropVideo:url];
                 }
                 else if (exporter.status == AVAssetExportSessionStatusFailed)
                     [SVProgressHUD showErrorWithStatus:@"Export Failed"];
                 else if (exporter.status == AVAssetExportSessionStatusCancelled)
                     [SVProgressHUD showErrorWithStatus:@"Export Failed"];
                 //             [self presentViewController:moviePlayer animated:YES completion:nil];
             }];
        }
    }
    else
    {
        if (_recordingTime == 0) return;
        if (_recording) return;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        
        if (![self combineVoices])
        {
            [SVProgressHUD showErrorWithStatus:@"Error! Try again"];
            return;
        }
            
    }
}

- (BOOL) combineVoices {
    
    NSError *error = nil;
    BOOL ok = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    CMTime nextClipStartTime = kCMTimeZero;
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    for (NSURL* url in _files) {
        
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
        if ([tracks count] == 0)
            return NO;
        CMTimeRange timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [avAsset duration]);
        AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        ok = [compositionAudioTrack insertTimeRange:timeRangeInAsset  ofTrack:clipAudioTrack atTime:nextClipStartTime error:&error];
        if (!ok) {
            NSLog(@"Current Video Track Error: %@",error);
        }
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
    }
    
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    
    
    if (nil == exportSession) return NO;
    

    
    NSString *soundOneNew = [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"combined.m4a"];
    NSError* err;

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:soundOneNew])
        [fm removeItemAtPath:soundOneNew error:&err];
    if (err)
    {
        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
   
    // configure export session  output with all our parameters
    __block NSURL* outputURL = [NSURL fileURLWithPath:soundOneNew];
    exportSession.outputURL = outputURL; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    __block VHPRecordInterviewViewController* selfObject = self;;

    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                VHPTagListViewController* vc = (VHPTagListViewController*)[selfObject.storyboard instantiateViewControllerWithIdentifier:@"taglistviewcontroller"];
                vc.videoURL = outputURL;
                vc.tagList = _tagArray;
                AVURLAsset *avUrl = [AVURLAsset assetWithURL:outputURL];
                CMTime time = [avUrl duration];
                int seconds = ceil(time.value/time.timescale);
                vc.timeLength = [NSNumber numberWithInteger:seconds];
                [SVProgressHUD dismiss];
                [nc pushViewController:vc animated:YES];
                
            });
            
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
            NSLog(@"%@", exportSession.error);
            [SVProgressHUD showErrorWithStatus:@"Export Failed"];
            
        } else {
            NSLog(@"Export Session Status: %d", exportSession.status);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Export Session Status: %d", exportSession.status]];
        }
    }];
    
    return YES;
}



-(void)cropVideo:(NSURL*)outputFileURL
{
    NSURL* originalURL = outputFileURL;
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"Processing Video..." maskType:SVProgressHUDMaskTypeGradient];
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    // 2 - Video track
    
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    mainCompositionInst.renderSize = CGSizeMake(VIDEO_SIZE_WIDTH, VIDEO_SIZE_HEIGHT);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    CMTime timeR=kCMTimeZero;
    
    AVAsset *videoAsset=nil;
    AVMutableCompositionTrack *videoTrack=nil;
    NSError *err=nil;
    NSMutableArray *vidInstArray=[[NSMutableArray alloc] init];
    NSMutableArray *assetArray=[[NSMutableArray alloc] init];
    NSMutableArray *trackArray=[[NSMutableArray alloc] init];
    
    videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                             preferredTrackID:kCMPersistentTrackID_Invalid];
    
    videoAsset = [AVAsset assetWithURL:outputFileURL];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:&err];
    
    [assetArray addObject:videoAsset];
    [trackArray addObject:videoTrack];
    if(err)
    {
        NSLog(@"Custom Error Log: %@",err);
        err=nil;
    }
    
    /*            if(CMTimeCompare(timeR,videoAsset.duration)<0)
     {
     timeR=videoAsset.duration;
     }*/
    //            CMTime b=videoAsset.duration;
    //            //            timeR=b;
    //            int bbb=CMTimeCompare(b, timeR);
    //            if(bbb>0)
    //                timeR=b;
    //CMTimeMaximum(timeR,videoAsset.duration);
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    CGAffineTransform orientationTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
        orientationTransform = CGAffineTransformMakeRotation(M_PI_2);
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
        orientationTransform = CGAffineTransformMakeRotation(- M_PI_2);
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
        orientationTransform = CGAffineTransformMakeRotation(- M_PI);
    }
    
    //            [videolayerInstruction]
    //            [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];//don't make it disappear
    
    // 3.3 - Add instructions
    
    CGSize naturalSize;
    //        CGRect subFrameRect = CGRectMake(0, 0, 320, 320);
    

    
    //        CGRect fr=CGRectMake(0, -70, <#CGFloat width#>, <#CGFloat height#>);
    CGRect cropRect;
    CGAffineTransform trans1;
    //        if(isVideoAssetPortrait_){
    naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    
    cropRect=CGRectMake( MARGIN_TOP*naturalSize.height/SCREEN_HEIGHT, 0, naturalSize.width, naturalSize.width);
    //ceilf(subFrameRect.size.width/SCREEN_WIDTH*naturalSize.width)
    //            trans1=CGAffineTransformMakeTranslation( 0,-MARGIN_TOP);
    
    
    
    //        } else {
    //            naturalSize = videoAssetTrack.naturalSize;
    //
    //            cropRect=CGRectMake(0, MARGIN_TOP/SCREEN_HEIGHT*naturalSize.height, naturalSize.width, naturalSize.width);
    //        }
    float scale=VIDEO_SIZE_WIDTH/naturalSize.width;
    float scale_xxx = VIDEO_SIZE_WIDTH/SCREEN_WIDTH;
    
    float xMargin = 0, yMargin = 0;
    
    if(naturalSize.height/naturalSize.width >= SCREEN_HEIGHT/SCREEN_WIDTH)
    {
        yMargin = (naturalSize.height*SCREEN_WIDTH/naturalSize.width - SCREEN_HEIGHT)/2;// - (SCREEN_HEIGHT * naturalSize.width/SCREEN_WIDTH));
    }
    else{
        xMargin = (naturalSize.width*SCREEN_HEIGHT/naturalSize.height - SCREEN_WIDTH)/2;
        scale=VIDEO_SIZE_HEIGHT/(naturalSize.height*SCREEN_WIDTH/SCREEN_HEIGHT);
        //            scale_xxx = VIDEO_SIZE_HEIGHT/SCREEN_HEIGHT;
        
    }
    
    
    trans1=CGAffineTransformMakeTranslation(-xMargin, -MARGIN_TOP*scale_xxx-yMargin*scale_xxx);
    
    NSLog(@"Natural Size: %f %f  Sale: %f", naturalSize.width, naturalSize.height, scale);
    NSLog(@"Natural Size: %f %f %f %f", cropRect.origin.x, cropRect.origin.y, cropRect.size.width, cropRect.size.height);
    
    CGAffineTransform trans=CGAffineTransformMakeScale(scale, scale);
    
    CGAffineTransform transResult = CGAffineTransformConcat(videoTransform ,CGAffineTransformConcat(trans, trans1));
//    transResult = CGAffineTransformConcat(transResult, orientationTransform);
    
    [videolayerInstruction setTransform:transResult atTime:kCMTimeZero];
    
    //        [videolayerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
    
    [vidInstArray addObject:videolayerInstruction];
    
    
    mainInstruction.layerInstructions = vidInstArray;//[NSArray arrayWithObjects:videolayerInstruction,nil];
    mainInstruction.timeRange =CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 2 - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, VIDEO_SIZE_WIDTH,VIDEO_SIZE_WIDTH);
    
    videoLayer.frame=parentLayer.frame;
    //    videoLayer.frame = subFrameRect;
    
    //    [videoLayer setContentsRect:CGRectMake(0, 0, 0.5,0.5)];
    
    [parentLayer addSublayer:videoLayer];
    
    //    [parentLayer addSublayer:overlayLayer];
    // 3 - apply magic
    mainCompositionInst.animationTool = [AVVideoCompositionCoreAnimationTool
                                         videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
   
    NSArray* arr= [videoAsset tracksWithMediaType:AVMediaTypeAudio];

    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    if ([arr count] > 0)
        [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                        ofTrack:[arr objectAtIndex:0] atTime:kCMTimeZero error:&err];
    
    
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                         presetName:AVAssetExportPresetLowQuality];
    
    
    NSString* videoName = @"export.mov";
    
    
    
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    
    exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = exportUrl;
    assetExport.shouldOptimizeForNetworkUse = YES;
    assetExport.videoComposition = mainCompositionInst;
    
    __block BOOL goOnFlag = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int count = 0;
        while(fabs(assetExport.progress - 1.0)>0.01&&goOnFlag){
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Processing... : %d%%",(int)(100 * assetExport.progress)] maskType:SVProgressHUDMaskTypeGradient];
            });
            sleep(1);
            if(assetExport.progress==0)
                count++;
            if(count>8){
                
                [assetExport cancelExport];
                goOnFlag = NO;
                NSLog(@"save failed");
                
            }
        }
    });
    
    
    [assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (assetExport.status == AVAssetExportSessionStatusCompleted)
            {
                AVURLAsset *avUrl = [AVURLAsset assetWithURL:exportUrl];
                CMTime time = [avUrl duration];
                int seconds = ceil(time.value/time.timescale);
                
                NSLog(@"file exported: %@", exportUrl);
                VHPTagListViewController* vc = (VHPTagListViewController*)[sb instantiateViewControllerWithIdentifier:@"taglistviewcontroller"];
                vc.videoURL = exportUrl;
                vc.tagList = _tagArray;
                vc.timeLength = [NSNumber numberWithInteger:seconds];
                
                NSFileManager *fm = [NSFileManager defaultManager];
                NSError* err = nil;
                
                if ([_files count] > 1)
                    [fm removeItemAtPath:[originalURL path] error:&err];

                if(err)
                    NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
                
                
                [nc pushViewController:vc animated:YES];
            }
            else
                [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Export Failed. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        });
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CHOOSE_INTERVIEW_MODE_AUDIO_OR_VIDEO)
    {
        if (buttonIndex == 0) return;
        _recordingMode = 1;
        _recorder.previewView = nil;
        [[_previewView viewWithTag:72] setHidden:NO];
        _previewView.backgroundColor = [UIColor blackColor];
        return;
    }
    else if (alertView.tag == LOAD_EXISTING_VIDEO_DIALOG) {
        if (buttonIndex == 0)
        {
            return;
        }
        else if (buttonIndex == 1)
        {
            int seconds = 0;
            VHPTagListViewController* vc = (VHPTagListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"taglistviewcontroller"];
            vc.videoURL = nil;
            vc.tagList = [[NSMutableDictionary alloc]init];
            vc.timeLength = [NSNumber numberWithInteger:seconds];
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
}

-(NSString *)fileDirectoryPathForSubDirName:(NSString *)subDirName;
{
    NSString *path = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(), subDirName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (NSString *)dirPathForRecordingFiles
{
    return [self fileDirectoryPathForSubDirName:@"recording_files"];
}

- (NSURL *)videoCapturingUrlForItem:(NSString *)itemKey
{
    if ([itemKey rangeOfString:@"/"].location == NSNotFound)
        return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_captured_video.mov", [self dirPathForRecordingFiles], itemKey]];
    else return [[NSURL alloc]initWithString:itemKey];
}

- (IBAction)ONBACK:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    
    if (_index == 0 && _recordingTime == 0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirm"
                                                                       message:@"You didn't start recording yet.\nAre you sure to navigate the questions before recording?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  _index = MIN(_index + 1, [_questionArray count]);
                                                                  [self updateQuestionDisplay];
                                                              }];
        
        UIAlertAction* defaultAction1 = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [alert addAction:defaultAction1];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        _index = MIN(_index + 1, [_questionArray count]);
        [self updateQuestionDisplay];
    }
}

- (IBAction)onPrev:(id)sender {
    if (_index == -1 && _recordingTime == 0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirm"
                                                                       message:@"You didn't start recording yet.\nAre you sure to navigate the questions before recording?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  _index = MAX(_index - 1, 0);
                                                                  [self updateQuestionDisplay];
                                                              }];
        
        UIAlertAction* defaultAction1 = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [alert addAction:defaultAction1];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        _index = MAX(_index - 1, 0);
        [self updateQuestionDisplay];
    }
}
-(void)updateQuestionDisplay
{
    [_indexLabel setText:[NSString stringWithFormat:@"%d of %d", _index + 1, [_questionArray count] + 1]];
    
    if (_index > 0)
    {
        NSString* text = [_questionArray objectAtIndex:_index - 1];
        NSArray* arr = [text componentsSeparatedByString:@"-"];
        if ([arr[0] intValue] < 6)
            _questionLabel.text = _app.questionData[[arr[0] intValue]][[arr[1] intValue]];
        else
            _questionLabel.text = [text substringFromIndex:2];        
    }
    else
    {
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"MM-dd-yyyy"];
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        NSString* myname = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"name"];
        NSString* interviewname = [[[appDelegate.tempData objectForKey:@"vetname"] stringByAppendingString:@" "] stringByAppendingString:[appDelegate.tempData objectForKey:@"vetname_last"]];
        _questionLabel.text = [NSString stringWithFormat:@"  It is %@. I am %@ and I'm interviewing %@", [DateFormatter stringFromDate:[NSDate date]], myname, interviewname];
        
    }
}

- (void) startRecording{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    [audioSession setActive:YES error:&err];
    err = nil;
    
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [NSString stringWithFormat:@"%0.5f.m4a", now.timeIntervalSince1970];
    
    _recorderFilePath = [DOCUMENTS_FOLDER stringByAppendingPathComponent: caldate] ;
    
    NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];
    err = nil;
    _audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!_audioRecorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        _recording = NO;
        return;
    }
    
    //prepare to record
    [_audioRecorder setDelegate:self];
    [_audioRecorder prepareToRecord];
    _audioRecorder.meteringEnabled = YES;

    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        [self onRecord:_recordRecognizer];
        return;
    }
    
    // start recording
    [_audioRecorder record];
    
}

- (void) stopRecording{
    
    [_audioRecorder stop];
    
    NSURL *url = [NSURL fileURLWithPath: _recorderFilePath];
    NSError *err = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(!audioData)
        NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    
    [_files addObject:[NSURL fileURLWithPath:_recorderFilePath]];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
}

@end

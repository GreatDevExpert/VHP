//
//  VHPTagListViewController.m
//  VHP_Project
//
//  Created by Steve on 4/17/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//
#import "MFSideMenu.h"
#import "VHPNewInterviewController.h"
#import "VHPInterviewListViewController.h"
#import "VHPTagListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VHPLoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "VHPBrowseTagFilesViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface VHPTagListViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerAreaView;
@property (weak, nonatomic) IBOutlet UIButton *noteSaveButton;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIView *noteView;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property NSArray* keys, *tagFiles;
@property  MPMoviePlayerController* moviePlayer;
@property NSDictionary* draftData;
@property int index, width;
@end

@implementation VHPTagListViewController

@synthesize moviePlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_doneButton setHidden:_readOnly];
    if (_readOnly)
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    
    int height = [[UIScreen mainScreen]bounds].size.height;
    CGRect rt = _noteView.frame;
    rt.origin = CGPointMake(0, height + 1);
    _noteView.frame = rt;
    [_noteSaveButton setHidden:_readOnly];
    
    moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:_videoURL];
    moviePlayer.controlStyle =  MPMovieControlStyleDefault;
    moviePlayer.shouldAutoplay=NO;
    moviePlayer.repeatMode = NO;
    [moviePlayer setFullscreen:YES animated:NO];
    [moviePlayer prepareToPlay];

    rt = _videoPlayerAreaView.bounds;
    rt.origin = CGPointMake(0, 0);
    moviePlayer.view.frame = rt;
    [_videoPlayerAreaView addSubview:moviePlayer.view];

    _noteTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    _noteTextView.layer.cornerRadius = 5;
    _noteTextView.layer.borderWidth = 0.5;
    [_videoPlayerAreaView setBackgroundColor:[UIColor redColor]];
    
    _width = [[UIScreen mainScreen]bounds].size.width;
    _keys = [_tagList allKeys];
    _keys = [_keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber* num1 = [NSNumber numberWithInt:abs([obj1 intValue])];
        NSNumber* num2 = [NSNumber numberWithInt:abs([obj2 intValue])];
        return [num1 compare:num2];
    }];
    
    [_tagTableView reloadData];
    [self resizeTable];
    
    if ([self.timeLength intValue] == 0 && self.videoURL == nil)
    {
        [self actionSheet:nil clickedButtonAtIndex:200000];
        return;
    }
    
    if (!_tagList) _tagList = [NSMutableDictionary dictionary];
    AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
    [appDelegate.tempData setObject:_tagList forKey:@"tagList"];
    
    if (appDelegate.isTempDataForDetail == NO) {
        [[NSUserDefaults standardUserDefaults] setObject:appDelegate.tempData forKey:Draft_Interview_Data];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSaveNote:(id)sender {
    [_tagList setObject:_noteTextView.text forKey:_keys[_index]];
    
    int height = [[UIScreen mainScreen]bounds].size.height;
    __block VHPTagListViewController* selfObject = self;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rt = _noteView.frame;
        rt.origin = CGPointMake(0, height + 1);
        _noteView.frame = rt;
    } completion:^(BOOL finished) {
        [_tagTableView reloadData];
        [selfObject resizeTable];
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    }];
}

-(NSString*)getIDFromAssetURL:(NSString*)urlString
{
    NSRange range1, range2;

    range1 = [urlString rangeOfString:@"id="];
    range2 = [urlString rangeOfString:@"&ext="];
    
    NSRange rangeOfID;
    rangeOfID.location = range1.length + range1.location;
    rangeOfID.length = range2.location - rangeOfID.location;
    
    NSString* idOfString = [urlString substringWithRange:rangeOfID];
    return idOfString;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL* fileURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSURL* referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    NSString* urlString = [referenceURL absoluteString];
    NSString* idOfString = [self getIDFromAssetURL:urlString];
    
    [self selectFile:idOfString];
    
    _videoURL = fileURL;
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:fileURL];
    CMTime time = [avUrl duration];
    int seconds = ceil(time.value/time.timescale);
    self.timeLength = [NSNumber numberWithInteger:seconds];
    
    [moviePlayer setContentURL:fileURL];
    [moviePlayer play];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([_timeLength intValue] == 0 && self.videoURL == nil)
    {
        __block VHPTagListViewController* selfObject = self;
        [picker dismissViewControllerAnimated:NO completion:^{
            [selfObject.navigationController popViewControllerAnimated:NO];
        }];
    }
    else [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDone:(id)sender {
    UIActionSheet *actionsheet = [[UIActionSheet alloc]initWithTitle:@"Choose your action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Publish" otherButtonTitles:@"Save to iPhoto",  @"Delete all data", nil];
    [actionsheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) [self onUpload:nil];
    else if (buttonIndex == 1)
    {
        [SVProgressHUD showWithStatus:@"Saving..." maskType:SVProgressHUDMaskTypeGradient];
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc]init];
        
        [library saveVideo:_videoURL toAlbum:@"VHP" completion:^(NSURL *assetURL, NSError *error) {
            
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
            {
                // [[myasset defaultRepresentation] fullResolutionImage]
                // is a CGImageRef so you can process it like you would any CGImageRef to save to disk, resize, etc.
                
                NSString* urlString = [[myasset defaultRepresentation].url absoluteString];
                urlString = [self getIDFromAssetURL:urlString];
                [self saveTag:urlString];
                
            };
            
            [library assetForURL:assetURL
                           resultBlock:resultblock
                          failureBlock:^(NSError *error) {
                              NSLog(@"error couldn't get photo");
                          }];
        
            if (error == nil) {
                [SVProgressHUD showSuccessWithStatus:@"Saved"];
            }
            else
                [SVProgressHUD showErrorWithStatus:@"Saving Error"];
            
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Saving Failed"];
        }];
    }
    else if (buttonIndex == 200000)
    {
        NSLog(@"Load ");
        UIImagePickerController* controller = [[UIImagePickerController alloc]init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.mediaTypes = @[(NSString*)kUTTypeMovie];
        controller.allowsEditing = NO;
        controller.delegate = self;
        BOOL animated = ([_timeLength intValue] != 0);
        [self.navigationController presentViewController:controller animated:animated completion:nil];
    }
    else if (buttonIndex == 5)
    {
        NSLog(@"Load Tags");
        int userID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"ID"] intValue];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", userID]];

        NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.vhp'"];
        
        _tagFiles = [dirContents filteredArrayUsingPredicate:fltr];
        
        VHPBrowseTagFilesViewController* vc = (VHPBrowseTagFilesViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"browsetags"];
        vc.files = _tagFiles;
        [self.navigationController pushViewController: vc animated:YES];
    }
    else if (buttonIndex == 2)
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Delete all data" message:@"Are you sure to delete all these interview data?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = DELETE_ALL_INTERVIEW_DATA_ALERT_ID;
        [alertView show];
    }
}

-(void)onUpload:(id)sender
{
    UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"Confirmation"
                                                       message:@"After your confirmation, the data will start immediately being uploaded.\nAre you sure that you have entered all the data correctly?"
                                                      delegate:self
                                             cancelButtonTitle:@"No, let me check again"
                                             otherButtonTitles:@"Yes, I'm sure", nil];
    alertview.tag = INTERVIEW_UPLOAD_CONFIRM_QUESTION_ALERT_ID;
    [alertview show];
}

-(void)saveTag:(NSString*)filename
{
    if ([filename stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"Invalid title"];
        return;
    }
    int userID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"ID"] intValue];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", userID]];
    
    if (![fileManager fileExistsAtPath:documentsDirectory]) {
        
        [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }

    NSString* originalFileName = filename;
    filename = [filename stringByAppendingString:@".vhp"];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:filename];
  
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_tagList];
    [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    
    if (error != nil)
    {
        [SVProgressHUD showErrorWithStatus:@"Error in saving tags. Try again"];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (MUST_LOGIN_BEFORE_PUBLISHING_INTERVIEW_DIALOG == alertView.tag)
    {
        [self actionDraftEvent:buttonIndex];
        return;
    }
    
    if (alertView.tag == DELETE_ALL_INTERVIEW_DATA_ALERT_ID)
    {
        if (buttonIndex == 0) return;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"newinterview" object:nil];
        return;
    }
    
    if (alertView.tag == ENTER_TITLE_OF_TAGS_LIST_ALERT_ID)
    {
        NSString* filename = [alertView textFieldAtIndex:0].text;
        [self saveTag:filename];
    }
    
    if (alertView.tag == INTERVIEW_UPLOAD_COMPLETED)
    {
        NSArray* arrayViewControllers = [self.navigationController viewControllers];
        
        for (UIViewController* vc in arrayViewControllers)
            if ([vc isKindOfClass:[MFSideMenuContainerViewController class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
            }
    }
    
    if (alertView.tag == INTERVIEW_UPLOAD_CONFIRM_QUESTION_ALERT_ID && buttonIndex == 1)
    {
        NSDictionary* dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"];

        
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];

        AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
        if (appDelegate.tempData == nil)
            appDelegate.tempData = [[NSMutableDictionary alloc]init];
        
        NSString* text;
        int seconds = [_timeLength integerValue];
        if (seconds >= 3600)
            text = [NSString stringWithFormat:@"%d:%02d:%02d", seconds / 3600, seconds / 60 % 60, seconds % 60];
        else
            text = [NSString stringWithFormat:@"%02d:%02d", seconds / 60 % 60, seconds % 60];
        
        NSDictionary* params = @{@"mode" : @"new_interview",
                                 @"data" : appDelegate.tempData,
                                 @"tags" : _tagList,
                                 @"timelength" : text,
                                 @"userID" : dict[@"ID"]};
        
        NSData* videoData = [NSData dataWithContentsOfURL:_videoURL];
        UIImage* thumbnail = [self generateThumbImage:_videoURL];
        NSData* imageData = UIImageJPEGRepresentation(thumbnail, 1);
        
        if ([[_videoURL path] hasSuffix:@".m4a"])
        {
            UIImage* imgAudio = [UIImage imageNamed:@"bkgBlack.png"];
            imageData = UIImageJPEGRepresentation(imgAudio, 1);
        }
        
        _draftData = @{@"params" : params,
                       @"thumbnail" : imageData,
                       @"data" : videoData,
                       @"type" : [NSNumber numberWithBool:[[_videoURL path] hasSuffix:@".m4a"]]};
        
        if ([params[@"userID"] intValue] == -2)
        {
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"User unconfirmed" message:@"Please log in or create your account before publishing the interview data." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",@"I will save data offline and publish later", nil];
            alertView.tag = MUST_LOGIN_BEFORE_PUBLISHING_INTERVIEW_DIALOG;
            [alertView show];
        }
        else
            [self onPublish:nil];
    }
}

-(void)actionDraftEvent:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) ; // cancel
    else if (buttonIndex == 1)
    {
        VHPLoginViewController* vc = (VHPLoginViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"VHPLoginViewController"];
        vc.loginMode = 1;
        [self.navigationController pushViewController:vc animated:YES];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onPublish:) name:@"publish_interview" object:nil];
    }
    else if (buttonIndex == 2)
    {
        [SVProgressHUD showWithStatus:@"Saving..." maskType:SVProgressHUDMaskTypeGradient];
        [self performSelector:@selector(saveDraftOffline) withObject:nil  afterDelay:0.01];
    }
}

-(void)saveDraftOffline
{
    [[NSUserDefaults standardUserDefaults] setObject:_draftData[@"params"] forKey:@"draft_interview_params"];
    [[NSUserDefaults standardUserDefaults] setObject:_draftData[@"type"] forKey:@"draft_interview_type"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        // Path to save array data
        NSString* path;
        path = [[paths objectAtIndex:0]
                     stringByAppendingPathComponent:@"video_draft.mov"];
        if (![_draftData[@"type"] boolValue])
            path = [[paths objectAtIndex:0]
                    stringByAppendingPathComponent:@"video_draft.m4a"];
        
        NSError* error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
        
        [_draftData[@"data"] writeToFile:path atomically:YES];
        
        path = [[paths objectAtIndex:0]
                stringByAppendingPathComponent:@"draft_thumbnail.png"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
        
        [_draftData[@"thumbnail"] writeToFile:path atomically:YES];
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc]initWithTitle:@"Saved" message:@"Successfully saved the interview data offline.\nNow you can upload data anytime you get online later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"File storage address not confirmed.\nPlease contact administrator." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}
-(NSString*)jsonEncode:(id)obj
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString* jsonString;
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        jsonString = @"[]";
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

-(void)onPublish:(id)sender
{
    AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
    [appDelegate.tempData setObject:_tagList forKey:@"tagList"];
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.tempData forKey:Draft_Interview_Data];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableDictionary* tempParams = [NSMutableDictionary dictionaryWithDictionary:_draftData[@"params"]];
    [tempParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"ID"] forKey:@"userID"];

    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:NEWINTERVIEW_WEBSERVICE_URL
                                    parameters:tempParams
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         if (![[_videoURL path] hasSuffix:@".m4a"])
                             [formData appendPartWithFileData:_draftData[@"data"]
                                                         name:@"videoURL"
                                                     fileName:@"output.mov"
                                                     mimeType:@"video/mov"];
                         else
                             [formData appendPartWithFileData:_draftData[@"data"]
                                                         name:@"videoURL"
                                                     fileName:@"audio.m4a"
                                                     mimeType:@"audio/m4a"];
                         
                         [formData appendPartWithFileData:_draftData[@"thumbnail"]
                                                     name:@"thumbnail"
                                                 fileName:@"image.jpg"
                                                 mimeType:@"image/jpg"];
                     } error:nil];
    
    [request setTimeoutInterval:3600*3];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager.requestSerializer setTimeoutInterval:3600*3];
    
    [SVProgressHUD showWithStatus:@"Preparing..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Response: %@", responseObject);
                                         [SVProgressHUD dismiss];
                                         NSDictionary*dict = (NSDictionary*)responseObject;
                                         if ([@"success" isEqualToString:dict[@"result"] ])
                                         {
                                             AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
                                             [[NSUserDefaults standardUserDefaults] removeObjectForKey:Draft_Interview_Data];
                                             [[NSUserDefaults standardUserDefaults] synchronize];
                                             appDelegate.tempData = nil;
                                             
                                             UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Successfully created new interview." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                             alertView.tag = INTERVIEW_UPLOAD_COMPLETED;
                                             [alertView show];
                                             
                                             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"draft_interview_params"];
                                             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"draft_interview_type"];
                                             [[NSUserDefaults standardUserDefaults] synchronize];
                                             
                                             VHPInterviewListViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"interviewlist"];
                                             demoController.mode = 0;
                                             
                                             UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                                             NSArray *controllers = [NSArray arrayWithObject:demoController];
                                             navigationController.viewControllers = controllers;
                                             [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                                             demoController.parentVController = self.navigationController;                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"select_previous_interviews" object:nil];
                                         }
                                         else
                                         {
                                             [SVProgressHUD dismiss];
                                             [[[UIAlertView alloc]initWithTitle:@"Error" message:dict[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                         }
                                     } failure:^(AFHTTPRequestOperation *operation, NSError* error) {
                                         [SVProgressHUD dismiss];
                                         NSLog(@"%@", operation.responseString);
                                         [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network Error. Keep all the data and try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                     }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        if (totalBytesWritten < totalBytesExpectedToWrite)
            [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Uploading: %lld%%", totalBytesWritten * 100 / totalBytesExpectedToWrite] maskType:SVProgressHUDMaskTypeGradient];
        else
            [SVProgressHUD showWithStatus:@"Uploading Data..." maskType:SVProgressHUDMaskTypeGradient];
        
        
    }];

    [operation start];
}

-(UIImage *)generateThumbImage : (NSURL*)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    CGSize size = thumbnail.size;
    size.width /= (size.height / 160.0);
    size.height /= (size.height / 160.0);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    [thumbnail drawInRect: CGRectMake(0, 0, size.width, size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)onBack:(id)sender {
    CGRect rt = _noteView.frame;
    if (rt.origin.y < 100)
    {
        __block VHPTagListViewController* selfObject = self;
        int height = [[UIScreen mainScreen]bounds].size.height;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect rt = _noteView.frame;
            rt.origin = CGPointMake(0, height + 1);
            _noteView.frame = rt;
        } completion:^(BOOL finished) {
            [_tagTableView reloadData];
            [selfObject resizeTable];
            [_backButton setTitle:@"Back" forState:UIControlStateNormal];
        }];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_keys count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.contentView.clipsToBounds = YES;
    
    NSArray* views = [cell.contentView subviews];
    for (UIView* cView in views)
         [cView removeFromSuperview];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, _width, 44)];
    
    NSString* text;
    int seconds = abs([[_keys objectAtIndex:indexPath.row] intValue]) / 20;
    
    if (seconds >= 3600)
        text = [NSString stringWithFormat:@"%d:%02d:%02d", seconds / 3600, seconds / 60 % 60, seconds % 60];
    else
        text = [NSString stringWithFormat:@"%02d:%02d", seconds / 60 % 60, seconds % 60];

    [label setText:[NSString stringWithFormat:@"%d. %@", indexPath.row + 1, text]];
    [cell.contentView addSubview:label];
    
    if ([[_tagList objectForKey:[_keys objectAtIndex:indexPath.row]] length] > 0)
    {
        UIImageView* noteIcon = [[UIImageView alloc]initWithFrame:CGRectMake(_width - 40, 10, 24, 24)];
        
        if ([[_keys objectAtIndex:indexPath.row] intValue] > 0)
        {
            noteIcon.image = [UIImage imageNamed:@"notepad.png"];
        }
        else
            noteIcon.image = [UIImage imageNamed:@"quote.png"];
        
        [cell.contentView addSubview:noteIcon];
    }
 
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString* text;
    int seconds = abs([[_keys objectAtIndex:indexPath.row] intValue]) / 20;
    
    if (seconds >= 3600)
        text = [NSString stringWithFormat:@"%d:%02d:%02d", seconds / 3600, seconds / 60 % 60, seconds % 60];
    else
        text = [NSString stringWithFormat:@"%02d:%02d", seconds / 60 % 60, seconds % 60];
    
    if ([[_keys objectAtIndex:indexPath.row] intValue] > 0)
        text = [@"Enter Your Note at " stringByAppendingString:text];
    else
        text = [@"Enter Your Quote at " stringByAppendingString:text];
    
    [_noteLabel setText:text];
    _index = indexPath.row;
    _noteTextView.text = [_tagList objectForKey:[_keys objectAtIndex:indexPath.row]];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rt = _noteView.frame;
        rt.origin = CGPointMake(0, 64);
        _noteView.frame = rt;
    }];
    
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return !_readOnly;
}

-(void)selectFile:(id)data
{
    int userID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"ID"] intValue];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", userID]];;
    
    NSString* filename = [documentsDirectory stringByAppendingPathComponent:data];
    filename = [filename stringByAppendingPathExtension:@"vhp"];
    NSData* data1 = [[NSData alloc]initWithContentsOfFile:filename];
    
    if (data1 == nil)
    {
        _tagList = [[NSMutableDictionary alloc]init];
    }
    else {
        
        NSDictionary* dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data1];
        
        _tagList = [[NSMutableDictionary alloc]initWithDictionary:dict];
    }
    
    _keys = [_tagList allKeys];
    _keys = [_keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber* num1 = [NSNumber numberWithInt:abs([obj1 intValue])];
        NSNumber* num2 = [NSNumber numberWithInt:abs([obj2 intValue])];
        return [num1 compare:num2];
    }];

    [_tagTableView reloadData];
    [self resizeTable];
}

-(void)resizeTable
{
    CGRect rt = [_tagTableView frame];
    rt.size.height = [[_tagList allKeys] count] * 44;
    [_tagTableView setFrame:rt];
    rt.size.height += _videoPlayerAreaView.frame.size.height;
    [_containerScrollView setContentSize:rt.size];
}

@end

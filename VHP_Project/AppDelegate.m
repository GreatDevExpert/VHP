//
//  AppDelegate.m
//  VHP_Project
//
//  Created by Steve on 3/29/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "AppDelegate.h"
#import <Harpy.h>
#import "SVProgressHUD.h"

@interface AppDelegate () <HarpyDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SVPROGRESSHUD"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self initQuestions];
    [self initHarpy];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pause_record" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pause_record" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[Harpy sharedInstance] checkVersion];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[Harpy sharedInstance] checkVersionWeekly];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)initHarpy
{
    [[Harpy sharedInstance] setPresentingViewController:self.window.rootViewController];
    
    // (Optional) Set the Delegate to track what a user clicked on, or to use a custom UI to present your message.
    [[Harpy sharedInstance] setDelegate:self];
    
    // (Optional) The tintColor for the alertController
    [[Harpy sharedInstance] setAlertControllerTintColor:[UIColor blueColor]];
    
    // (Optional) Set the App Name for your app
    [[Harpy sharedInstance] setAppName:@"VHP"];
    [[Harpy sharedInstance] setAppID:@"1133380697"];
    
    /* (Optional) Set the Alert Type for your app
     By default, Harpy is configured to use HarpyAlertTypeOption */
    [[Harpy sharedInstance] setAlertType:HarpyAlertTypeSkip];
    
    [[Harpy sharedInstance] setDebugEnabled:true];
    
    [[Harpy sharedInstance] checkVersion];
    
}

-(void)initQuestions
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [NSString stringWithFormat:@"%0.4f", now.timeIntervalSince1970];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"question"
                                                     ofType:@"txt"];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    
    NSArray* data  = [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    NSMutableArray* element = [[NSMutableArray alloc]init];
    
    _emptyAvatar = [UIImage imageNamed:@"empty_avatar"];
    _photoCache = [[NSMutableDictionary alloc]init];
    _questionSegmentTitleArr = [[NSMutableArray alloc]init];
    _questionData = [[NSMutableArray alloc]init];
    _tempData = nil;
    
    for (int i = 0; i < [data count]; i++)
    {
        NSString* text = data[i];
        if ([text hasPrefix:@"Segment "])
            if (i == 0)
                [_questionSegmentTitleArr addObject:text];
            else
            {
                [_questionSegmentTitleArr addObject:text];
                [_questionData addObject:element];
                element = [[NSMutableArray alloc]init];
            }
            else
                [element addObject:text];
    }
    
    [_questionData addObject:element];
}

- (void)harpyDidShowUpdateDialog
{
//    [[SVProgressHUD sharedView] setHidden:YES];
    [[SVProgressHUD sharedView].superview setHidden:YES];
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidLaunchAppStore
{
    [[SVProgressHUD sharedView].superview setHidden:NO];
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidSkipVersion
{
    [[SVProgressHUD sharedView].superview setHidden:NO];
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidCancel
{
    [[SVProgressHUD sharedView].superview setHidden:NO];
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyDidDetectNewVersionWithoutAlert:(NSString *)message
{
    NSLog(@"%@", message);
}

@end

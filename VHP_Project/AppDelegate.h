//
//  AppDelegate.h
//  VHP_Project
//
//  Created by Steve on 3/29/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "constant.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property NSMutableArray* questionData;
@property NSMutableArray* questionSegmentTitleArr;

@property NSMutableDictionary* tempData, *tagList;
@property BOOL isTempDataForDetail; //current tempdata is for interview detail
@property NSURL* videoURL;
@property NSMutableDictionary* photoCache;
@property UIImage* emptyAvatar;
@property NSMutableDictionary * avatarDictionary;
@end


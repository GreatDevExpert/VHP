//
//  VHPTagListViewController.h
//  VHP_Project
//
//  Created by Steve on 4/17/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHPTagListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,UITextViewDelegate>

@property NSURL* videoURL;
@property NSMutableDictionary* tagList;
@property NSNumber* timeLength;
@property BOOL readOnly;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *tagTableView;

-(void)selectFile:(id)data;
-(void)resizeTable;
@end

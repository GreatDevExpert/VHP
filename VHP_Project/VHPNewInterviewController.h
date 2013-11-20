//
//  VHPNewInterviewController.h
//  VHP_Project
//
//  Created by Steve on 4/4/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHPNewInterviewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property BOOL readOnly, draft;
@property (weak, nonatomic) IBOutlet UITableView *formsTable;
@property (strong, nonatomic) NSMutableArray* arrayQuestions;
@property (nonatomic, strong) UINavigationController* parentVController;

- (IBAction)onStart:(id)sender;
-(void)openReorderingScreen;

@end

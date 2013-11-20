//
//  VHPManageQuestionViewController.h
//  VHP_Project
//
//  Created by Steve on 4/9/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "FormViewController.h"
#import "VHPNewInterviewController.h"
@interface VHPManageQuestionViewController : FormViewController<UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray* questionsData,*questionSegmentTitleArr;
@property NSMutableArray* selectedData;
@property VHPNewInterviewController* parentVC;
@property NSMutableArray* customQuestionData, *selectedRows;

-(void)onCheckBoxSelected:(id)sender;

@end

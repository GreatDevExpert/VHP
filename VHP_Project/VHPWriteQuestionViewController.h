//
//  VHPWriteQuestionViewController.h
//  VHP_Project
//
//  Created by Owl on 6/17/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHPNewInterviewController.h"
#import "FormViewController.h"

@interface VHPWriteQuestionViewController : FormViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property VHPNewInterviewController* parentVC;
@end

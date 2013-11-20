//
//  VHPManuscriptViewController.m
//  VHP_Project
//
//  Created by Steve on 4/8/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPManuscriptViewController.h"

@interface VHPManuscriptViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation VHPManuscriptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView = _scrollView;
    self.dateFieldTagsArray = @[@"10"];
    self.stateFieldTagsArray = @[@"4"];    
    [self refreshInterface];
    
    int width = [[UIScreen mainScreen]bounds].size.width;
    [_scrollView setContentSize:CGSizeMake(width, 1820)];
    
    [self writeEmailList:@[@"7"]];
    [self load:@"manuscript"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    if ([self save:@"manuscript"])
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

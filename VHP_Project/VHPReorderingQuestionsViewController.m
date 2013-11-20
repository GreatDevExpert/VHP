//
//  VHPReorderingQuestionsViewController.m
//  VHP_Project
//
//  Created by Owl on 12/9/15.
//  Copyright © 2015 Wei. All rights reserved.
//

#import "VHPReorderingQuestionsViewController.h"
#import "AppDelegate.h"
#import "HPReorderTableView.h"

@interface VHPReorderingQuestionsViewController () <HPReorderTableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet HPReorderTableView *mainTableView;
@property NSMutableArray* questionsData, *questionSegmentTitleArr, *selectedData, *questions;
@end

@implementation VHPReorderingQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
    _questionsData = appDelegate.questionData;
    _questionSegmentTitleArr = appDelegate.questionSegmentTitleArr;
    _selectedData = [ NSMutableArray arrayWithArray:self.vcParent.arrayQuestions];
    _questions = [NSMutableArray arrayWithArray:self.vcParent.arrayQuestions];
    [_mainTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    [_mainTableView reloadData];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_questions removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    [self.questions exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _questions.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
    }
    cell.contentView.clipsToBounds = YES;

    NSString* quText = _questions[indexPath.row];
    NSArray* arr = [quText componentsSeparatedByString:@"-"];

    UILabel*label = cell.textLabel;
    label.numberOfLines = 5;
    label.font = [UIFont fontWithName:@"Helvetica Neue Light" size:14];
    
    if ([arr[0] integerValue] < 6)
    {
        [((UILabel*)label) setText:_questionsData[[arr[0] integerValue]][[arr[1] integerValue]]];
        
    }
    else
    {
        [((UILabel*)label) setText:[quText substringFromIndex:2]];
    }
    
    return cell;
}

- (IBAction)onSortbySection:(id)sender {
    NSMutableArray* arrayQuestions = [[NSMutableArray alloc]initWithArray:_questions];
    
    [arrayQuestions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSArray* key1 = [obj1 componentsSeparatedByString:@"-"];
        NSArray* key2 = [obj2 componentsSeparatedByString:@"-"];
        
        if ([key1[0] intValue] < [key2[0] intValue]) return NSOrderedAscending;
        if ([key1[0] intValue] > [key2[0] intValue]) return NSOrderedDescending;
        if ([key1[0] intValue] < 6)
        {
            if ([key1[1] intValue] < [key2[1] intValue]) return NSOrderedAscending;
            if ([key1[1] intValue] > [key2[1] intValue]) return NSOrderedDescending;
        }
        
        return [[obj1 substringFromIndex:2] compare:[obj2 substringFromIndex:2]];
    }];
    
    _questions = arrayQuestions;
    [_mainTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDiscardChanges:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSaveReturn:(id)sender {
    self.vcParent.arrayQuestions = [NSMutableArray arrayWithArray:_questions];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveDraftInterview" object:nil];
    if (sender == nil)
        [self.navigationController popToViewController:_vcParent animated:NO];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onStart:(id)sender {
    if (![_questions count]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                       message:@"Are you sure to proceed without any questions?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  VHPNewInterviewController* parentViewcontroller = self.vcParent;
                                                                  [self onSaveReturn:nil];
                                                                  [parentViewcontroller onStart:nil];
                                                              }];
        
        [alert addAction:defaultAction];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        
        [alert addAction:noAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        VHPNewInterviewController* parentViewcontroller = self.vcParent;
        [self onSaveReturn:nil];
        [parentViewcontroller onStart:nil];
    }
}

@end

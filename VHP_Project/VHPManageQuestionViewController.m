//
//  VHPManageQuestionViewController.m
//  VHP_Project
//
//  Created by Steve on 4/9/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPManageQuestionViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "VHPReorderingQuestionsViewController.h"
#import "SVProgressHUD.h"

@interface VHPManageQuestionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *sampleLabel;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property NSMutableArray* heightArray;

@end

@implementation VHPManageQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];

    _questionsData = appDelegate.questionData;
    _questionSegmentTitleArr = appDelegate.questionSegmentTitleArr;
    _selectedData = self.parentVC.arrayQuestions;
    if (_selectedData == nil)
        _selectedData = [[NSMutableArray alloc]init];
    
    if (_customQuestionData == nil)
    {
        NSString* url = NEW_WEBSERVICE_URL;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        id userID = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"ID"];
        
        NSString* text;
        text = [_questionsData componentsJoinedByString:@"\n"];
        
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
        
        __block VHPManageQuestionViewController* selfObject = self;
        [manager GET:GETQUESTIONS_WEBSERVICE_URL parameters:@{}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response: %@", responseObject);
            [SVProgressHUD dismiss];
            NSDictionary*dict = (NSDictionary*)responseObject;
            if ([@"success" isEqualToString:dict[@"result"]])
            {
                selfObject.customQuestionData = [[NSMutableArray alloc]initWithArray:[self getCustomQuestionsFromData:dict[@"data"]]];
                
                for (id ind in _selectedRows)
                    [_selectedData addObject:[NSString stringWithFormat:@"%d-%@", 6, ind]];
                [selfObject.mainTableView reloadData];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"Loading Error"];
            }
            
        } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            [SVProgressHUD dismiss];
            [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        }];
    }
    else
    {
        for (id ind in _selectedRows)
            [_selectedData addObject:[NSString stringWithFormat:@"%d-%@", 6, ind]];
        
        [_mainTableView reloadData];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onStart:(id)sender {
    VHPNewInterviewController* parentViewcontroller = self.parentVC;
    [self onBack:nil];
    [parentViewcontroller openReorderingScreen];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 6) return [_customQuestionData count];
    return [_questionsData[section] count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 6) return @"Custom Questions";
    
    return [NSString stringWithFormat:@"%@", _questionSegmentTitleArr[section]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MAX(56, 20 + [self autoHeightQuestion:(indexPath.section < 6) ? _questionsData[indexPath.section][indexPath.row] : _customQuestionData[indexPath.row]]);
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
       
    }
    
    cell.contentView.clipsToBounds = YES;
    ((PJRCheckBox*)[cell.contentView viewWithTag:11]).parentVC = self;
    UILabel* questionLabel = ((UILabel*)[cell.contentView viewWithTag:10]);
    
    if (indexPath.section < 6)
    {
        [questionLabel setText:_questionsData[indexPath.section][indexPath.row]];
        NSString* text = [NSString stringWithFormat:@"%d-%d", (int)indexPath.section, (int)indexPath.row];
        
        [((UILabel*)[cell.contentView viewWithTag:12]) setText:text];
        if ([_selectedData indexOfObject:text] == NSNotFound)
        {
            [((PJRCheckBox*)[cell.contentView viewWithTag:11]) setCheckState:PJRCheckboxStateUnchecked];
        }
        else
            [((PJRCheckBox*)[cell.contentView viewWithTag:11]) setCheckState:PJRCheckboxStateChecked];
        
    }
    else
    {
        [questionLabel setText:_customQuestionData[indexPath.row]];
        
        NSString* text = [NSString stringWithFormat:@"%d-%@", (int)indexPath.section, _customQuestionData[(int)indexPath.row]];
        [((UILabel*)[cell.contentView viewWithTag:12]) setText:text];
        
        if ([_selectedData indexOfObject:text] == NSNotFound)
        {
            [((PJRCheckBox*)[cell.contentView viewWithTag:11]) setCheckState:PJRCheckboxStateUnchecked];
        }
        else
            [((PJRCheckBox*)[cell.contentView viewWithTag:11]) setCheckState:PJRCheckboxStateChecked];

    }

    CGRect rt = questionLabel.frame;
    rt.size.height = [self autoHeightQuestion:questionLabel.text] + 14;
    if (rt.size.height < 50) rt.size.height = 50;
    questionLabel.frame = rt;
    
    return cell;
}

-(void)onCheckBoxSelected:(id)sender
{
    PJRCheckBox* object = (PJRCheckBox*)sender;
    NSString* text = ((UILabel*)[[object superview] viewWithTag:12]).text;
    
    if ([_selectedData indexOfObject:text] != NSNotFound)
        [_selectedData removeObject:text];
    else [_selectedData addObject:text];
    
    [_mainTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString* text;
    if (indexPath.section < 6)
        text = [NSString stringWithFormat:@"%d-%d", (int)indexPath.section, (int)indexPath.row];
    else
        text = [NSString stringWithFormat:@"%d-%@", (int)indexPath.section, _customQuestionData[(int)indexPath.row]];
    
    if ([_selectedData indexOfObject:text] == NSNotFound)
    {
        [_selectedData addObject:text];
    }
    else
        [_selectedData removeObject:text];
    
    [_mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)onBack:(id)sender {
    
    _parentVC.arrayQuestions = [[NSMutableArray alloc]init];
    
    for (NSString* question in _selectedData)
    {
        NSArray* values = [question componentsSeparatedByString:@"-"];
        if ([values[0] intValue] < 6)
        {
            if ([values[1] intValue] < [_questionsData[[values[0] intValue]] count])
                [_parentVC.arrayQuestions addObject:question];
        }
        else
        {
            NSString* quest = [question substringFromIndex:2];
            if ([_customQuestionData indexOfObject:quest] != NSNotFound && [_parentVC.arrayQuestions indexOfObject:question] == NSNotFound)
                [_parentVC.arrayQuestions addObject:question];
        }
    }
    
    [_parentVC.arrayQuestions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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

    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveDraftInterview" object:nil];
    if (sender == nil)
        [self.navigationController popToViewController:_parentVC animated:NO];
    else
        [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)onSelectAll:(id)sender {
    _selectedData = [[NSMutableArray alloc]init];
    for (int i = 0; i < 6; i++)
    {
        for (int j = 0; j < [_questionsData[i] count]; j++)
            [_selectedData addObject:[NSString stringWithFormat:@"%d-%d", i, j]];
    }
    for (int i = 0; i < [_customQuestionData count]; i++)
        [_selectedData addObject:[NSString stringWithFormat:@"6-%@", _customQuestionData[i]]];
    
    [_mainTableView reloadData];
}

- (IBAction)onDeselectAll:(id)sender {
    _selectedData = [[NSMutableArray alloc]init];
    [_mainTableView reloadData];    
}

-(NSArray*)getCustomQuestionsFromData:(NSArray*)data
{
    NSMutableArray* array = [NSMutableArray array];
    for (NSDictionary* dict in data) {
        [array addObject:dict[@"post_title"]];
    }
    
    return array;
}

-(CGFloat) autoHeightQuestion:(NSString*)text
{
    CGFloat maxWidth = _mainTableView.frame.size.width - 50;
    
    CGSize size = [text sizeWithFont:_sampleLabel.font
                   constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
                       lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

@end

//
//  VHPNewInterviewController.m
//  VHP_Project
//
//  Created by Steve on 4/4/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//
#import "PPSSignatureView.h"
#import "VHPPhotoLogViewController.h"
#import "VHPNewInterviewController.h"
#import "AppDelegate.h"
#import "VHPManageQuestionViewController.h"
#import "VHPTagListViewController.h"
#import "MFSideMenu.h"
#import "VHPInterviewFormViewController.h"
#import "VHPVeteranFormViewController.h"
#import "VHPBiographyFormViewController.h"
#import "VHPCoverLetterFormViewController.h"
#import "VHPWriteQuestionViewController.h"
#import "VHPReorderingQuestionsViewController.h"
#import "SVProgressHUD.h"

@interface VHPNewInterviewController()

@property (weak, nonatomic) IBOutlet UITextField *veteranEmailAddress;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelText;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITableView *questionTable;
@property (weak, nonatomic) IBOutlet UIButton *manageQuestions;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *backbutton;
@property AppDelegate* appDelegate;

@end

@implementation VHPNewInterviewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    _arrayQuestions = [[NSMutableArray alloc]init];

    UITapGestureRecognizer* recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapScreen:)];
    recog.numberOfTapsRequired = 1;
    [recog setCancelsTouchesInView:NO];
    [_scrollView addGestureRecognizer:recog];
    int height = (int)([_arrayQuestions count] * 35 +30 + 465 + 60);
    int width = [[UIScreen mainScreen]bounds].size.width;
    [_scrollView setContentSize:CGSizeMake(width, height)];
    
    _appDelegate = [UIApplication sharedApplication].delegate;
    _manageQuestions.center = CGPointMake(width / 2 + 50, height - 40);
    
    if (_readOnly)
    {
        [_titleLabelText setText:@"Details"];
        [_startButton setTitle:@"Next >" forState:UIControlStateNormal];
        [((UITextField*)([_scrollView viewWithTag:1])) setText:_appDelegate.tempData[@"interviewtitle"]];
        [((UITextField*)([_scrollView viewWithTag:4])) setText:_appDelegate.tempData[@"emailaddress"]];
        [((UITextField*)([_scrollView viewWithTag:2])) setText:_appDelegate.tempData[@"vetname"]];
        [((UITextField*)([_scrollView viewWithTag:3])) setText:_appDelegate.tempData[@"vetname_last"]];
        _arrayQuestions = [NSMutableArray arrayWithArray:_appDelegate.tempData[@"questions"]];
        [_manageQuestions setHidden:YES];
        [_startButton setTitle:@"Tags" forState:UIControlStateNormal];
        [_menuButton setHidden:YES];
        [_backbutton setHidden:NO];
    }
    else {
        
        [_startButton setTitle:@"Record" forState:UIControlStateNormal];
    
        if (_draft)
        {
            [((UITextField*)([_scrollView viewWithTag:1])) setText:_appDelegate.tempData[@"interviewtitle"]];
            [((UITextField*)([_scrollView viewWithTag:4])) setText:_appDelegate.tempData[@"emailaddress"]];
            [((UITextField*)([_scrollView viewWithTag:2])) setText:_appDelegate.tempData[@"vetname"]];
            [((UITextField*)([_scrollView viewWithTag:3])) setText:_appDelegate.tempData[@"vetname_last"]];
            _arrayQuestions = [NSMutableArray arrayWithArray:_appDelegate.tempData[@"questions"]];
        }
    }
    
    [_startButton setImage:nil forState:UIControlStateNormal];
    [self refreshQuestions];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self textFieldDidEndEditing:nil];
    
    if (!self.readOnly) {
        if (_appDelegate.tempData) {
            [_appDelegate.tempData removeObjectForKey:@"tagList"];
            [[NSUserDefaults standardUserDefaults] setObject:_appDelegate.tempData forKey:Draft_Interview_Data];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:Draft_Interview_Data];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMenu" object:nil];
}

-(void)saveDraftInterview
{
    if (!self.readOnly) {
        [[NSUserDefaults standardUserDefaults] setObject:_appDelegate.tempData forKey:Draft_Interview_Data];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)onManageQuestions:(id)sender {
    int flag = 0;
    
    if ([((UITextField*)[_scrollView viewWithTag:2]).text length] == 0)
    {
        ((UITextField*)[_scrollView viewWithTag:2]).layer.borderWidth = 1;
        ((UITextField*)[_scrollView viewWithTag:2]).layer.borderColor = [UIColor redColor].CGColor;
        flag = 1;
    }
    
    if ([((UITextField*)[_scrollView viewWithTag:3]).text length] == 0)
    {
        ((UITextField*)[_scrollView viewWithTag:3]).layer.borderWidth = 1;
        ((UITextField*)[_scrollView viewWithTag:3]).layer.borderColor = [UIColor redColor].CGColor;
        if (!flag) flag = 2;
    }
    
    if (![self isValidEmail:_veteranEmailAddress.text])
    {
        _veteranEmailAddress.layer.borderColor = [UIColor redColor].CGColor;
        _veteranEmailAddress.layer.borderWidth = 1;
        if (!flag) flag = 3;
    }
    
    if (flag == 1)
    {
        [((UITextField*)[_scrollView viewWithTag:2]) becomeFirstResponder];
    }
    else if (flag == 2)
    {
        [((UITextField*)[_scrollView viewWithTag:3]) becomeFirstResponder];
    }
    else if (flag == 3)
    {
        [((UITextField*)[_scrollView viewWithTag:4]) becomeFirstResponder];
    }
    else {
        
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Choose an Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Select Questions" otherButtonTitles:@"Custom Questions", @"Re-order Questions", nil];
        [sheet showFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self selectQuestions];
    }
    else if (buttonIndex == 1)
    {
        [self writeQuestions];
    }
    else if (buttonIndex == 2)
    {
        [self openReorderingScreen];
    }
    else return;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveDraftInterview) name:@"SaveDraftInterview" object:nil];
    
}

-(void)openReorderingScreen
{
    VHPReorderingQuestionsViewController* vc = (VHPReorderingQuestionsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"reordering"];
    vc.vcParent = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)writeQuestions
{
    VHPWriteQuestionViewController* vc = (VHPWriteQuestionViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"writequestions"];
    vc.parentVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)selectQuestions
{
    VHPManageQuestionViewController* vc = (VHPManageQuestionViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"managequestions"];
    vc.parentVC = self;
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshQuestions];
    [_questionTable setHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SaveDraftInterview" object:nil];
}

-(void)onTapScreen:(UIGestureRecognizer*)recog
{
    NSArray* arr = [_scrollView subviews];
    for (UIView* c in arr)
    {
        [c resignFirstResponder];
    }
}

- (IBAction)onBack:(id)sender {
    
    if (self.readOnly)
    {
        [self.navigationController popViewControllerAnimated:YES];
        _appDelegate.isTempDataForDetail = NO;
        return;
    }
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _questionTable) return 1;
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _questionTable) return 0;
    if (section == 1) return 0;
    else return 30;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _questionTable) return nil;
    if(section == 0) return @"Required";

    return @"If Applicable";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _questionTable)
        return MAX(1, [_arrayQuestions count]);
    if (section == 0) return 3;
    else return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) return 0;
    return 35;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if (tableView != _questionTable)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Light" size:15];

    if (tableView == _formsTable)
    {
        switch(indexPath.row + indexPath.section * 4)
        {
            case 0:
                cell.textLabel.text = @"Biographical Data Form";
                break;
            case 1:
                cell.textLabel.text = @"Veteran's Release Form";
                break;
            case 2:
                cell.textLabel.text = @"Interviewer's Release Form";
                break;
            case 3:
                cell.textLabel.text = @"Cover Letter";
                break;
            case 4:
                cell.textLabel.text = @"Photograph Log";
                break;
            case 5:
                cell.textLabel.text = @"Manuscript Data Sheet";
                break;
        }
    }
    else
    {
        if ([_arrayQuestions count] == 0)
            cell.textLabel.text = @"    No Questions";
        else {
        NSString* key = _arrayQuestions[indexPath.row];
        NSArray* arr = [key componentsSeparatedByString:@"-"];
        
        if ([arr[0] intValue] < 6)
            cell.textLabel.text = _appDelegate.questionData[[arr[0] intValue]][[arr[1] intValue]];
        else
            cell.textLabel.text = [key substringFromIndex:2];
        }
    }
    return cell;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return !_readOnly;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag = (int)(textField.tag + 1);
    if ([_scrollView viewWithTag:tag] && [[_scrollView viewWithTag:tag] isKindOfClass:[UITextField class]])
    {
        [[_scrollView viewWithTag:tag] becomeFirstResponder];
    }
    else [textField resignFirstResponder];
    return  YES;
}

-(void)refreshQuestions
{
    CGRect rt = [_questionTable frame];
    rt.size.height = 35 * [_arrayQuestions count] + 30;
    [_questionTable setFrame:rt];
    [_questionTable reloadData];
    
    rt.size.height = rt.origin.y + rt.size.height + 80;
    rt.size.width = [UIScreen mainScreen].bounds.size.width;
    
    [(UIView*)[_scrollView viewWithTag:90] setCenter:CGPointMake(_questionTable.center.x + 50, rt.size.height - 50)];
    [_scrollView setContentSize:rt.size];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    int flag = 0;
    if ([((UITextField*)[_scrollView viewWithTag:2]).text length] == 0)
    {
        ((UITextField*)[_scrollView viewWithTag:2]).layer.borderWidth = 1;
        ((UITextField*)[_scrollView viewWithTag:2]).layer.borderColor = [UIColor redColor].CGColor;
        flag = 1;
    }
    
    if ([((UITextField*)[_scrollView viewWithTag:3]).text length] == 0)
    {
        ((UITextField*)[_scrollView viewWithTag:3]).layer.borderWidth = 1;
        ((UITextField*)[_scrollView viewWithTag:3]).layer.borderColor = [UIColor redColor].CGColor;
        if (!flag) flag = 2;
    }
    
    if (![self isValidEmail:_veteranEmailAddress.text])
    {
        _veteranEmailAddress.layer.borderColor = [UIColor redColor].CGColor;
        _veteranEmailAddress.layer.borderWidth = 1;
        if (!flag) flag = 3;
    }
    
    if (flag == 1)
    {
        [((UITextField*)[_scrollView viewWithTag:2]) becomeFirstResponder];
    }
    else if (flag == 2)
    {
        [((UITextField*)[_scrollView viewWithTag:3]) becomeFirstResponder];
    }
    else if (flag == 3)
    {
        [((UITextField*)[_scrollView viewWithTag:4]) becomeFirstResponder];
    }
    else {
        if (tableView == _questionTable)
        {
            
        }
        else {
            NSString* identifier;
            
        
            switch (indexPath.section* 4 + indexPath.row)
            {
                case 0:
                    identifier = @"biography"; break;
                case 1:
                    identifier = @"veteran"; break;
                case 2:
                    identifier = @"interviewer"; break;
                case 3:
                    identifier = @"coverletter"; break;
                case 4:
                    identifier = @"Photograph Log"; break;
                case 5:
                    identifier = @"Manuscript Data Sheet"; break;
            }
            
            UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            
            if ([identifier isEqualToString:@"interviewer"])
            {
                ((VHPInterviewFormViewController*)vc).vetName = [NSString stringWithFormat:@"%@ %@", ((UITextField*)[_scrollView viewWithTag:2]).text, ((UITextField*)[_scrollView viewWithTag:3]).text];
                ((VHPInterviewFormViewController*)vc).vetEmail = ((UITextField*)[_scrollView viewWithTag:4]).text;
            }
            else if ([identifier isEqualToString:@"biography"])
            {
                ((VHPBiographyFormViewController*)vc).vetName = [NSString stringWithFormat:@"%@ %@", ((UITextField*)[_scrollView viewWithTag:2]).text, ((UITextField*)[_scrollView viewWithTag:3]).text];
                ((VHPBiographyFormViewController*)vc).vetEmail = ((UITextField*)[_scrollView viewWithTag:4]).text;
            }
            else if ([identifier isEqualToString:@"veteran"])
            {
                ((VHPVeteranFormViewController*)vc).vetName = [NSString stringWithFormat:@"%@ %@", ((UITextField*)[_scrollView viewWithTag:2]).text, ((UITextField*)[_scrollView viewWithTag:3]).text];
                ((VHPVeteranFormViewController*)vc).vetEmail = ((UITextField*)[_scrollView viewWithTag:4]).text;
            }
            else if ([identifier isEqualToString:@"coverletter"])
            {
                ((VHPCoverLetterFormViewController*)vc).vetName = [NSString stringWithFormat:@"%@ %@", ((UITextField*)[_scrollView viewWithTag:2]).text, ((UITextField*)[_scrollView viewWithTag:3]).text];
                ((VHPCoverLetterFormViewController*)vc).vetEmail = ((UITextField*)[_scrollView viewWithTag:4]).text;
            }
            
            if ([vc isKindOfClass:[FormViewController class]])
            {
                ((FormViewController*)vc).readOnly = _readOnly;
            }
            if ([identifier isEqualToString:@"Photograph Log"])
            {
                ((VHPPhotoLogViewController*)vc).thisStoryboard = self.storyboard;
            }
            
            [self.navigationController presentViewController:vc animated:YES completion:^{
                
            }];
        }
    }
}

-(BOOL)isValidText:(UITextField*)textField
{
    if ([[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0)
        return YES;
    return NO;
}

-(BOOL)isValidEmail:(NSString*)text
{
    NSString* emailRegEx = @"[A-Za-z0-9._%+-]+@[A-Z0-9a-z.-]+\\.[A-za-z]{2,4}";
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    return [predicate evaluateWithObject:text];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag >= 2 && textField.tag <= 4)
    {
        textField.layer.borderWidth = 0;
    }
    return  YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_appDelegate.tempData == nil)
        _appDelegate.tempData = [NSMutableDictionary dictionary];
    
    [_appDelegate.tempData setObject:((UITextField*)[_scrollView viewWithTag:1]).text forKey:@"interviewtitle"];
    [_appDelegate.tempData setObject:((UITextField*)[_scrollView viewWithTag:2]).text forKey:@"vetname"];
    [_appDelegate.tempData setObject:((UITextField*)[_scrollView viewWithTag:3]).text forKey:@"vetname_last"];
    [_appDelegate.tempData setObject:((UITextField*)[_scrollView viewWithTag:4]).text forKey:@"emailaddress"];
    if (_arrayQuestions == nil)
        _arrayQuestions = [[NSMutableArray alloc]init];
    [_appDelegate.tempData setObject:_arrayQuestions forKey:@"questions"];
    
    if (!self.readOnly) {
        [[NSUserDefaults standardUserDefaults] setObject:_appDelegate.tempData forKey:Draft_Interview_Data];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)startAlert:(id)sender
{
    
    if ([self readOnly])
    {
        VHPTagListViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"taglistviewcontroller"];
        vc.videoURL = _appDelegate.videoURL;
        vc.tagList = _appDelegate.tagList;
        vc.readOnly = _readOnly;
        
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    _appDelegate.tagList = [NSMutableDictionary dictionary];
    
    if (![self isValidEmail:_veteranEmailAddress.text])
    {
        _veteranEmailAddress.layer.borderColor = [UIColor redColor].CGColor;
        _veteranEmailAddress.layer.borderWidth = 1;
        [_veteranEmailAddress becomeFirstResponder];
        return;
    }
    if (_appDelegate.tempData == nil)
        _appDelegate.tempData = [[NSMutableDictionary alloc]init];
                
    [_appDelegate.tempData setObject:((UITextField*)[_scrollView viewWithTag:1]).text forKey:@"interviewtitle"];
    [_appDelegate.tempData setObject:((UITextField*)[_scrollView viewWithTag:2]).text forKey:@"vetname"];
    [_appDelegate.tempData setObject:((UITextField*)[_scrollView viewWithTag:3]).text forKey:@"vetname_last"];
    [_appDelegate.tempData setObject:((UITextField*)[_scrollView viewWithTag:4]).text forKey:@"emailaddress"];
    if (_arrayQuestions == nil)
        _arrayQuestions = [[NSMutableArray alloc]init];
    [_appDelegate.tempData setObject:_arrayQuestions forKey:@"questions"];
    
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"recordinterview"];
    
    if (sender == nil)
        [self.navigationController pushViewController:vc animated:NO];
    else
        [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)onStart:(id)sender {
    
    NSLog(@"%@", _appDelegate.tempData);
    
    int flag = 0;
    if ([((UITextField*)[_scrollView viewWithTag:2]).text length] == 0)
    {
        ((UITextField*)[_scrollView viewWithTag:2]).layer.borderWidth = 1;
        ((UITextField*)[_scrollView viewWithTag:2]).layer.borderColor = [UIColor redColor].CGColor;
        flag = 1;
    }
    
    if ([((UITextField*)[_scrollView viewWithTag:3]).text length] == 0)
    {
        ((UITextField*)[_scrollView viewWithTag:3]).layer.borderWidth = 1;
        ((UITextField*)[_scrollView viewWithTag:3]).layer.borderColor = [UIColor redColor].CGColor;
        if (!flag) flag = 2;
    }
    
    if (![self isValidEmail:_veteranEmailAddress.text])
    {
        _veteranEmailAddress.layer.borderColor = [UIColor redColor].CGColor;
        _veteranEmailAddress.layer.borderWidth = 1;
        if (!flag) flag = 3;
    }
    
    if (flag == 1)
    {
        [((UITextField*)[_scrollView viewWithTag:2]) becomeFirstResponder];
    }
    else if (flag == 2)
    {
        [((UITextField*)[_scrollView viewWithTag:3]) becomeFirstResponder];
    }
    else if (flag == 3)
    {
        [((UITextField*)[_scrollView viewWithTag:4]) becomeFirstResponder];
    }
    
     else if (!(_appDelegate.tempData && _appDelegate.tempData[@"biography"]))
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"The biography form should be filled before going to next stage"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (!(_appDelegate.tempData && _appDelegate.tempData[@"veteran"]))
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"The veteran release form should be filled before going to next stage"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (!(_appDelegate.tempData && _appDelegate.tempData[@"interview"]))
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"The interview release form should be filled before going to next stage"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        if (![_arrayQuestions count] && !_readOnly) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                           message:@"Are you sure to proceed without any questions?"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self startAlert:sender];
                                                                  }];
            
            [alert addAction:defaultAction];
            
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:noAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else [self startAlert:sender];
    }
    
}

@end

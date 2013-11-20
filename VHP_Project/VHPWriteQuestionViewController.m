//
//  VHPWriteQuestionViewController.m
//  VHP_Project
//
//  Created by Owl on 6/17/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPWriteQuestionViewController.h"
#import "VHPManageQuestionViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "SVProgressHUD.h"


@interface VHPWriteQuestionViewController ()
@property (weak, nonatomic) IBOutlet UIView *writeView;
@property NSMutableArray* selectedRows;
@property NSMutableArray* questionsData;
@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property int flag;
@end

@implementation VHPWriteQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedRows = [[NSMutableArray alloc]init];
    _flag = 0;
    
    int height = [[UIScreen mainScreen]bounds].size.height;
    CGRect rect = _writeView.frame;
    rect.origin.y = height + 1;
    [_writeView setFrame:rect];
   
    _questionsData = [[NSMutableArray alloc]init];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    id userID = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"ID"];
    
    NSString* text;
    text = [_questionsData componentsJoinedByString:@"\n"];
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    
    __block VHPWriteQuestionViewController* selfObject = self;
    [manager GET:GETQUESTIONS_WEBSERVICE_URL parameters:@{}
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        [SVProgressHUD dismiss];
        NSDictionary*dict = (NSDictionary*)responseObject;
        if ([@"success" isEqualToString:dict[@"result"]])
        {
            selfObject.questionsData = [[NSMutableArray alloc]initWithArray:[self getCustomQuestionsFromData:dict[@"data"]]];
            
            NSLog(@"%@", _parentVC.arrayQuestions);
            for (int i = 0; i < _questionsData.count; i++)
                if ([_parentVC.arrayQuestions indexOfObject:[NSString stringWithFormat:@"6-%@", _questionsData[i]]] != NSNotFound)
                    [_selectedRows addObject:[NSString stringWithFormat:@"%d", i]];
            [selfObject.mainTableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Loading Error"];
        }
        
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", error);
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network connection problem. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }];
}

-(NSArray*)getCustomQuestionsFromData:(NSArray*)data
{
    NSMutableArray* array = [NSMutableArray array];
    for (NSDictionary* dict in data) {
        [array addObject:dict[@"post_title"]];
    }
    
    return array;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onNext:(id)sender {
    [self saveQuestions:TRUE];
    
    
}

- (IBAction)onBack:(id)sender {
    if (_writeView.frame.origin.y < 100)
    {
        int height = [[UIScreen mainScreen]bounds].size.height;
        CGRect rect = _writeView.frame;
        rect.origin.y = height + 1;
        [UIView animateWithDuration:0.25 animations:^{
            [_writeView setFrame:rect];
        }];
    }
    else [self saveQuestions:FALSE];
}

-(void)saveQuestions:(BOOL)ford
{
    if (_flag)
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        id email = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"email"];
        id userID = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"ID"];
        
        NSString* text;
        text = [_questionsData componentsJoinedByString:@"\n"];
        
        [SVProgressHUD showWithStatus:@"Saving..."  maskType:SVProgressHUDMaskTypeGradient];

        __block VHPWriteQuestionViewController* selfObject = self;
        
        if (!_questionsData || _questionsData.count == 0)
            text = @"";
        
        [manager POST:SETQUESTIONS_WEBSERVICE_URL parameters:@{ @"question_txt" : text } constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response: %@", responseObject);
            [SVProgressHUD dismiss];
            NSDictionary*dict = (NSDictionary*)responseObject;
            if ([@"success" isEqualToString:dict[@"result"]])
            {
                if (ford)
                {
                    VHPManageQuestionViewController* vc = (VHPManageQuestionViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"managequestions"];
                    vc.customQuestionData = [[NSMutableArray alloc]initWithArray:_questionsData];
                    NSMutableArray* selectedRows = [NSMutableArray array];
                    for (NSString* ind in _selectedRows)
                    {
                        [selectedRows addObject:_questionsData[ind.intValue]];
                    }
                    vc.selectedRows = selectedRows;
                    vc.parentVC = selfObject.parentVC;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    for (int i = _parentVC.arrayQuestions.count - 1; i>= 0; i--)
                    {
                        NSRange range;
                        range.location = 0; range.length = 1;
                        if ([[_parentVC.arrayQuestions[i] substringWithRange:range] isEqualToString:@"6"])
                        {
                            [_parentVC.arrayQuestions removeObjectAtIndex:i];
                        }
                    }
                    for (NSString* ind in _selectedRows)
                    {
                        [_parentVC.arrayQuestions addObject:[NSString stringWithFormat:@"6-%@", _questionsData[ind.intValue]]];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveDraftInterview" object:nil];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"Error!"];
            }
            
        } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            [SVProgressHUD dismiss];
            [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network connection problem. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        }];
    }
    else
    {
        if (ford)
        {
            VHPManageQuestionViewController* vc = (VHPManageQuestionViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"managequestions"];
            vc.parentVC = self.parentVC;
            NSMutableArray* selectedRows = [NSMutableArray array];
            for (NSString* ind in _selectedRows)
            {
                [selectedRows addObject:_questionsData[ind.intValue]];
            }
            vc.selectedRows = selectedRows;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            for (int i = _parentVC.arrayQuestions.count - 1; i>= 0; i--)
            {
                NSRange range;
                range.location = 0; range.length = 1;
                if ([[_parentVC.arrayQuestions[i] substringWithRange:range] isEqualToString:@"6"])
                {
                    [_parentVC.arrayQuestions removeObjectAtIndex:i];
                }
            }
            for (NSString* ind in _selectedRows)
            {
                [_parentVC.arrayQuestions addObject:[NSString stringWithFormat:@"6-%@", _questionsData[ind.intValue]]];
            }
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveDraftInterview" object:nil];
        }
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (IBAction)onDelete:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                   message:@"Are you sure to delete the selected questions?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSMutableArray* questions = [[NSMutableArray alloc]init];
                                                              
                                                              for (int i = 0; i < [_questionsData count]; i++)
                                                              {
                                                                  NSString* key = [NSString stringWithFormat:@"%d", i];
                                                                  
                                                                  if ([_selectedRows indexOfObject:key] == NSNotFound)
                                                                  {
                                                                      [questions addObject:_questionsData[i]];
                                                                  }
                                                                  else _flag = 1;
                                                              }
                                                              
                                                              _questionsData = [[NSMutableArray alloc]initWithArray:questions];
                                                              _selectedRows = [[NSMutableArray alloc]init];
                                                              [_mainTableView reloadData];
                                                          }];
    
    [alert addAction:defaultAction];
    
    UIAlertAction* offlineAction = [UIAlertAction actionWithTitle:@"No"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action)
                                    {
                                    }];
    
    [alert addAction:offlineAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onNewQuestion:(id)sender {
    _questionTextField.text = @"";
    
    CGRect rect = _writeView.frame;
    rect.origin.y = 65;
    
    [UIView animateWithDuration:0.25 animations:^{
        [_writeView setFrame:rect];
    }];

    [_questionTextField becomeFirstResponder];
}

- (IBAction)onAddQuestion:(id)sender {
    if ([_questionTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0)
    {
        [_questionTextField resignFirstResponder];
        [_questionsData addObject:_questionTextField.text];
        [_selectedRows addObject:[NSString stringWithFormat:@"%d", _questionsData.count - 1]];
        
        int height = [[UIScreen mainScreen]bounds].size.height;
        CGRect rect = _writeView.frame;
        rect.origin.y = height + 1;
        
        [UIView animateWithDuration:0.25 animations:^{
            [_writeView setFrame:rect];
        }];
        
        _flag = 1;
        [_mainTableView reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_questionsData count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }
    
    cell.contentView.clipsToBounds = YES;
    [((UILabel*)[cell.contentView viewWithTag:10]) setText:_questionsData[indexPath.row]];
    
    [((UILabel*)[cell.contentView viewWithTag:12]) setText:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
    
    ((PJRCheckBox*)[cell.contentView viewWithTag:11]).parentVC = self;
    
    if ([_selectedRows indexOfObject:[NSString stringWithFormat:@"%d", (int)indexPath.row]] == NSNotFound)
    {
        [((PJRCheckBox*)[cell.contentView viewWithTag:11]) setCheckState:PJRCheckboxStateUnchecked];
    }
    else
        [((PJRCheckBox*)[cell.contentView viewWithTag:11]) setCheckState:PJRCheckboxStateChecked];
    
    return cell;
}

-(void)onCheckBoxSelected:(id)sender
{
    PJRCheckBox* object = (PJRCheckBox*)sender;
    NSString* text = ((UILabel*)[[object superview] viewWithTag:12]).text;
    if ([_selectedRows indexOfObject:text] != NSNotFound)
        [_selectedRows removeObject:text];
    else
        [_selectedRows addObject:text];
    [_mainTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString* text = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    
    if ([_selectedRows indexOfObject:text] == NSNotFound)
    {
        [_selectedRows addObject:text];
    }
    else
        [_selectedRows removeObject:text];
    
    [_mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
@end

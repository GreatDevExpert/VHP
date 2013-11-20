//
//  VHPSignUpViewController.m
//  VHP_Project
//
//  Created by Steve on 3/30/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPSignUpViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "VHPLoginViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface VHPSignUpViewController()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation VHPSignUpViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer* recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapScreen:)];
    recog.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:recog];
    
    for (int i = 1; i <= 5; i++)
    {
        [((UITextField*)[self.view viewWithTag:i]) setDelegate:self];
        if ([((UITextField*)[self.view viewWithTag:i]) respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = [UIColor colorWithWhite:0.5 alpha:1];
            ((UITextField*)[self.view viewWithTag:i]).attributedPlaceholder = [[NSAttributedString alloc] initWithString:((UITextField*)[self.view viewWithTag:i]).placeholder attributes:@{NSForegroundColorAttributeName: color}];
        } else {
            NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
            // TODO: Add fall-back code to set placeholder color.
        }
    }
    
    _registerButton.layer.cornerRadius = 4;
    _backButton.layer.cornerRadius = 4;
    _containerView.layer.cornerRadius = 5;
}

-(void)onTapScreen:(UIGestureRecognizer*)recog
{
    for (int i = 1; i <= 5; i++)
        [([self.view viewWithTag:i]) resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 5)
        [_confirmField resignFirstResponder];
    else
        [[self.view viewWithTag:textField.tag + 1] becomeFirstResponder];
    
    return YES;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(BOOL)isEmail:(NSString*)text
{
    return YES;
}

-(NSString*)isSafePassword:(NSString*)password
{
    if (password.length < 6 || password.length > 20)
        return @"Password should be 6-20 characters";
    
    return nil;
}

- (IBAction)onRegister:(id)sender {
    if ([_nameField.text length] == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"No name?"];
        [_nameField becomeFirstResponder];
    }
    else if (![self isValidEmail:_emailField.text])
    {
        [SVProgressHUD showErrorWithStatus:@"Invalid E-mail Address!"];
        [_emailField becomeFirstResponder];
    }
    else if ([self isSafePassword:_passwordField.text])
    {
        [SVProgressHUD showErrorWithStatus:[self isSafePassword:_passwordField.text]];
        [_passwordField becomeFirstResponder];
    }
    else if ([_passwordField.text isEqualToString:_confirmField.text])
    {
        [self.view endEditing:YES];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                       message:@"No entities associated with this App and vhpstudentedition.com are responsible or liable in any manner for any user experiences or for any generated or posted content that you may encounter on our sites or in connection with your use of the app or site. To the fullest extent permitted by applicable laws we on behalf of our employers, employees, and families exclude and disclaim all liability for any losses and expenses of whatever nature and howsoever arising in connection with the use of the App or its associated site."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"I Agree" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  
                                                                  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                                                  manager.responseSerializer = [AFJSONResponseSerializer serializer];
                                                                  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                                                                  [SVProgressHUD showWithStatus:@"Signing up..." maskType:SVProgressHUDMaskTypeGradient];
                                                                  manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
                                                                  [manager POST:SIGNUP_WEBSERVICE_URL parameters:
                                                                   @{@"uname" : _nameField.text,
                                                                     @"uemail": _emailField.text,
                                                                     @"ucell_no" : _mobileField.text,
                                                                     @"uretype_pwd" : _passwordField.text,
                                                                     @"upwd" : _passwordField.text}
                                                                   
                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                            NSLog(@"Response: %@", responseObject);
                                                                            [SVProgressHUD dismiss];
                                                                            NSDictionary*dict = (NSDictionary*)responseObject;
                                                                            if ([dict[@"success"] boolValue] && [dict[@"id"] intValue] > 0)
                                                                            {
                                                                                
                                                                                [[[UIAlertView alloc]initWithTitle:@"Success" message:@"Successfully created your account.\nYou can log in with your new account and enjoy." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                                                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userData"];
                                                                                [[NSUserDefaults standardUserDefaults]synchronize];
                                                                                VHPLoginViewController* vc = (VHPLoginViewController*)([self backViewController]);
                                                                                [vc reloadField:@[_emailField.text, _passwordField.text]];
                                                                                [self.navigationController popViewControllerAnimated:YES];
                                                                                
                                                                            }
                                                                            else
                                                                            {
                                                                                [SVProgressHUD dismiss];
                                                                                NSLog(@"%@", dict);
                                                                                [[[UIAlertView alloc]initWithTitle:@"Error" message:dict[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                                                                
                                                                            }
                                                                        } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                                                                            [SVProgressHUD dismiss];
                                                                            NSLog(@"%@", operation.responseString);
                                                                            [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network Error! Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                                                        }];
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"Passwords don't match"];
        [_confirmField setText:@""];
        [_confirmField becomeFirstResponder];
    }
}

-(UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range    replacementString:(NSString *)string {
    if (textField != _mobileField) return YES;
    
    // All digits entered
    if (range.location == 12) {
        return NO;
    }
    
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
        return NO;
    }
    
    // Auto-add hyphen before appending 4rd or 7th digit
    if (range.length == 0 &&
        (range.location == 3 || range.location == 7)) {
        textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
        return NO;
    }
    
    // Delete hyphen when deleting its trailing digit
    if (range.length == 1 &&
        (range.location == 4 || range.location == 8))  {
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        return NO;
    }
    
    return YES;
}


@end

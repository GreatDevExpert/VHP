//
//  VHPLoginViewController.m
//  VHP_Project
//
//  Created by Steve on 3/30/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPLoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "VHPInterviewListViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "SideMenuViewController.h"
#import "VHPNewInterviewController.h"
#import "VHPSignUpViewController.h"
#import "VHPInstructionsViewController.h"

@interface VHPLoginViewController() <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property NSDictionary* draftData;

@end

@implementation VHPLoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
     
    _containerView.layer.cornerRadius = 5;
    _containerView.clipsToBounds = YES;
    _emailTextField.layer.borderWidth = 0;
    _emailTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    _emailTextField.clipsToBounds = YES;
    _passwordTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    _passwordTextField.layer.borderWidth = 0;
    _loginButton.layer.cornerRadius = 4;
    _signUpButton.layer.cornerRadius = 4;
    _loginButton.clipsToBounds = YES;
    _signUpButton.clipsToBounds = YES;
    _emailTextField.borderStyle = UITextBorderStyleNone;
    
    for (int i = 1; i <= 2; i++)
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
    
    UITapGestureRecognizer* recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapScreen:)];
    recog.numberOfTapsRequired = 1;    
    [_mainView addGestureRecognizer:recog];
    
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"];
    NSLog(@"%@", dict);
    
    if (self.loginMode == 1)
    {
        [_offlineButton setHidden:YES];
    }
    if (dict == nil || [dict[@"email"] length] == 0) return;
    
    [_emailTextField setText:dict[@"email"]];
    [_passwordTextField setText:dict[@"password"]];
    [self onLogin:nil];
}

-(void)onTapScreen:(UIGestureRecognizer*)recog
{
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == _emailTextField)
    {
        [_passwordTextField becomeFirstResponder];
    }
    else if (textField == _passwordTextField)
    {
        [_passwordTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)onCreateAccount:(id)sender {
    VHPSignUpViewController* vc = (VHPSignUpViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"signupscreen"];
    
    vc.loginMode = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onLogin:(id)sender {
    __block VHPLoginViewController* selfObject = self;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[NSUserDefaults standardUserDefaults] setObject:@"SHOWN" forKey:@"SVPROGRESSHUD"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([@"No Success" isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"Initial_Loaded"]])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@[] forKey:INTERVIEW_DATA];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:@"No Success" forKey:@"Initial_Loaded"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString: @"http://vhpstudentedition.org"]];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSDictionary* param = @{
                            @"log":_emailTextField.text,
                            @"pwd":_passwordTextField.text,
                            @"redirect_to" :@"/oauth/authorize/?response_type=code&client_id=WqEEin3HOeE8ARvV3g4WV5e2edJzbS&redirect_uri=https://vhpstudentedition.org/tkn/tkn.php",
//                            z2lOHBSMt7KBsVJrLyTagsh6R2THnl&redirect_uri=https://dev.vhpstudentedition.org/tkn/tkn.php",
//                            @"redirect_to" :@"/oauth/authorize/?response_type=code&client_id=z2lOHBSMt7KBsVJrLyTagsh6R2THnl&redirect_uri=https://vhpstudentedition.org/tkn/tkn.php",
                            @"testcookie":@0,
                            
                            @"wp-submit":@"Log In"};
//                            @"rememberme" : @"forever"};
    
    
    [manager POST:LOGIN_WEBSERVICE_URL parameters:param
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);
        [SVProgressHUD dismiss];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SVPROGRESSHUD"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDictionary*dict = (NSDictionary*)responseObject;
        if ([dict[@"result"] boolValue] && [dict[@"data"] objectForKey:@"ID"])
        {
            NSMutableDictionary* dict1 = [NSMutableDictionary dictionaryWithDictionary:dict[@"data"]];
            
            [dict1 setObject:_passwordTextField.text forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"token"] forKey:@"ACCESS_TOKEN"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[self convertDict:dict1] forKey:@"userData"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            if (selfObject.loginMode == 1)
            {
                [selfObject.navigationController popViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLeftMenu" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"publish_interview" object:nil];
            }
            else {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"draft_interview_params"] != nil) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                                        message:@"You have one draft interview data. Would you like to upload it now?"
                                                                       delegate:self
                                                              cancelButtonTitle:@"No, I will give it up"
                                                              otherButtonTitles:@"Yes, I will upload it now", nil];
                    
                    alertView.tag = DRAFT_INTERVIEW_UPLOAD_WHEN_LOGIN;
                    [alertView show];
                }
                else
                {
                    SideMenuViewController *leftMenuViewController = [selfObject.storyboard instantiateViewControllerWithIdentifier:@"sidemenu"];
                    
                    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                                    containerWithCenterViewController:[selfObject getMainNavigationController]
                                                                    leftMenuViewController:leftMenuViewController
                                                                    rightMenuViewController:nil];
                    
                    [selfObject.navigationController pushViewController:container animated:YES];
                }
            }
        }
        else
        {
            [SVProgressHUD dismiss];
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:dict[@"message"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        
        NSString* string = [NSString stringWithFormat:@"You failed to connect to VHP server"];
        
        if ([operation.response statusCode] / 100 == 2 && [operation.responseString rangeOfString:@"The password you entered for the email address"].location != NSNotFound)
        {
            string = @"Incorrect Password";
        }
        else if ([operation.response statusCode] / 100 == 2 && [operation.responseString rangeOfString:@"Invalid email address."].location != NSNotFound)
        {
            string = @"Invalid or not existing e-mail address";
        }
        else if ([operation.response statusCode] / 100 == 2)
            string = @"Failed to login!";
        
        [SVProgressHUD dismiss];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:string
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

-(void)uploadData
{
    NSDictionary* userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
    __block NSNumber* type = [[NSUserDefaults standardUserDefaults] objectForKey:@"draft_interview_type"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSData* videoData, *thumbnail;
    if ([paths count] > 0)
    {
        // Path to save array data
        NSString* pathVideo, *pathImage;
        pathVideo = [[paths objectAtIndex:0]
                stringByAppendingPathComponent:@"video_draft.mov"];
        if (![type boolValue])
            pathVideo = [[paths objectAtIndex:0]
                    stringByAppendingPathComponent:@"video_draft.m4a"];
        
        pathImage = [[paths objectAtIndex:0]
                stringByAppendingPathComponent:@"draft_thumbnail.png"];
        
        videoData = [NSData dataWithContentsOfFile:pathVideo];
        thumbnail = [NSData dataWithContentsOfFile:pathImage];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"Can't find the location"];
        return;
    }
    
    NSMutableDictionary* infoParam = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"draft_interview_params"]];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    [infoParam setObject:userData[@"ID"] forKey:@"userID"];
    
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:NEW_WEBSERVICE_URL
                                    parameters:infoParam
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         
                         if (![type boolValue]) {
                                [formData appendPartWithFileData:videoData
                                                         name:@"videoURL"
                                                     fileName:@"output.mov"
                                                     mimeType:@"video/mov"];
                         }
                         else {
                                [formData appendPartWithFileData:videoData
                                                         name:@"videoURL"
                                                     fileName:@"audio.m4a"
                                                     mimeType:@"audio/m4a"];
                         
                         }
                         
                         [formData appendPartWithFileData:thumbnail
                                                     name:@"thumbnail"
                                                 fileName:@"image.jpg"
                                                 mimeType:@"image/jpg"];
                     } error:nil];
    
    [request setTimeoutInterval:3600*3];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager.requestSerializer setTimeoutInterval:3600*3];
    
    __block id selfObject = self;
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Response: %@", responseObject);
                                         [SVProgressHUD dismiss];
                                         NSDictionary*dict = (NSDictionary*)responseObject;
                                         if ([@"success" isEqualToString:dict[@"result"] ])
                                         {
                                             UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Successfully created new interview." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                             
                                             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"draft_interview_params"];
                                             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"draft_interview_type"];
                                             [[NSUserDefaults standardUserDefaults] synchronize];
                                             
                                             [alertView show];
                                             
                                             SideMenuViewController *leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"sidemenu"];
                                             
                                             MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                                                             containerWithCenterViewController:[selfObject getMainNavigationController]
                                                                                             leftMenuViewController:leftMenuViewController
                                                                                             rightMenuViewController:nil];                                             
                                             
                                             [self.navigationController pushViewController:container animated:YES];
                                             leftMenuViewController.selectedCategory = 4;
                                             [leftMenuViewController.mainTableView reloadData];
                                         }
                                         else
                                         {
                                             [SVProgressHUD dismiss];
                                             [[[UIAlertView alloc]initWithTitle:@"Error" message:dict[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                             
                                         }
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError* error) {
                                         [SVProgressHUD dismiss];
                                         NSLog(@"%@", operation.responseString);
                                         [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network Error. Keep all the data and try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        if (totalBytesWritten < totalBytesExpectedToWrite)
            [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Uploading: %lld%%", totalBytesWritten * 100 / totalBytesExpectedToWrite] maskType:SVProgressHUDMaskTypeGradient];
        else
            [SVProgressHUD showWithStatus:@"Uploading Data..." maskType:SVProgressHUDMaskTypeGradient];
        
        
    }];
    
    // 5. Begin!
    [operation start];
    
    

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == DRAFT_INTERVIEW_UPLOAD_WHEN_LOGIN) {
        if (buttonIndex == 1)
        {
            [SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeGradient];
            [self performSelector:@selector(uploadData) withObject:nil afterDelay:0.01];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"draft_interview_params"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"draft_interview_type"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask, YES);
            
            if ([paths count] > 0)
            {
                // Path to save array data
                NSString* path;
                path = [[paths objectAtIndex:0]
                        stringByAppendingPathComponent:@"video_draft.mov"];
                if (![_draftData[@"type"] boolValue])
                    path = [[paths objectAtIndex:0]
                            stringByAppendingPathComponent:@"video_draft.m4a"];
                
                NSError* error;
                if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                    [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
                
                path = [[paths objectAtIndex:0]
                        stringByAppendingPathComponent:@"draft_thumbnail.png"];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                    [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
            }
            
            SideMenuViewController *leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"sidemenu"];
            
            MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                            containerWithCenterViewController:[self getMainNavigationController]
                                                            leftMenuViewController:leftMenuViewController
                                                            rightMenuViewController:nil];
            
            [self.navigationController pushViewController:container animated:YES];
        }
    }
}

- (IBAction)onOfflineMode:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:@{@"ID" : @"-2", @"name" : @"", @"email" : @"", @"cell_phone" : @"", @"password" : @"", @"avatar" : @"" } forKey:@"userData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SideMenuViewController *leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"sidemenu"];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:[self getOfflineMainNavigationController]
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    
    [self.navigationController pushViewController:container animated:YES];
    [SVProgressHUD dismiss];
}

-(NSDictionary*)convertDict:(NSDictionary*)dict
{
    return @{@"ID" : MAKE_VALUE(dict[@"ID"]),
             @"name": MAKE_VALUE(dict[@"display_name"]),
             @"email": MAKE_VALUE(dict[@"user_email"]),
             @"cell_phone" : MAKE_VALUE(dict[@"cell_phone"]),
             @"password" : MAKE_VALUE(dict[@"password"]),
             @"avatar" : MAKE_VALUE(dict[@"avatar"])};
}
                                
#pragma mark -
#pragma mark - Instantiating Interview List View Controller

- (UIViewController *)firstViewController {
    VHPInstructionsViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"insructions"];
    demoController.titles = @"How It Works";
    demoController.name = @"HowItWorks";
    
    return demoController;
}

- (UINavigationController *)getMainNavigationController {
    
    UINavigationController* vc =[[UINavigationController alloc]
            initWithRootViewController:[self firstViewController]];
    vc.navigationBarHidden = YES;
    return vc;
}

- (UINavigationController *)getOfflineMainNavigationController {
    
    UINavigationController* vc =[[UINavigationController alloc]
                                 initWithRootViewController:[self firstViewController]];
    vc.navigationBarHidden = YES;
    return vc;
}

-(void)reloadField:(NSArray*)loginFields
{
    _emailTextField.text = loginFields[0];
    _passwordTextField.text = loginFields[1];
}
@end


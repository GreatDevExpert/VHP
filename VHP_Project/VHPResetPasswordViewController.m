//
//  VHPResetPasswordViewController.m
//  VHP_Project
//
//  Created by Owl on 7/20/16.
//  Copyright © 2016 Jeidong. All rights reserved.
//

#import "VHPResetPasswordViewController.h"
#import "VHPLoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "VHPInterviewListViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "SideMenuViewController.h"
#import "VHPNewInterviewController.h"
#import "VHPSignUpViewController.h"


@interface VHPResetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@end

@implementation VHPResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSendLink:(id)sender {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSDictionary* param = @{@"user_login" : _emailTextField.text};
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [manager POST:RESET_WEBSERVICE_URL parameters:param
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Response: %@", responseObject);
            [SVProgressHUD dismiss];
            NSDictionary*dict = (NSDictionary*)responseObject;
            
            if ([dict[@"result"] boolValue])
            {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Result" message:dict[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alertView show];
                
            }
            else
            {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send you a password reset link. Try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alertView show];
                
            }
        } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            
            [SVProgressHUD dismiss];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send you a password reset link. Try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alertView show];
            
        }];
}


@end

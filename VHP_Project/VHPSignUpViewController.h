//
//  VHPSignUpViewController.h
//  VHP_Project
//
//  Created by Steve on 3/30/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHPSignUpViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmField;
@property int loginMode;
@end

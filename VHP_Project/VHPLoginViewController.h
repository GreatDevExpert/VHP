//
//  VHPLoginViewController.h
//  VHP_Project
//
//  Created by Steve on 3/30/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHPLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *offlineButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property int loginMode;

-(void)reloadField:(NSArray*)loginFields;

@end

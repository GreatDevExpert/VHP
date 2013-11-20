//
//  FormViewController.h
//  VHP_Project
//
//  Created by Steve on 4/7/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PJRCheckBox.h"
#import "PJRSignatureView.h"
#import "AppDelegate.h"


@interface FormViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource>

@property AppDelegate* app;
@property (nonatomic, strong)UIView* contentView;
@property BOOL readOnly;
@property NSArray* dateFieldTagsArray, *stateFieldTagsArray, *customFieldTagsArray;
@property NSDictionary *customData;

-(void)refreshInterface;
-(void)load:(NSString*)value;
-(void)onCheckBoxSelected:(id)object;
-(void)addPhoneTexts:(NSArray*)array;
-(void)writeZipCodes:(NSArray *)zipCodes;
-(void)writeEmailList:(NSArray *)emailList;
-(BOOL)checkIfImage:(UIImage *)someImage;
-(BOOL)save:(NSString*)value;
-(NSString *)encodeToBase64String:(UIImage *)image;
-(UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;

@end

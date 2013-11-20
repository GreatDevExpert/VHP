//
//  VHPPhotoDetailViewController.h
//  VHP_Project
//
//  Created by Steve on 4/8/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "FormViewController.h"
#import "VHPPhotoLogViewController.h"
@interface VHPPhotoDetailViewController : FormViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UIImage* currentImage;
@property NSString* location, *date, *descText;
@property VHPPhotoLogViewController* parentVC;
@property int selectedIndex;
@end

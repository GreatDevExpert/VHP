//
//  VHPPhotoLogViewController.h
//  VHP_Project
//
//  Created by Steve on 4/8/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "FormViewController.h"

@interface VHPPhotoLogViewController : FormViewController<UITableViewDataSource, UITableViewDelegate>
@property UIStoryboard *thisStoryboard;
-(void)updateCellWithImage:(UIImage*)image
                  location:(NSString*)location
                      date:(NSString*)date
               description:(NSString*)description;
@end

//
//  DemoViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.
//

#import <UIKit/UIKit.h>

@interface VHPInterviewListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong) UINavigationController* parentVController;

@property int mode;

@end

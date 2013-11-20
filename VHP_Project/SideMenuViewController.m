//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.
#import "SVProgressHUD.h"
#import "VHPAboutViewController.h"
#import "VHPInstructionsViewController.h"
#import "VHPProfileViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "VHPNewInterviewController.h"
#import "VHPInterviewListViewController.h"
#import <AFNetworking.h>
#import "AppDelegate.h"

@interface SideMenuViewController()

@property NSArray* labels;
@property AppDelegate* appDelegate;
@end

@implementation SideMenuViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    _appDelegate = [[UIApplication sharedApplication]delegate];

    NSDictionary* draftDict = [[NSUserDefaults standardUserDefaults] objectForKey:Draft_Interview_Data];
    _appDelegate.tempData = draftDict ? [NSMutableDictionary dictionaryWithDictionary:draftDict] : nil;
    
    _selectedCategory = 1;
    _labels = @[@"My Profile", @"How it works",@"New Interview",@"Draft Interview", @"Previous Interviews", @"About VHP App", @"Log out"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewInterview) name:@"newinterview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:@"reloadLeftMenu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPreviousInterviews) name:@"select_previous_interviews" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSideMenuOpened) name:@"sidemenu_open" object:nil];
}

-(void)onSideMenuOpened
{
    [self refreshTable];
}

-(void)selectPreviousInterviews
{
    _selectedCategory = 4;
    [self refreshTable];
}

-(void)refreshTable
{
    [self.mainTableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return 40;
    
    NSDictionary* userProfile = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"];
    
    if ([userProfile[@"ID"] intValue] == -2)
    {
        if (indexPath.row == 1 || indexPath.row == 4 || indexPath.row == 5 ) return 0;
    }
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:Draft_Interview_Data] && indexPath.row == 4)
        return 0;
    if (indexPath.row == 9) return 170;
    return 40;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (_selectedCategory == indexPath.row - 1 && _selectedCategory < 9)
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
        [(UILabel*)[cell.contentView viewWithTag:11] setTextColor:[UIColor colorWithWhite:37.0 / 255 alpha:1]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor clearColor]];
        [(UILabel*)[cell.contentView viewWithTag:11] setTextColor:[UIColor whiteColor]];
    }
    
    cell.clipsToBounds = YES;
    
    if (indexPath.row == 0 || indexPath.row == 9) {
        [(UILabel*)[cell.contentView viewWithTag:11] setText:@""];
        return cell;
    }
    
    NSDictionary* userProfile = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"];
    
    if ([userProfile[@"ID"] intValue] == -2)
    {
        if (indexPath.row == 6)
            [(UILabel*)[cell.contentView viewWithTag:11] setText:@"Go to Login Screen"];
        else [(UILabel*)[cell.contentView viewWithTag:11] setText:_labels[indexPath.row - 1]];
    }
    else
        [(UILabel*)[cell.contentView viewWithTag:11] setText:_labels[indexPath.row - 1]];

    [(UIImageView*)[cell.contentView viewWithTag:10] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%d.png", indexPath.row]]];
    return cell;
}

-(void)onNewInterview
{
    [SVProgressHUD dismiss];
    
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"newInterview"];
    _appDelegate.tempData = nil;
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:vc];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

-(void)startNewInterview
{
    _appDelegate.tempData = nil;
    _appDelegate.isTempDataForDetail = NO;
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"newInterview"];
    [SVProgressHUD dismiss];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:Draft_Interview_Data];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:vc];
    navigationController.viewControllers = controllers;
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    [self performSelector:@selector(selectDraftAfterNew) withObject:nil afterDelay:1];
}

-(void)selectDraftAfterNew
{
    _selectedCategory++;
    [self refreshTable];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int currentCategory = _selectedCategory;
    
    if (indexPath.row > 0 && indexPath.row < 9)
    {
        if (_selectedCategory == indexPath.row - 1)
        {
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            return;
        }
        
        _selectedCategory = indexPath.row - 1;
        [_mainTableView reloadData];
        switch (indexPath.row - 1)
        {
            case 0: {
                VHPProfileViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"profile"];
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:demoController];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                _appDelegate.isTempDataForDetail = NO;
                break;
            }
                
            case 1: {
                
                VHPInstructionsViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"insructions"];
                demoController.titles = @"How It Works";
                demoController.name = @"HowItWorks";
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:demoController];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                _appDelegate.isTempDataForDetail = NO;
                break;
            }
                
            case 2:  {
                
                if (![[NSUserDefaults standardUserDefaults] objectForKey:Draft_Interview_Data]) {
                    [self startNewInterview];
                    break;
                }
                NSDictionary* tempData = [[NSUserDefaults standardUserDefaults] objectForKey:Draft_Interview_Data];
                
                if ([tempData[@"vetname"] length] + [tempData[@"vetname_last"] length] + [tempData[@"emailaddress"] length] == 0)
                {
                    [self startNewInterview];
                    break;
                }
                
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                               message:@"You have a draft for an interview. \nWould you like to discard it and start new interview?"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes, I will start new interview" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [self startNewInterview];
                                                                          
                                                                      }];
                
                [alert addAction:defaultAction];
    
                UIAlertAction* offlineAction = [UIAlertAction actionWithTitle:@"No, I will keep it for now"
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:^(UIAlertAction * action)
                                                {
                                                    _selectedCategory = currentCategory;
                                                    [_mainTableView reloadData];
                                                    return;
    
                                                }];
                
                [alert addAction:offlineAction];
                [self presentViewController:alert animated:YES completion:nil];
                break;
            }
                
            case 3: {
                if (![[NSUserDefaults standardUserDefaults] objectForKey:Draft_Interview_Data]) {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                                   message:@"There is no draft interview."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                              _selectedCategory = currentCategory;
                                                                              [_mainTableView reloadData];
                                                                          }];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                
                [SVProgressHUD dismiss];
                _appDelegate.tempData = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:Draft_Interview_Data]];
                VHPNewInterviewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"newInterview"];
                vc.draft = YES;
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:vc];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                break;
            }
                
            case 4: {
                VHPInterviewListViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"interviewlist"];
                demoController.mode = 0;
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:demoController];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                demoController.parentVController = self.navigationController;
                _appDelegate.isTempDataForDetail = NO;
                break;
            }
            
            case 5: {
                VHPAboutViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"about"];
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:demoController];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                _appDelegate.isTempDataForDetail = NO;
                break;
            }
                
            case 6: {
                NSDictionary* userProfile = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"];
                
                if ([userProfile[@"ID"] intValue] == -2)
                {
                    if (indexPath.row == 6) {
                        [self performSelector:@selector(logOut:) withObject:nil afterDelay:0.1];
                        return;
                    }
                }
                _appDelegate.isTempDataForDetail = NO;
                [SVProgressHUD showWithStatus:@"Logging out..." maskType:SVProgressHUDMaskTypeGradient];
                [self performSelector:@selector(logOut:) withObject:[NSNumber numberWithInt:currentCategory] afterDelay:1];
                break;
            }
                
            case 9: {
                VHPInterviewListViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"browseinterviewlist"];
                demoController.mode = 1;
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:demoController];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                _appDelegate.isTempDataForDetail = NO;
                demoController.parentVController = self.navigationController;
                break;
            }
            case 10: {
                VHPInstructionsViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"insructions"];
                demoController.titles = @"Instructions";
                demoController.name = @"instructions";
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:demoController];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                _appDelegate.isTempDataForDetail = NO;
                break;
            }
            case 14: {
                VHPInstructionsViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"insructions"];
                demoController.titles = @"Helpful Hints";
                demoController.name = @"tips";
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:demoController];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                _appDelegate.isTempDataForDetail = NO;
                break;
            }
        }
    }
}

-(void)logOut:(NSNumber*)currentCategory
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    __block id selfObject = self;
    
    [manager GET:LOGOUT_WEBSERVICE_URL parameters:@{}
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);
        [SVProgressHUD dismiss];
        NSDictionary*dict = (NSDictionary*)responseObject;
        if ([dict[@"success"] boolValue])
        {
            [[selfObject navigationController] popToRootViewControllerAnimated:YES];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACCESS_TOKEN"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        else
        {
            [[selfObject navigationController] popToRootViewControllerAnimated:YES];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACCESS_TOKEN"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
//
//        [SVProgressHUD dismiss];
//        NSString* string = [NSString stringWithFormat:@"You failed to log out"];
//        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
//                                                                       message:string
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                              handler:^(UIAlertAction * action) {}];
//        
//        [alert addAction:defaultAction];
//        
//        [self presentViewController:alert animated:YES completion:nil];
//        _selectedCategory = [currentCategory intValue];
//        [_mainTableView reloadData];
        [[selfObject navigationController] popToRootViewControllerAnimated:YES];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACCESS_TOKEN"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

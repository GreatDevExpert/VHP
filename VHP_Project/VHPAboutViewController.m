//
//  VHPAboutViewController.m
//  VHP_Project
//
//  Created by Steve on 4/21/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//
#import "VHPInstructionsViewController.h"
#import "VHPAboutViewController.h"
#import "MFSideMenu.h"

@interface VHPAboutViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property int width;

@end

@implementation VHPAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _width = [[UIScreen mainScreen] bounds].size.width;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int realNo = 0;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.clipsToBounds = YES;
    cell.contentView.clipsToBounds = YES;
    
    NSArray* cArr = [cell.contentView subviews];
    
    for (UIView* c in cArr)
        [c removeFromSuperview];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 30, 30)];
    label.layer.cornerRadius = 15;
    label.layer.borderColor = [UIColor colorWithRed:37.0 / 255 green:37 / 255.0 blue:37.0 / 255 alpha:1].CGColor;
    label.backgroundColor = [UIColor colorWithRed:37.0 / 255 green:37 / 255.0 blue:37.0 / 255 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.layer.borderWidth = 0.5;
    label.clipsToBounds = YES;
    
    [cell.contentView addSubview:label];
    
    UIView* separator = [[UIView alloc]initWithFrame:CGRectMake(10, 39, _width, 1)];
    [separator setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1]];
    [cell.contentView addSubview:separator];
    
    NSString* text;
    
    switch ( indexPath.row )
    {
        case 0:
            text = @"Veterans History Project";
            realNo = 1;
            break;
        case 1:
            text = @"Software";
            realNo = 2;
            break;
        case 2:
            text = @"Visit Us";   //Will be hidden
            break;
        case 3:
            text = @"Disclaimer";
            realNo = 3;
            break;
        case 4:
            text = @"Partners & Sponsors"; // Will be hidden
            break;
        case 5:
            text = @"Give Us Feedback";
            realNo = 4;
            break;
    }
    
    [label setText:[NSString stringWithFormat:@"%d", realNo]];
    
    UILabel* label1 = [[UILabel alloc]initWithFrame:CGRectMake(55, 5, _width - 80, 30)];
    [label1 setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
    [label1 setText:text];
    [cell.contentView addSubview:label1];
    
    return cell;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (IBAction)onMenu:(id)sender {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2 || indexPath.row == 4) return 0;
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   
    VHPInstructionsViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"insructions"];
    NSString* text;
    
    switch (indexPath.row)
    {
        case 0:
            text = @"Veterans History Project";
            break;
        case 1:
            text = @"Software";
            break;
        case 2:
            text = @"Visit Us";
            break;
        case 3:
            text = @"Disclaimer";
            break;
        case 4:
            text = @"Partners & Sponsors";
            break;
        case 5:
            text = @"Give Us Feedback";
            break;
    }
    
    demoController.titles = text;
    demoController.name = [NSString stringWithFormat:@"about%d", indexPath.row];
    [demoController setFlag:101];
    [self.navigationController pushViewController:demoController animated:YES];
}

@end

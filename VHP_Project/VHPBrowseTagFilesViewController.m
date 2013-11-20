//
//  VHPBrowseTagFilesViewController.m
//  VHP_Project
//
//  Created by Owl on 6/23/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPBrowseTagFilesViewController.h"
#import "VHPTagListViewController.h"
#import "SVProgressHUD.h"

@interface VHPBrowseTagFilesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *fileTableView;
@property NSMutableArray* tagsCountArray;
@end

@implementation VHPBrowseTagFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *filename;
    int userID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"ID"] intValue];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    _fileTableView.allowsMultipleSelectionDuringEditing = NO;
    _tagsCountArray = [[NSMutableArray alloc]init];
    
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", userID]];
    
    for (int i = 0; i < [_files count]; i++)
    {
        filename = _files[i];
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:filename];
        NSData* data = [[NSData alloc]initWithContentsOfFile:filePath];
        NSDictionary* dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        [_tagsCountArray addObject:[NSString stringWithFormat:@"%d Tags", [[dict allKeys] count]]];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString* filename = [[_files objectAtIndex:indexPath.row] stringByAppendingString:@""];
        int userID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"ID"] intValue];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", userID]];
        
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        NSLog(@"%@", filePath);
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        
        if (error == nil)
        {
            [SVProgressHUD showSuccessWithStatus:@"Successfully Deleted"];
            NSMutableArray* files = [[NSMutableArray alloc]initWithArray:_files];
            [files removeObjectAtIndex:indexPath.row];
            _files = [[NSArray alloc]initWithArray:files];
            [_tagsCountArray removeObjectAtIndex:indexPath.row];
            [_fileTableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Deleting Failed"];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    _fileTableView.editing = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onOK:(id)sender {
    _fileTableView.editing = NO;
    NSArray* selectedFiles = [_fileTableView indexPathsForSelectedRows];
    if ([selectedFiles count] == 1)
    {
        NSIndexPath* indexPath = selectedFiles[0];
        NSArray* arr= [self.navigationController viewControllers];
        VHPTagListViewController* vc = (VHPTagListViewController*)(arr[[arr count] - 2]);
        [vc selectFile:_files[indexPath.row]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else [SVProgressHUD showErrorWithStatus:@"No chosen tag data"];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    cell.contentView.clipsToBounds = YES;
    
    NSString* filename = _files[indexPath.row];
    [((UILabel*)[cell.contentView viewWithTag:10]) setText:[filename substringToIndex:[filename length] - 4]];
    [((UILabel*)[cell.contentView viewWithTag:11]) setText:[_tagsCountArray objectAtIndex:indexPath.row]];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_files count];
}
@end

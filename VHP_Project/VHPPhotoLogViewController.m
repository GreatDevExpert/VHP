//
//  VHPPhotoLogViewController.m
//  VHP_Project
//
//  Created by Steve on 4/8/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPPhotoLogViewController.h"
#import "VHPPhotoDetailViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import <UIImageView+AFNetworking.h>
@interface VHPPhotoLogViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *photoTableView;
@property NSMutableArray* arrData;
@property AppDelegate* appDelegate;
@property int currentSelectedIndex;
@end

@implementation VHPPhotoLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = [[UIApplication sharedApplication]delegate];

    // Do any additional setup after loading the view.
    self.contentView = self.view;
    self.dateFieldTagsArray = @[@"2"];    
    [self refreshInterface];
    [_addButton setHidden:[self readOnly]];
    [self load:@"photo"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onBack:(id)sender {
    if ( [self save:@"photo"])
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MAX([_arrData count], 1);
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"photoCell";
    
    if ([_arrData count] == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NOCELL"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NOCELL"];
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([self readOnly])
            cell.textLabel.text = @"No Data";
        else
            cell.textLabel.text = @"No Data.\nPlease tap here and add more photo data";
        
        cell.textLabel.numberOfLines = 3;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    [cell.contentView viewWithTag:10].layer.borderColor = [[UIColor blackColor]CGColor];
    [cell.contentView viewWithTag:10].layer.borderWidth = 1;
    
    ((UIActivityIndicatorView*)[cell.contentView viewWithTag:956]).hidden = NO;
    [((UIActivityIndicatorView*)[cell.contentView viewWithTag:956]) startAnimating];

    __weak UIImageView * photoImage = ((UIImageView*)[cell.contentView viewWithTag:10]);
    
    if ([_arrData[indexPath.row][@"image"] isKindOfClass:[NSString class]] && [_arrData[indexPath.row][@"image"] hasPrefix:@"http"]) {
        [photoImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_arrData[indexPath.row][@"image"]]] placeholderImage:[[UIImage alloc]init] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            photoImage.image = image;
            [((UIActivityIndicatorView*)[cell.contentView viewWithTag:956]) stopAnimating];
            ((UIActivityIndicatorView*)[cell.contentView viewWithTag:956]).hidden = YES;
            NSLog(@"success image loaded");
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"failed to load image");
            [((UIActivityIndicatorView*)[cell.contentView viewWithTag:956]) stopAnimating];
            ((UIActivityIndicatorView*)[cell.contentView viewWithTag:956]).hidden = YES;
            }];
    }
    else if ([_arrData[indexPath.row][@"image"] isKindOfClass:[NSString class]])
        ((UIImageView*)[cell.contentView viewWithTag:10]).image = [self decodeBase64ToImage: _arrData[indexPath.row][@"image"]];
    else
        ((UIImageView*)[cell.contentView viewWithTag:10]).image = _arrData[indexPath.row][@"image"];
    
    
    ((UILabel*)[cell.contentView viewWithTag:11]).text = [NSString stringWithFormat:@"Location : %@", _arrData[indexPath.row][@"location"]];
    ((UILabel*)[cell.contentView viewWithTag:12]).text = [NSString stringWithFormat:@"Date : %@", _arrData[indexPath.row][@"date"]];
    ((UILabel*)[cell.contentView viewWithTag:13]).text = [NSString stringWithFormat:@"%@", _arrData[indexPath.row][@"description"]];
    [((UILabel*)[cell.contentView viewWithTag:13]) setFrame:CGRectMake(18, 101, 233, 82)];
    [((UILabel*)[cell.contentView viewWithTag:13]) sizeToFit];
    [cell.contentView viewWithTag:9].clipsToBounds = YES;
    cell.contentView.clipsToBounds = YES;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self readOnly])
        return;
    if ([_arrData count] == 0) {
        [self onAddPhoto:nil];
        return;
    }
    
    [SVProgressHUD show];
    
    VHPPhotoDetailViewController *vc = (VHPPhotoDetailViewController*)[_thisStoryboard instantiateViewControllerWithIdentifier:@"photodetail"];
     vc.parentVC = self;   
    _currentSelectedIndex = indexPath.row;
    vc.currentImage = _arrData[indexPath.row][@"image"];
    vc.date = _arrData[indexPath.row][@"date"];
    vc.location = _arrData[indexPath.row][@"location"];
    vc.descText = _arrData[indexPath.row][@"description"];
    
    [self presentViewController:vc animated:YES completion:^(void)
     {
         [SVProgressHUD dismiss];
     }];
}

-(void)updateCellWithImage:(UIImage*)image
                  location:(NSString*)location
                      date:(NSString*)date
               description:(NSString*)description
{
    if (image == nil)
        image = [[UIImage alloc] init];
    
    NSDictionary* data = @{@"image" : image, @"location" :location, @"date" : date, @"description" : description};
    
    if ([_arrData count] > _currentSelectedIndex)
        [_arrData replaceObjectAtIndex:_currentSelectedIndex withObject:data];
    else
    {
        if (_arrData == nil) _arrData = [[NSMutableArray alloc]init];
        [_arrData addObject:data];
    }
    [_photoTableView reloadData];
}

- (IBAction)onAddPhoto:(id)sender {
    [SVProgressHUD show];
    _currentSelectedIndex = [_arrData count];
    VHPPhotoDetailViewController *vc = (VHPPhotoDetailViewController*)[_thisStoryboard instantiateViewControllerWithIdentifier:@"photodetail"];
    vc.parentVC = self;
    [self presentViewController:vc animated:YES completion:^(void)
     {
         [SVProgressHUD dismiss];
     }];
}

-(BOOL)save:(NSString*)value
{
    if (self.readOnly) return YES;
    [super save:value];
    
    int count = [_arrData count];
    for (int i = 0; i < count; i++)
    {
        NSMutableDictionary* object = [[NSMutableDictionary alloc]init];
        if ([_arrData[i][@"image"] isKindOfClass:[UIImage class]])
            [object setObject:[self encodeToBase64String: _arrData[i][@"image"]] forKey:@"image"];
        [object setObject:_arrData[i][@"location"] forKey:@"location"];
        [object setObject:_arrData[i][@"description"] forKey:@"description"];
        [object setObject:_arrData[i][@"date"] forKey:@"date"];
        
        [[_appDelegate.tempData objectForKey:value] setObject:object forKey:[NSString stringWithFormat:@"%d", 3 + i]];
    }
    
    return YES;
}

-(void)load:(NSString*)value
{
    [super load:value];
    NSMutableDictionary* dict = [_appDelegate.tempData objectForKey:value];
    int count = [[dict allKeys]count];
    _arrData = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < count - 2; i++)
    {
        NSMutableDictionary* object = [[NSMutableDictionary alloc]initWithDictionary:[dict objectForKey:[NSString stringWithFormat:@"%d", 3 + i]]];
        NSString* image = [object objectForKey:@"image"];
        [_arrData addObject:@{@"image" : image, @"location" : [object objectForKey: @"location"], @"description" : [object objectForKey:@"description"], @"date" : [object objectForKey:@"date"]}];
    }
    
    [_photoTableView reloadData];
}


@end

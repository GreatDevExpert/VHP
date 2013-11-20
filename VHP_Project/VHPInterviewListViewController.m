//
//  DemoViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.
//
#import "VHPNewInterviewController.h"
#import "VHPInterviewListViewController.h"
#import "MFSideMenu.h"
#import "SBMoviePlayerController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
@interface VHPInterviewListViewController() <UIActivityItemSource>

@property (weak, nonatomic) IBOutlet UIButton *buttonNew;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property NSArray* data;
@property NSString* emptyText;
@property float width;
@property AppDelegate* appdelegate;
@property NSMutableDictionary* avatarDictionary;
@end

@implementation VHPInterviewListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_mode == 1)
        [_buttonNew setHidden:YES];
    
    _width = [[UIScreen mainScreen]bounds].size.width;
    _mainTableView.clipsToBounds = YES;
    [self setupMenuBarButtonItems];
    _appdelegate = [[UIApplication sharedApplication]delegate];
    _data = [self jsonDecode:[[NSUserDefaults standardUserDefaults]objectForKey:INTERVIEW_DATA]];
    _avatarDictionary = [NSMutableDictionary dictionary];
    _emptyText = @"Loading...";
    [_mainTableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh:nil];
}

-(void)refresh:(UIRefreshControl*)refreshControl
{
    _emptyText = @"Loading...";
    [_mainTableView reloadData];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    id temp = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"ID"];
    if (_mode == 1) temp = @"-1";
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [manager GET:MYINTERVIEWS_WEBSERVICE_URL parameters:@{}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        [refreshControl endRefreshing];

        NSDictionary*dict = (NSDictionary*)responseObject;
        if ([dict[@"result"] boolValue])
        {
            _data = dict[@"data"];
            if ([_data count] == 0) _emptyText = @"No Previous Interviews";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
                [[NSUserDefaults standardUserDefaults] setObject:[self jsonEncode:_data] forKey:INTERVIEW_DATA];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
            
            if (refreshControl == nil) {
                UIRefreshControl* refreshControl = [[UIRefreshControl alloc]init];
                [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
                [_mainTableView addSubview:refreshControl];
            }
            
            _avatarDictionary = _appdelegate.avatarDictionary;
            if (!_avatarDictionary)
                _avatarDictionary = _appdelegate.avatarDictionary = [NSMutableDictionary dictionary];
            [_mainTableView reloadData];
            [SVProgressHUD dismiss];
        }
        else
        {
            [SVProgressHUD dismiss];
            _data = @[];
            _emptyText = @"No Previous Interviews";
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                [[NSUserDefaults standardUserDefaults] setObject:[self jsonEncode:_data] forKey:INTERVIEW_DATA];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
            
            if (refreshControl == nil) {
                UIRefreshControl* refreshControl = [[UIRefreshControl alloc]init];
                [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
                [_mainTableView addSubview:refreshControl];
            }
            
            _avatarDictionary = _appdelegate.avatarDictionary;
            if (!_avatarDictionary)
                _avatarDictionary = _appdelegate.avatarDictionary = [NSMutableDictionary dictionary];
            [_mainTableView reloadData];
            [SVProgressHUD dismiss];
            
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        [refreshControl endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"Failed to load data"];
    }];
    
}
#pragma mark -
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(rightSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MAX(1, [_data count]);
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    UIView* view = [tap view];
    
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]])
        view = [view superview];
    
    if (view == nil) return;
    
    UITableViewCell* cell = (UITableViewCell*)view;
    [[cell.contentView viewWithTag:10] setHidden:NO];
    
    SBMoviePlayerController* moviePlayer = [[SBMoviePlayerController alloc] init];
    [moviePlayer setViewFrame:CGRectMake(0, 40, _width, _width)];
    [moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    NSURL* url = [NSURL URLWithString:_data[[tap view].tag - 100][@"videoURL"]];
    
    if (url == nil) {
        [SVProgressHUD showErrorWithStatus:@"Invalid URL! File not valid!"];
        return;
    }
    [moviePlayer playContentUrl:url autoPlay:YES];
    [moviePlayer.view setTag:10];
    
    if (![cell.contentView.subviews containsObject:moviePlayer.view]) {
        if ([moviePlayer.view superview]) {
            [moviePlayer.view removeFromSuperview];
        }
        [cell.contentView addSubview:moviePlayer.view];
    }
    
    [cell.contentView bringSubviewToFront:moviePlayer.view];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_data count] == 0) return _width + 190;
    id url = _data[indexPath.row][@"thumbnail"];
    NSLog(@"%@", _data[indexPath.row]);
    
    if ([url isKindOfClass:[NSString class]]) {
        if ([NSURL URLWithString:url] == nil) return 0;
    }
    else if ([_data count] > 0) return 0;
    
    return _width + 190;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [[NSUserDefaults standardUserDefaults]setObject:@"No Success" forKey:@"Initial_Loaded"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
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

    if ([_data count] == 0) {
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _width, _width)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:_emptyText];
        [cell.contentView addSubview:label];
        [[NSUserDefaults standardUserDefaults]setObject:@"Success" forKey:@"Initial_Loaded"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return cell;
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 40, _width, _width)];
    [view setBackgroundColor:[UIColor blackColor]];
    [cell.contentView addSubview:view];

    UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag:10];
    __block UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    __block UIImageView* playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnPlay.png"]];
    
    _width = [[UIScreen mainScreen]bounds].size.width;
    
    if (![cell.contentView viewWithTag:99])
    {
        UIImageView* separator = [[UIImageView alloc]initWithFrame:CGRectMake(0, _width + 220 - 2, _width, 1)];
        separator.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        separator.tag = 99;
        [cell.contentView addSubview:separator];
    }
    
    if (imageView == nil)
    {
        imageView = [[UIImageView alloc]init];
        [imageView setFrame:CGRectMake(0, 40, _width, _width)];
        [imageView setBackgroundColor:[UIColor blackColor]];
        imageView.tag = 10;
        [cell.contentView addSubview:imageView];
    }
    __block NSString* url = _data[indexPath.row][@"thumbnail"];
    if (![url isKindOfClass:[NSString class]]) url = @"s";
    
    __block NSURL* tURL = [NSURL URLWithString:url];

    if (tURL && tURL.scheme && tURL.host) {
        
        CGPoint center = view.center;
        center.y -= 40;
        [playIcon setFrame:CGRectMake(0, 0, 50, 50)];    
        [playIcon setCenter:center];
        playIcon.tag = 100 + indexPath.row;
        playIcon.hidden = NO;
        playIcon.userInteractionEnabled = YES;

        if ([_appdelegate.photoCache objectForKey:url]) {
            UIImage *image = [_appdelegate.photoCache objectForKey:url];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.backgroundColor = [UIColor blackColor];
            imageView.image = image;
            [indicator stopAnimating];
            [playIcon setHidden:NO];
        }
        else {
            CGPoint center = view.center;
            center.y -= 40;
            [playIcon setCenter:center];
            [playIcon setHidden:YES];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{

                if (tURL == nil) return;
                NSData * imageData = [NSData dataWithContentsOfURL:tURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                        imageView.backgroundColor = [UIColor blackColor];
                        imageView.image = image;
                        if (image)
                            [_appdelegate.photoCache setObject:image forKey:url];
                        
                        [indicator stopAnimating];
                        [playIcon setHidden:NO];
                    });
                });
            });
        }
        
        if ([imageView viewWithTag:90])
        {
            [[imageView viewWithTag:90] removeFromSuperview];
        }
        
        imageView.userInteractionEnabled = YES;
        
        [imageView addSubview:playIcon];
        UITapGestureRecognizer* rec3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        rec3.numberOfTapsRequired = 1;
        [playIcon addGestureRecognizer:rec3];
        
        indicator.center = playIcon.center;
        indicator.hidesWhenStopped = YES;
        [indicator setColor:[UIColor colorWithWhite:0.7 alpha:1]];
        [imageView addSubview:indicator];
        
        if (playIcon.hidden == YES)
            [indicator startAnimating];
        else [indicator stopAnimating];
    }
    UILabel* interviewTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, _width+50, _width - 40, 20)];
    
    NSDictionary* interviewData = _data[indexPath.row][@"data"];
    
    if ([_data[indexPath.row][@"data"] isKindOfClass:[NSNull class]]) interviewData = @{};
    else if ([_data[indexPath.row][@"data"] isKindOfClass:[NSString class]]) {
        NSData *data = [_data[indexPath.row][@"data"] dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (json == nil) interviewData = @{};
        else interviewData = [NSDictionary dictionaryWithDictionary:json];
    }
    
    [interviewTitleLabel setText:[NSString stringWithFormat:@"Title: %@", interviewData[@"interviewtitle"]]];
    [interviewTitleLabel setHidden:YES];
    
    UILabel* vetNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, _width+50, _width - 40, 20)];
    [vetNameLabel setText:[NSString stringWithFormat:@"Vet Name: %@ %@",interviewData[@"vetname"], interviewData[@"vetname_last"]]];
    
    UILabel* lengthLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, _width+80, _width - 40, 20)];
    [lengthLabel setText:[NSString stringWithFormat:@"Length: %@", _data[indexPath.row][@"timelength"]]];
    
    UILabel* questionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, _width+110, _width - 40, 20)];
    int length = 0;
    
    if (interviewData[@"questions"] != nil && [interviewData[@"questions"] isKindOfClass:[NSArray class]])
        length = [interviewData[@"questions"] count];
    
    [questionsLabel setText:[NSString stringWithFormat:@"Questions: %d", length]];
    
    UIFont* font = [UIFont fontWithName:@"Helvetica Light" size:16];
    [cell.contentView addSubview:interviewTitleLabel];
    [cell.contentView addSubview:lengthLabel];
    [cell.contentView addSubview:vetNameLabel];
    [cell.contentView addSubview:questionsLabel];
    
    [interviewTitleLabel setFont:font];
    [lengthLabel setFont:font];
    [vetNameLabel setFont:font];
    [questionsLabel setFont:font];
    
    
    UIImageView* avatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 24, 24)];
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    
    avatar.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    avatar.layer.borderWidth = 0.5;
    avatar.layer.cornerRadius = 12;
    avatar.clipsToBounds = YES;
    
    NSString* avatarURL = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"avatar"];
    if ([_avatarDictionary objectForKey:avatarURL] == nil)
    {
        NSLog(@"%@", avatarURL);
        dispatch_queue_t queues = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queues, ^{
            NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                __block UIImage *image = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    avatar.image = image;
                    if (image == nil)
                        image = [[UIImage alloc]init];
                    [_avatarDictionary setObject:image forKey:avatarURL];
                });
            });
        });
    }
    else
        avatar.image = [_avatarDictionary objectForKey:avatarURL];
    
    UILabel* userLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,5,_width - 120,30)];
    
    [userLabel setText:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"name"]]];
    [userLabel setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
    [cell.contentView addSubview:userLabel];
    [cell.contentView addSubview:avatar];
    
    
    UIButton *detailButton = [[UIButton alloc]initWithFrame:CGRectMake((_width + 40) / 4, _width + 145, (_width - 40) / 2, 30)];
    
    [detailButton setBackgroundColor:[UIColor colorWithRed:37.0 / 255 green:37 / 255.0 blue:37.0 / 255 alpha:1]];
    [detailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [detailButton setTitle:@"More ..." forState:UIControlStateNormal];
    [detailButton setTag:indexPath.row];
    [detailButton addTarget:self action:@selector(onMoreClicked:) forControlEvents:UIControlEventTouchUpInside];
    [detailButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
    [cell.contentView addSubview:detailButton];

    
    [[NSUserDefaults standardUserDefaults]setObject:@"Success" forKey:@"Initial_Loaded"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"Initial_Loaded"]);
    return cell;
}

-(void)deleteInterView:(int)index
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    id userID = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"ID"];
    int interviewID = [_data[index][@"ID"] intValue];

    if (_mode == 1)
        userID = @"-1";
    
    [SVProgressHUD showWithStatus:@"Processing..." maskType:SVProgressHUDMaskTypeGradient];
    [manager GET:DELETEINTERVIEW_WEBSERVICE_URL(interviewID) parameters:@{}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary*dict = (NSDictionary*)responseObject;
             
        if ([@"success" isEqualToString:dict[@"result"] ])
        {
            NSMutableArray* tempData = [[NSMutableArray alloc]initWithArray:_data];
            [tempData removeObjectAtIndex:index];
            _data = tempData;
            [_mainTableView reloadData];
            [SVProgressHUD dismiss];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self refresh:nil];
            });
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:dict[@"message"]];
            [self refresh:nil];
        }
             
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Unexpected Network Error"];
        NSLog(@"%@", error.description);
        [self refresh:nil];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag < 0)
    {
        if (buttonIndex == 0)
        {
            int tag = (alertView.tag + 1) * (-1);
            [self deleteInterView:tag];
        }
    }
    else {
        if (buttonIndex == 0)     {//Do nothing
            
        }
        else if (buttonIndex == 1) //View Details
        {
            [self onDetails:alertView];
        }
        else if (buttonIndex == 9999998) //Share - Deleted from the list
        {
            NSString* urlString = [NSString stringWithFormat:@"http://vhpstudentedition.org/detail/?value=%d", [_data[alertView.tag][@"ID"] integerValue]];
            
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
        }
        else if (buttonIndex == 9999999) //visit website - Deleted from the list
        {
            NSString* urlString = [NSString stringWithFormat:@"http://vhpstudentedition.org/detail/?value=%d", [_data[alertView.tag][@"ID"] integerValue]];

            UIActivityViewController* vc = [[UIActivityViewController alloc]initWithActivityItems:  @[[NSURL URLWithString:urlString]] applicationActivities:nil];
            
            vc.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFlickr, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypePostToFlickr];
            
            
            [self presentViewController:vc animated:YES completion:nil];
                                    
        }
        else if (buttonIndex == 2) //Delete
        {
            UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"Confirmation" message:@"Are you sure to delete this interview data?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            alertview.tag = alertView.tag * (-1) - 1;
            [alertview show];
        }
        else if (buttonIndex == 9999997)//Download video  - Deleted from the list
        {
            UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"Confirmation" message:@"Are you sure to download this video? It might be taking too much time." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            alertview.tag = alertView.tag * (-1) - 1;
            [alertview show];
        }
    }
}

-(void)onMoreClicked:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    id temp = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"ID"];
    UIAlertView *alertview;
    
    if ([_data[tag][@"userID"] intValue] == [temp intValue])
        alertview = [[UIAlertView alloc]initWithTitle:@"Choose what to do" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View Interview Details",  @"Delete this interview", nil];
    else
        alertview = [[UIAlertView alloc]initWithTitle:@"Choose what to do" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View Interview Details", nil];
    
    alertview.tag = tag;
    [alertview show];
}


-(void)onDetails:(id)sender
{
    int rowIndex = [sender tag];
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    appDelegate.tempData = [NSMutableDictionary dictionaryWithDictionary:[_data[rowIndex][@"data"] isKindOfClass:[NSDictionary class]] ? _data[rowIndex][@"data"] : [self jsonDecode:_data[rowIndex][@"data"]]];
    appDelegate.videoURL = [NSURL URLWithString:_data[rowIndex][@"videoURL"]];
    
    if ([_data[rowIndex][@"tags"] isKindOfClass:[NSDictionary class]])
        appDelegate.tagList = [NSMutableDictionary dictionaryWithDictionary:_data[rowIndex][@"tags"]];
    else
        appDelegate.tagList = [[NSMutableDictionary alloc]init];

    VHPNewInterviewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"newInterview"];
    vc.readOnly = YES;
    appDelegate.isTempDataForDetail = YES;
    [self.parentVController pushViewController:vc animated:YES];
}

- (IBAction)onNew:(id)sender {
    
    [SVProgressHUD dismiss];
    
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"newInterview"];
    AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
    appDelegate.tempData = nil;
    [self.parentVController pushViewController:vc animated:YES];
}

- (IBAction)onMenu:(id)sender {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

/************ Custom Functions ***********/
-(NSString*)jsonEncode:(id)obj
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString* jsonString;
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        jsonString = @"[]";
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

-(id)jsonDecode:(NSString*)str
{
    if (![str isKindOfClass:[NSString class]]) return [NSMutableArray array];
    NSString *jsonString = str;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return json;
}

@end

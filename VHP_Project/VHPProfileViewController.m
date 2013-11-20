//
//  VHPProfileViewController.m
//  VHP_Project
//
//  Created by Steve on 4/19/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPProfileViewController.h"
#import "MFSideMenu.h"
#import <AFNetworking/AFNetworking.h>
#import "SVProgressHUD.h"

@interface VHPProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property int loading;
@property int flag;
@property UIActivityIndicatorView* activityIndicator;

@end

@implementation VHPProfileViewController

@synthesize activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"];
    __block VHPProfileViewController* selfObject = self;
    
    _flag = _loading = 0;
    _photoImageView.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1].CGColor;
    _photoImageView.layer.borderWidth = 2;
    _photoImageView.layer.cornerRadius = _photoImageView.frame.size.width / 2;
    _photoImageView.clipsToBounds = YES;
    
    ((UITextField*)([self.view viewWithTag:1])).text = dict[@"name"];
    ((UITextField*)([self.view viewWithTag:2])).text = dict[@"email"];
    ((UITextField*)([self.view viewWithTag:3])).text = dict[@"cell_phone"];
    ((UITextField*)([self.view viewWithTag:4])).text = dict[@"password"];
    ((UITextField*)([self.view viewWithTag:4])).text = @"";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    [manager GET:GETPROFILE_WEBSERVICE_URL parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        NSDictionary* dict;
        
        if ([responseObject[@"result"] boolValue])
        {
             dict = @{@"name" : responseObject[@"data"][@"display_name"],
                      @"email" : responseObject[@"data"][@"user_login"],
                      @"cell_phone" : responseObject[@"data"][@"cell_phone"] != nil ? responseObject[@"data"][@"cell_phone"] : @"",
                      @"password" : [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"password"],
                      @"avatar" : responseObject[@"data"][@"avatar"] != nil  ? responseObject[@"data"][@"avatar"] : @""};
        }
        else {
            dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
        }
        
        ((UITextField*)([selfObject.view viewWithTag:1])).text = dict[@"name"];
        ((UITextField*)([selfObject.view viewWithTag:2])).text = dict[@"email"];
        ((UITextField*)([selfObject.view viewWithTag:3])).text = dict[@"cell_phone"];
        ((UITextField*)([selfObject.view viewWithTag:4])).text = dict[@"password"];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = _photoImageView.center;
        [_photoImageView.superview addSubview:activityIndicator];
        [activityIndicator setColor:[UIColor colorWithWhite:0.7 alpha:1]];
        [activityIndicator startAnimating];
        [activityIndicator setHidesWhenStopped:YES];

        dispatch_queue_t queues = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        NSString* avatarURL = dict[@"avatar"];
        _photoImageView.image = appDelegate.emptyAvatar;
        NSMutableDictionary* avatarDictionary = appDelegate.avatarDictionary;
        
        if (avatarDictionary == nil)
            avatarDictionary = appDelegate.avatarDictionary = [NSMutableDictionary dictionary];
        
        if (avatarDictionary[avatarURL])
        {
            _photoImageView.image = avatarDictionary[avatarURL];
            [activityIndicator setHidden:YES];
            [activityIndicator stopAnimating];
        }
        else
            dispatch_async(queues, ^{
                NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarURL]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __block UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_loading == 1) return;
                        if (imageData)
                            _photoImageView.image = image;
                        
                        [activityIndicator stopAnimating];
                        [activityIndicator setHidden:YES];
                        
                    });
                });
            });
        
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUpload:)];
        recognizer.numberOfTapsRequired = 1;
        [_photoImageView addGestureRecognizer:recognizer];
        _photoImageView.userInteractionEnabled = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
        
        ((UITextField*)([selfObject.view viewWithTag:1])).text = dict[@"name"];
        ((UITextField*)([selfObject.view viewWithTag:2])).text = dict[@"email"];
        ((UITextField*)([selfObject.view viewWithTag:3])).text = dict[@"cell_phone"];
        ((UITextField*)([selfObject.view viewWithTag:4])).text = dict[@"password"];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = _photoImageView.center;
        [_photoImageView.superview addSubview:activityIndicator];
        [activityIndicator setColor:[UIColor colorWithWhite:0.7 alpha:1]];
        [activityIndicator startAnimating];
        [activityIndicator setHidesWhenStopped:YES];
        dispatch_queue_t queues = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        NSString* avatarURL = dict[@"avatar"];
        
        _photoImageView.image = appDelegate.emptyAvatar;
        
        NSMutableDictionary* avatarDictionary = appDelegate.avatarDictionary;
        if (avatarDictionary == nil)
            avatarDictionary = appDelegate.avatarDictionary = [NSMutableDictionary dictionary];
        
        if (avatarDictionary[avatarURL])
        {
            _photoImageView.image = avatarDictionary[avatarURL];
            [activityIndicator setHidden:YES];
            [activityIndicator stopAnimating];
        }
        else
            dispatch_async(queues, ^{
                NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarURL]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __block UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_loading == 1) return;
                        if (imageData)
                            _photoImageView.image = image;
                        
                        [activityIndicator stopAnimating];
                        [activityIndicator setHidden:YES];
                        
                    });
                });
            });
        
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUpload:)];
        recognizer.numberOfTapsRequired = 1;
        [_photoImageView addGestureRecognizer:recognizer];
        _photoImageView.userInteractionEnabled = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onUpload:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Your preference"
                                message:@"You can choose an image from"
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Photo Library", @"Camera", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;

    if (buttonIndex == 2)
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else if (buttonIndex == 1)
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    else return;
    
    [self presentViewController:picker animated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag = (int)textField.tag;
    
    if ([self.view viewWithTag:tag + 1])
        [[self.view viewWithTag:tag + 1] becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)onSave:(id)sender {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userData"]];
    
    if ([((UITextField*)([self.view viewWithTag:4])).text isEqualToString:dict[@"password"]])
    {
        
    }
    else
    {
        int length = [((UITextField*)([self.view viewWithTag:4])).text length];
        if (length < 6 || length > 20)
        {
            [SVProgressHUD showErrorWithStatus:@"Password should be 6-20 characters long"];
            return;
        }
        else if (![((UITextField*)([self.view viewWithTag:4])).text isEqualToString:((UITextField*)([self.view viewWithTag:5])).text])
        {
            [SVProgressHUD showErrorWithStatus:@"Passwords don't match. Please confirm passwords"];
            return;
        }
    }
    
    [dict setObject:((UITextField*)([self.view viewWithTag:1])).text forKey:@"full_name"];
    [dict setObject:((UITextField*)([self.view viewWithTag:2])).text forKey:@"email_ws"];
    [dict setObject:((UITextField*)([self.view viewWithTag:2])).text forKey:@"name_ws"];
    [dict setObject:((UITextField*)([self.view viewWithTag:3])).text forKey:@"cell_phone_ws"];
    [dict setObject:((UITextField*)([self.view viewWithTag:4])).text forKey:@"password_ws"];

    NSData* photoData = UIImagePNGRepresentation(
                 [self imageWithImage:_photoImageView.image
                         scaledToSize:CGSizeMake(100, 100 * (_photoImageView.image.size.height / 1.0 / _photoImageView.image.size.width))]
            );

    [SVProgressHUD showWithStatus:@"Saving..." maskType:SVProgressHUDMaskTypeGradient];
    
    [manager POST:UPDATEPROFILE_WEBSERVICE_URL parameters:@{@"data" : dict} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (photoData != nil)
        [formData appendPartWithFileData:photoData
                                    name:@"avtar_ws"
                                fileName:@"image.png" mimeType:@"image/png"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary* vdict = (NSDictionary*)responseObject;
        if ([responseObject[@"result"] boolValue])
        {
            [SVProgressHUD showSuccessWithStatus:@"Successfully updated"];
            [dict setObject:vdict[@"avtar"] forKey:@"avatar"];
            
            AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
            
            if (_photoImageView.image)
                [appDelegate.avatarDictionary setObject:_photoImageView.image forKey:vdict[@"avtar"]];
            else
                [appDelegate.avatarDictionary removeObjectForKey:vdict[@"avtar"]];
            
            NSMutableDictionary* userData = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userData"]];
            
            userData[@"avatar"] = vdict[@"avtar"];
            userData[@"cell_phone"] = dict[@"cell_phone_ws"];
            userData[@"email"] = dict[@"email_ws"];
            userData[@"name"] = dict[@"full_name"];
            userData[@"password"] = dict[@"password_ws"];
            
            [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"userData"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Failed to save profile"];
        }
        
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        NSLog(@"%@", operation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Network Error! Please try again"];
    }];
}

- (IBAction)onMenu:(id)sender {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _loading = 1;
    _flag = 1;
    [activityIndicator stopAnimating];
    _photoImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

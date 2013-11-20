//
//  VHPPhotoDetailViewController.m
//  VHP_Project
//
//  Created by Steve on 4/8/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPPhotoDetailViewController.h"
#import "VHPPhotoLogViewController.h"

@interface VHPPhotoDetailViewController () <UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UITextField *locationText;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation VHPPhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _photoImageView.layer.borderWidth = 1;
    _photoImageView.layer.borderColor = [UIColor blackColor].CGColor;
    [_photoImageView setImage:_currentImage];
    [_locationText setText:_location];
    [_dateTextField setText:_date];
    [_descriptionText setText:_descText];
    _descriptionText.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    _descriptionText.layer.borderWidth = 0.5;
    _descriptionText.layer.cornerRadius = 5;
    self.dateFieldTagsArray = @[@"2"];
    [self refreshInterface];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onUpload:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Upload Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Photo Library",@"From Camera", nil] ;
    action.delegate = self;
    [action showInView:self.view];
}

#pragma mark - ActionSheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 ) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *pickerView = [[UIImagePickerController alloc]init];
            pickerView.allowsEditing = YES;
            pickerView.delegate = self;
            pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerView animated:YES completion:nil];
        }        
    }
    else if ( buttonIndex == 0 ) {
        
        UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
        pickerView.allowsEditing = YES;
        pickerView.delegate = self;
        [pickerView setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:pickerView animated:YES completion:nil];
    }
}

#pragma mark - PickerDelegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * img = [info valueForKey:UIImagePickerControllerEditedImage];
    _photoImageView.image = img;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSave:(id)sender {
    if (!_photoImageView.image) _photoImageView.image = [UIImage new];
    [_parentVC updateCellWithImage:_photoImageView.image location:_locationText.text date:_dateTextField.text description:_descriptionText.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

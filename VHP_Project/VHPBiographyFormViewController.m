//
//  VHPBiographyFormViewController.m
//  VHP_Project
//
//  Created by Steve on 4/7/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPBiographyFormViewController.h"

@interface VHPBiographyFormViewController ()

@property (weak, nonatomic) IBOutlet UIView *signatureDialog;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property PJRSignatureView* signatureView;
@property UIImageView* signatureImageView;
@end

@implementation VHPBiographyFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    int width = [[UIScreen mainScreen] bounds].size.width;
    
    [_scrollView setContentSize:CGSizeMake(width, 2550)];
    _signatureView = [[PJRSignatureView alloc]initWithFrame:CGRectMake(30, 35, width - 60, 100)];
    _signatureView.userInteractionEnabled = YES;
    [_signatureDialog addSubview:_signatureView];
    _signatureImageView = (UIImageView*)[_scrollView viewWithTag:301];
    self.contentView = _scrollView;
    _signatureView.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1]CGColor];
    _signatureView.layer.borderWidth = 1;
    _signatureView.clipsToBounds = YES;

    self.dateFieldTagsArray = [@"11,10,14,15" componentsSeparatedByString:@","];
    self.stateFieldTagsArray = @[@"4", @"9"];
    self.customFieldTagsArray = @[@"23", @"24"];
    self.customData = @{@"23": [@"E1,E2,E3,E4,E5,E6,E7,E8,E9,O1,O2,O3,O4,O5,O6,O7,O8,O9,O10,W1,W2,W3,W4,W5" componentsSeparatedByString:@","],
                        @"24": @[@"2LT/ENSIGN",@"1LT/LTJG", @"CAPT/LT", @"MAJ/LCDR", @"LT/CDR", @"COL/CAPT", @"BRIG GEN/RDML", @"MAJ GEN/RADM", @"LT GEN/VADM", @"GEN/ADM", @"Other"]};
    
    [self refreshInterface];
    
    [self addPhoneTexts:@[@"6"]];
    [self writeZipCodes:@[@"5"]];
    [self writeEmailList:@[@"7"]];
    [self load:@"biography"];
    
    ((UITextField*)[self.view viewWithTag:1]).text = _vetName;
    
    if ([((UITextField*)[self.view viewWithTag:7]).text length] == 0)
    ((UITextField*)[self.view viewWithTag:7]).text = _vetEmail;

    if ([((UITextField*)[self.view viewWithTag:6]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:6]).text = @"";

    for (int i = 251; i <= 257; i++)
    {
        ((PJRCheckBox*)[self.contentView viewWithTag:i]).parentVC = self;
    }
    
    for (int i = 261; i <= 267; i++)
    {
        ((PJRCheckBox*)[self.contentView viewWithTag:i]).parentVC = self;
    }
    
    
    for (int i = 271; i <= 278; i++)
    {
        ((PJRCheckBox*)[self.contentView viewWithTag:i]).parentVC = self;
        ((PJRCheckBox*)[self.contentView viewWithTag:i]).type = PJRCheckboxCHECKBOX;
    }
    for (int i = 293; i <= 297; i++)
    {
        ((PJRCheckBox*)[self.contentView viewWithTag:i]).parentVC = self;
        ((PJRCheckBox*)[self.contentView viewWithTag:i]).type = PJRCheckboxCHECKBOX;
    }
    
    if (((PJRCheckBox*)[self.contentView viewWithTag:257]).checkState == PJRCheckboxStateChecked)
        ((UITextField*)[self.contentView viewWithTag:13]).enabled = YES;
    else {
        ((UITextField*)[self.contentView viewWithTag:13]).enabled = NO;
        ((UITextField*)[self.contentView viewWithTag:13]).text = @"";
    }
    
    if (((PJRCheckBox*)[self.contentView viewWithTag:266]).checkState == PJRCheckboxStateChecked)
        ((UITextField*)[self.contentView viewWithTag:12]).enabled = YES;
    else {
        ((UITextField*)[self.contentView viewWithTag:12]).enabled = NO;
        ((UITextField*)[self.contentView viewWithTag:12]).text = @"";
    }
    
    if (((PJRCheckBox*)[self.contentView viewWithTag:278]).checkState == PJRCheckboxStateChecked)
    {
        ((UITextField*)[self.contentView viewWithTag:18]).enabled = YES;
    }
    else
    {
        ((UITextField*)[self.contentView viewWithTag:18]).enabled = NO;
        ((UITextField*)[self.contentView viewWithTag:18]).text = @"";
    }
    
    if (((PJRCheckBox*)[self.contentView viewWithTag:297]).checkState == PJRCheckboxStateChecked)
    {
        ((UITextField*)[self.contentView viewWithTag:21]).enabled = YES;
    }
    else
    {
        ((UITextField*)[self.contentView viewWithTag:21]).enabled = NO;
        ((UITextField*)[self.contentView viewWithTag:21]).text = @"";
    }
    
    if ([((UITextField*)[self.contentView viewWithTag:24]).text isEqualToString:@"Other"])
    {
        ((UITextField*)[self.contentView viewWithTag:16]).enabled = YES;
    }
    else
    {
        ((UITextField*)[self.contentView viewWithTag:16]).enabled = NO;
        ((UITextField*)[self.contentView viewWithTag:16]).text = @"";
    }
    
    width = [[UIScreen mainScreen]bounds].size.width;
    int height = [[UIScreen mainScreen]bounds].size.height;
    [_scrollView setFrame:CGRectMake(0, 64, width, height - 64)];
    
    for (UIView* view in [_scrollView subviews])
    {
        if ([view isKindOfClass:[UITextField class]] && !view.hidden)
        {
            ((UITextField*)view).delegate = self;
        }
    }
    
}

-(void)onCheckBoxSelected:(id)object1
{    
    [super onCheckBoxSelected:object1];
    
    int grouptag = (int)([object1 tag] / 10 * 10);
    
    if ([object1 tag] == 257)
    {
        ((UITextField*)[self.contentView viewWithTag:13]).enabled = YES;
    }
    else if (grouptag == 250)
    {
        ((UITextField*)[self.contentView viewWithTag:13]).enabled = NO;
    }
    else if ([object1 tag] == 266)
    {
        ((UITextField*)[self.contentView viewWithTag:12]).enabled = YES;
    }
    else if (grouptag == 260)
        ((UITextField*)[self.contentView viewWithTag:12]).enabled = NO;
    
    else if ([object1 tag] == 278 &&((PJRCheckBox*)object1).checkState == PJRCheckboxStateChecked)
    {
        ((UITextField*)[self.contentView viewWithTag:18]).enabled = YES;
    }
    else if ([object1 tag] == 278 &&((PJRCheckBox*)object1).checkState != PJRCheckboxStateChecked)
    {
        ((UITextField*)[self.contentView viewWithTag:18]).enabled = NO;
    }
    else if ([object1 tag] == 297 &&((PJRCheckBox*)object1).checkState == PJRCheckboxStateChecked)
    {
        ((UITextField*)[self.contentView viewWithTag:21]).enabled = YES;
    }
    else if ([object1 tag] == 297 &&((PJRCheckBox*)object1).checkState != PJRCheckboxStateChecked)
    {
        ((UITextField*)[self.contentView viewWithTag:21]).enabled = NO;
    }
    else if ([object1 tag] == 291 &&((PJRCheckBox*)object1).checkState == PJRCheckboxStateChecked)
    {
        ((UITextField*)[self.contentView viewWithTag:16]).enabled = YES;
    }
    else if ([object1 tag] >= 281 && [object1 tag] < 291 &&((PJRCheckBox*)object1).checkState == PJRCheckboxStateChecked)
    {
        ((UITextField*)[self.contentView viewWithTag:16]).enabled = NO;
    }

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
    CGRect rt = [_signatureDialog frame];
    
    if (rt.origin.y <= 200)
    {
        int height = [[UIScreen mainScreen] bounds].size.height;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect rt = _signatureDialog.frame;
            
            rt.origin.y = height;
            [_signatureDialog setFrame:rt];
        }];
        
        _signatureImageView.image=[_signatureView getSignatureImage];
    }
    else
    {
        if (((PJRCheckBox*)[self.contentView viewWithTag:278]).checkState == PJRCheckboxStateChecked)
        {
            ((UITextField*)[self.contentView viewWithTag:18]).enabled = YES;
        }
        else
        {
            ((UITextField*)[self.contentView viewWithTag:18]).enabled = NO;
            ((UITextField*)[self.contentView viewWithTag:18]).text = @"";
        }
        
        if (((PJRCheckBox*)[self.contentView viewWithTag:297]).checkState == PJRCheckboxStateChecked)
        {
            ((UITextField*)[self.contentView viewWithTag:21]).enabled = YES;
        }
        else
        {
            ((UITextField*)[self.contentView viewWithTag:21]).enabled = NO;
            ((UITextField*)[self.contentView viewWithTag:21]).text = @"";
        }
        
        if (((PJRCheckBox*)[self.contentView viewWithTag:291]).checkState == PJRCheckboxStateChecked)
        {
            ((UITextField*)[self.contentView viewWithTag:16]).enabled = YES;
        }
        else
        {
            ((UITextField*)[self.contentView viewWithTag:16]).enabled = NO;
            ((UITextField*)[self.contentView viewWithTag:16]).text = @"";
        }
        
        if ([self confirmDetails] && [self save:@"biography"])
            [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(BOOL)isEmpty:(NSString*)string
{
    if ([string stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) return YES;
    
    return NO;
}

-(BOOL)confirmDetails
{
    if (self.readOnly) return YES;
    
    int firstTag = 0;
    
    for (int i = 2; i <= 10; i++)
    {
        if ([self isEmpty:((UITextField*)[self.view viewWithTag:i]).text])
        {
            if (!firstTag) firstTag = i;
            [self.view viewWithTag:i].layer.borderColor = [UIColor redColor].CGColor;
            [self.view viewWithTag:i].layer.borderWidth = 1;
        }
        else  {
            [self.view viewWithTag:i].layer.borderColor = [UIColor redColor].CGColor;
            [self.view viewWithTag:i].layer.borderWidth = 0;
        }
    }
    
    NSDateFormatter* dateFormatter=  [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSDate* birthDate = [dateFormatter dateFromString:((UITextField*)[self.view viewWithTag:10]).text];
    NSDate* currentDate = [NSDate date];
    NSTimeInterval diff = [currentDate timeIntervalSinceDate:birthDate];
    
    if (diff >= 3600 * 24 * 365 * 18 + 4) {}
    else {
        [self.view viewWithTag:10].layer.borderColor = [UIColor redColor].CGColor;
        [self.view viewWithTag:10].layer.borderWidth = 1;
        if (!firstTag) firstTag = 10;
    }
        
    
    if (((PJRCheckBox*)[_scrollView viewWithTag:211]).checkState == PJRCheckboxStateChecked || ((PJRCheckBox*)[_scrollView viewWithTag:212]).checkState == PJRCheckboxStateChecked) {
        ((PJRCheckBox*)[_scrollView viewWithTag:211]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:212]).strokeColor = [UIColor blackColor];
        [((PJRCheckBox*)[_scrollView viewWithTag:211]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:211]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:212]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:212]).checkState];
    }
    else
    {
        ((PJRCheckBox*)[_scrollView viewWithTag:211]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:212]).strokeColor = [UIColor redColor];
        [((PJRCheckBox*)[_scrollView viewWithTag:211]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:212]) setCheckState:PJRCheckboxStateUnchecked];
        if (!firstTag) firstTag = 211;
    }
    
    if (((PJRCheckBox*)[_scrollView viewWithTag:221]).checkState == PJRCheckboxStateChecked || ((PJRCheckBox*)[_scrollView viewWithTag:222]).checkState == PJRCheckboxStateChecked || ((PJRCheckBox*)[_scrollView viewWithTag:223]).checkState == PJRCheckboxStateChecked) {
        ((PJRCheckBox*)[_scrollView viewWithTag:221]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:223]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:222]).strokeColor = [UIColor blackColor];
        
        [((PJRCheckBox*)[_scrollView viewWithTag:221]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:221]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:223]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:223]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:222]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:222]).checkState];
    }
    else
    {
        ((PJRCheckBox*)[_scrollView viewWithTag:221]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:223]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:222]).strokeColor = [UIColor redColor];
        
        [((PJRCheckBox*)[_scrollView viewWithTag:221]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:223]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:222]) setCheckState:PJRCheckboxStateUnchecked];
        
        if (!firstTag) firstTag = 221;
    }
    
    
    if (((PJRCheckBox*)[_scrollView viewWithTag:251]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:252]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:253]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:254]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:255]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:256]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:257]).checkState == PJRCheckboxStateChecked) {
        ((PJRCheckBox*)[_scrollView viewWithTag:251]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:252]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:254]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:255]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:256]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:257]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:253]).strokeColor = [UIColor blackColor];
        
        [((PJRCheckBox*)[_scrollView viewWithTag:251]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:251]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:252]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:252]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:253]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:253]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:254]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:254]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:255]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:255]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:256]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:256]).checkState];
        [((PJRCheckBox*)[_scrollView viewWithTag:257]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:257]).checkState];
    }
    else
    {
        ((PJRCheckBox*)[_scrollView viewWithTag:251]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:252]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:254]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:255]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:256]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:257]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:253]).strokeColor = [UIColor redColor];
        
        [((PJRCheckBox*)[_scrollView viewWithTag:251]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:252]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:253]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:254]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:255]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:256]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:257]) setCheckState:PJRCheckboxStateUnchecked];
        
        if (!firstTag) firstTag = 251;
    }
    
    for (int i = 14; i <= 17; i++)
    {
        if (i == 16) continue;
        
        if ([self isEmpty:((UITextField*)[self.view viewWithTag:i]).text])
        {
            if (!firstTag) firstTag = i;
            [self.view viewWithTag:i].layer.borderColor = [UIColor redColor].CGColor;
            [self.view viewWithTag:i].layer.borderWidth = 1;
        }
        else {
            [self.view viewWithTag:i].layer.borderColor = [UIColor redColor].CGColor;
            [self.view viewWithTag:i].layer.borderWidth = 0;
        }
    }
    
    if (((PJRCheckBox*)[_scrollView viewWithTag:271]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:272]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:273]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:274]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:275]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:276]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:278]).checkState == PJRCheckboxStateChecked ||
        ((PJRCheckBox*)[_scrollView viewWithTag:277]).checkState == PJRCheckboxStateChecked) {
        for (int i = 271; i<= 278; i++)
        {
            ((PJRCheckBox*)[_scrollView viewWithTag:i]).strokeColor = [UIColor blackColor];
            [((PJRCheckBox*)[_scrollView viewWithTag:i]) setCheckState:((PJRCheckBox*)[_scrollView viewWithTag:i]).checkState];
            
        }

    }
    else
    {
        ((PJRCheckBox*)[_scrollView viewWithTag:271]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:272]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:274]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:275]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:276]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:277]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:278]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:273]).strokeColor = [UIColor redColor];
        
        [((PJRCheckBox*)[_scrollView viewWithTag:271]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:272]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:273]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:274]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:275]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:276]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:277]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:278]) setCheckState:PJRCheckboxStateUnchecked];
        
        if (!firstTag) firstTag = 271;
    }
    
    if (((PJRCheckBox*)[_scrollView viewWithTag:231]).checkState == PJRCheckboxStateChecked || ((PJRCheckBox*)[_scrollView viewWithTag:232]).checkState == PJRCheckboxStateChecked) {}
    else
    {
        ((PJRCheckBox*)[_scrollView viewWithTag:231]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:232]).strokeColor = [UIColor redColor];
        [((PJRCheckBox*)[_scrollView viewWithTag:231]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:232]) setCheckState:PJRCheckboxStateUnchecked];
        if (!firstTag) firstTag = 231;
    }
    
    if (((PJRCheckBox*)[_scrollView viewWithTag:241]).checkState == PJRCheckboxStateChecked || ((PJRCheckBox*)[_scrollView viewWithTag:242]).checkState == PJRCheckboxStateChecked) {}
    else
    {
        ((PJRCheckBox*)[_scrollView viewWithTag:241]).strokeColor =
        ((PJRCheckBox*)[_scrollView viewWithTag:242]).strokeColor = [UIColor redColor];
        [((PJRCheckBox*)[_scrollView viewWithTag:241]) setCheckState:PJRCheckboxStateUnchecked];
        [((PJRCheckBox*)[_scrollView viewWithTag:242]) setCheckState:PJRCheckboxStateUnchecked];
        if (!firstTag) firstTag = 241;
    }
    
    if (!firstTag) {
        NSLog(@"OKKKKK");
        return  YES;
    }
    
    CGPoint cp = [_scrollView viewWithTag:firstTag].frame.origin;
    cp.x = 0;
    cp.y = MAX(0, cp.y - 20);
    _scrollView.contentOffset = cp;
    
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 15) {
        if ([((UITextField*)[self.view viewWithTag:14]).text length] == 0)
        {
            ((UITextField*)[self.view viewWithTag:14]).layer.borderColor = [UIColor redColor].CGColor;
            ((UITextField*)[self.view viewWithTag:14]).layer.borderWidth = 1;
        }
        else {
            ((UITextField*)[self.view viewWithTag:14]).layer.borderColor = [UIColor redColor].CGColor;
            ((UITextField*)[self.view viewWithTag:14]).layer.borderWidth = 0;
        }
    }
    else if (textField.tag == 14)
    {
        if ([((UITextField*)[self.view viewWithTag:14]).text length] == 0 && [((UITextField*)[self.view viewWithTag:15]).text length] > 0)
        {
            ((UITextField*)[self.view viewWithTag:14]).layer.borderColor = [UIColor redColor].CGColor;
            ((UITextField*)[self.view viewWithTag:14]).layer.borderWidth = 1;
        }
        else {
            ((UITextField*)[self.view viewWithTag:14]).layer.borderColor = [UIColor redColor].CGColor;
            ((UITextField*)[self.view viewWithTag:14]).layer.borderWidth = 0;
        }
    }
    
    if (textField.tag == 15 || textField.tag == 14) {
        if (((UITextField*)[self.view viewWithTag:14]).text.length &&
            ((UITextField*)[self.view viewWithTag:15]).text.length &&
            [self getTime:((UITextField*)[self.view viewWithTag:14]).text] > [self getTime:((UITextField*)[self.view viewWithTag:15]).text])
        {
            ((UITextField*)[self.view viewWithTag:14]).layer.borderColor = [UIColor redColor].CGColor;
            ((UITextField*)[self.view viewWithTag:14]).layer.borderWidth = 1;
            ((UITextField*)[self.view viewWithTag:15]).layer.borderColor = [UIColor redColor].CGColor;
            ((UITextField*)[self.view viewWithTag:15]).layer.borderWidth = 1;
        }
        else {
            ((UITextField*)[self.view viewWithTag:15]).layer.borderColor = [UIColor redColor].CGColor;
            ((UITextField*)[self.view viewWithTag:15]).layer.borderWidth = 0;
        }
    }
    else {
        textField.layer.borderWidth = 0;
    }
}

-(NSTimeInterval)getTime:(NSString*)strDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:strDate];
    return [dateFromString timeIntervalSince1970];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textFieldDidBeginEditing:textField];
    
    if ([self isEmpty:textField.text] && ((textField.tag >= 2 && textField.tag <= 10) || (textField.tag >= 14 && textField.tag <= 17)))
    {
        textField.layer.borderWidth = 1;
        textField.layer.borderColor = [UIColor redColor].CGColor;
    }
    else textField.layer.borderWidth = 0;
}

- (IBAction)onDrawSignature:(id)sender {
    
    [self.view bringSubviewToFront:_signatureDialog];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rt = _signatureDialog.frame;
        
        rt.origin.y = 60;
        [_signatureDialog setFrame:rt];
    }];
}

- (IBAction)onResetSign:(id)sender {
    [_signatureView clearSignature];
}

@end

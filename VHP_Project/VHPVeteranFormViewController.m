//
//  VHPVeteranFormViewController.m
//  VHP_Project
//
//  Created by Steve on 4/7/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPVeteranFormViewController.h"

@interface VHPVeteranFormViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *signatureDialog;
@property PJRSignatureView* signatureView;
@property UIImageView* signatureImageView;
@end

@implementation VHPVeteranFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView = _scrollView;
    self.dateFieldTagsArray = @[@"2"];
    [self refreshInterface];
    
    int width = [[UIScreen mainScreen]bounds].size.width;
    int height = 620;
    [_scrollView setContentSize:CGSizeMake(width, 750)];
    
    _signatureImageView = (UIImageView*)[_scrollView viewWithTag:301];
    _signatureView = [[PJRSignatureView alloc]initWithFrame:CGRectMake(30, 35, width - 60, 100)];
    _signatureView.userInteractionEnabled = YES;
    _signatureView.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1]CGColor];
    _signatureView.layer.borderWidth = 1;
    _signatureView.clipsToBounds = YES;
    [_signatureDialog addSubview:_signatureView];
    // Do any additional setup after loading the view.

    [self load:@"veteran"];
    
    NSString* myname = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"name"];
    NSString* address = [self.app.tempData objectForKey:@"biography"][@"2"];
    if (address == nil) address = @"";
    
    if ([((UITextField*)[self.view viewWithTag:1]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:1]).text = _vetName;
    
    ((UITextField*)[self.view viewWithTag:3]).text = _vetName;
    
    if ([((UITextField*)[self.view viewWithTag:4]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:4]).text = address;
    if ([((UITextField*)[self.view viewWithTag:5]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:5]).text = myname;
    
    [self updateLabel:((UITextField*)[self.view viewWithTag:3])];

    [((UITextField*)[self.view viewWithTag:3]) addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventEditingChanged];
    
    for (int i = 301; i <= 301; i++) {
        ((UIImageView*)[_scrollView viewWithTag:i]).layer.borderWidth = 1;
        ((UIImageView*)[_scrollView viewWithTag:i]).layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderWidth = 0;
}

-(BOOL)isEmpty:(NSString*)string
{
    if ([string stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) return YES;
    return NO;
}

-(BOOL)confirmDetails
{
    if (self.readOnly)
        return YES;
    
    int firstTag = 0;
    
    for (int i = 2; i <= 5; i++)
    {
        if ([self isEmpty:((UITextField*)[self.view viewWithTag:i]).text])
        {
            if (!firstTag)
                firstTag = i;
            [self.view viewWithTag:i].layer.borderColor = [UIColor redColor].CGColor;
            [self.view viewWithTag:i].layer.borderWidth = 1;
        }
    }
    
    for (int i = 301; i<= 301; i++)
    {
        ((UIImageView*)[self.view viewWithTag:i]).layer.borderWidth = 0;
        UIImage* image = ((UIImageView*)[self.view viewWithTag:i]).image;
        if (image == nil || [self checkIfImage:image])
        {
            ((UIImageView*)[self.view viewWithTag:i]).layer.borderColor = [UIColor redColor].CGColor;
            ((UIImageView*)[self.view viewWithTag:i]).layer.borderWidth = 1;
            if (!firstTag)
                firstTag = i;
        }
        else {
            ((UIImageView*)[self.view viewWithTag:i]).layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
            ((UIImageView*)[self.view viewWithTag:i]).layer.borderWidth = 1;
        }
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
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self isEmpty:textField.text] && textField.tag != 6)
    {
        textField.layer.borderWidth = 1;
        textField.layer.borderColor = [UIColor redColor].CGColor;
    }
}

-(void)updateLabel:(UITextField*)textField
{
    NSString* myname = textField.text;
    
    NSString* text = [NSString stringWithFormat:@"I,  %@ , am a participant in the Veterans History Project (hereinafter \"VHP\") of the Library of Congress American Folklife Center.", myname];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:text];
    
    NSRange range;
    range.location = 3;
    range.length = [myname length] + 2;
    
    [string addAttribute:NSUnderlineStyleAttributeName  value:[NSNumber numberWithInteger:1] range:range];
    [string addAttribute:NSUnderlineColorAttributeName  value:[UIColor blackColor] range:range];
    
    [_letterLabel setAttributedText:string];
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
- (IBAction)onResetSign:(id)sender {
    [_signatureView clearSignature];
}

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
        _signatureView.layer.borderWidth = 0;
        _signatureImageView.image=[_signatureView getSignatureImage];
        _signatureView.layer.borderWidth = 1;
    }
    else
    {
        [self.view viewWithTag:301].layer.borderWidth = 0;
        
        if ([self confirmDetails] && [self save:@"veteran"]) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self.view viewWithTag:301].layer.borderWidth = 1;
            
        }
    }
}

- (IBAction)onReadPrint:(id)sender {
    [self save:@"veteran"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.loc.gov/vets/pdf/vetsrelease-fieldkit-2013.pdf"]];
}

- (IBAction)onDrawSignature:(id)sender {
    [self.view bringSubviewToFront:_signatureDialog];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rt = _signatureDialog.frame;
        
        rt.origin.y = 60;
        [_signatureDialog setFrame:rt];
    }];
    ((UIImageView*)[_scrollView viewWithTag:301]).layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
}

@end

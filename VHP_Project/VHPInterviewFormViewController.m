//
//  VHPVeteranFormViewController.m
//  VHP_Project
//
//  Created by Steve on 4/7/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPInterviewFormViewController.h"

@interface VHPInterviewFormViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *signatureDialog;
@property (weak, nonatomic) IBOutlet UIView *signatureDialog1;
@property (weak, nonatomic) IBOutlet UILabel *letterLabel;
@property PJRSignatureView* signatureView;
@property UIImageView* signatureImageView;
@property int selectedSignIndex;
@end

@implementation VHPInterviewFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView = _scrollView;
    self.dateFieldTagsArray = [@"11,13" componentsSeparatedByString:@","];
    self.stateFieldTagsArray = @[@"5"];
    [self refreshInterface];
    
    int width = [[UIScreen mainScreen]bounds].size.width;
    int height = 620;
    [_scrollView setContentSize:CGSizeMake(width, 1350)];
    
    _signatureImageView = (UIImageView*)[_scrollView viewWithTag:301];
    _signatureView = [[PJRSignatureView alloc]initWithFrame:CGRectMake(30, 35, width - 60, 100)];
    _signatureView.userInteractionEnabled = YES;
    [_signatureDialog addSubview:_signatureView];
    // Do any additional setup after loading the view.
    _signatureView.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1]CGColor];
    _signatureView.layer.borderWidth = 1;
    _signatureView.clipsToBounds = YES;
    _signatureView.tag = 901;
    _signatureView = [[PJRSignatureView alloc]initWithFrame:CGRectMake(30, 35, width - 60, 100)];
    _signatureView.userInteractionEnabled = YES;
    _signatureView.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1]CGColor];
    _signatureView.layer.borderWidth = 1;
    _signatureView.clipsToBounds = YES;
    _signatureView.tag = 902;
    [_signatureDialog1 addSubview:_signatureView];
    
    [self writeEmailList:@[@"8"]];
    
    for (int i = 301; i <= 302; i++) {
        ((UIImageView*)[_scrollView viewWithTag:i]).layer.borderWidth = 1;
        ((UIImageView*)[_scrollView viewWithTag:i]).layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    }
    
    [self load:@"interview"];
    
    NSString* myname = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"name"];
    NSString* email = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"email"];
    NSString* cell_phone = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"cell_phone"];
    
    if ([((UITextField*)[self.view viewWithTag:1]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:1]).text = myname;
    if ([((UITextField*)[self.view viewWithTag:2]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:2]).text = myname;
    
    if ([((UITextField*)[self.view viewWithTag:8]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:8]).text = email;
    if ([((UITextField*)[self.view viewWithTag:7]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:7]).text = cell_phone;

    ((UITextField*)[self.view viewWithTag:9]).text = _vetName;
    
    [self updateLabel:((UITextField*)[self.view viewWithTag:1])];
    
    [((UITextField*)[self.view viewWithTag:1]) addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventEditingChanged];
    
    [self addPhoneTexts:@[@"7"]];
    [self writeZipCodes:@[@"6"]];
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
    [(PJRSignatureView*)[[sender superview] viewWithTag:[sender tag] + 100] clearSignature];
}

- (IBAction)onBack:(id)sender {
    __block CGRect rt = [_signatureDialog frame];
    if (_selectedSignIndex == 302)
        rt = _signatureDialog1.frame;
    
    if (rt.origin.y <= 200)
    {
        int height = [[UIScreen mainScreen] bounds].size.height;
        [UIView animateWithDuration:0.25 animations:^{
            
            rt.origin.y = height;
            
            if (_selectedSignIndex == 301)
                [_signatureDialog setFrame:rt];
            else
                [_signatureDialog1 setFrame:rt];
        }];
        if (_selectedSignIndex == 301) {
            double f = [_signatureDialog viewWithTag:901].layer.borderWidth;
            [_signatureDialog viewWithTag:901].layer.borderWidth = 0;
            ((UIImageView*)[_scrollView viewWithTag:_selectedSignIndex]).image = [(PJRSignatureView*)[_signatureDialog viewWithTag:901] getSignatureImage];
            [_signatureDialog viewWithTag:901].layer.borderWidth = f;
        }
        else         {
            double f = [_signatureDialog viewWithTag:902].layer.borderWidth;
            [_signatureDialog viewWithTag:902].layer.borderWidth = 0;
            ((UIImageView*)[_scrollView viewWithTag:_selectedSignIndex]).image=[(PJRSignatureView*)[_signatureDialog1 viewWithTag:902] getSignatureImage];
            [_signatureDialog viewWithTag:902].layer.borderWidth = f;
        }
    }
    else
    {
        [self.view viewWithTag:301].layer.borderWidth = 0;
        [self.view viewWithTag:302].layer.borderWidth = 0;
        if ([self confirmDetails] && [self save:@"interview"]) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self.view viewWithTag:301].layer.borderWidth = 1;
            [self.view viewWithTag:302].layer.borderWidth = 1;
        }
    }

}

- (IBAction)onReadPrint:(id)sender {
    [self save:@"interview"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.loc.gov/vets/pdf/interviewer-release-fieldkit-2013.pdf"]];
}

- (IBAction)onDrawSignature:(id)sender {
    _selectedSignIndex = (int)[sender tag] - 9700;
    if (_selectedSignIndex == 302)
        [self onDrawSecondSignature];
    else {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect rt = _signatureDialog.frame;
            
            rt.origin.y = 60;
            [_signatureDialog setFrame:rt];
        }];
        ((UIImageView*)[_scrollView viewWithTag:301]).layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    }
}

-(void)onDrawSecondSignature
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rt = _signatureDialog1.frame;
        
        rt.origin.y = 60;
        [_signatureDialog1 setFrame:rt];
    }];
    ((UIImageView*)[_scrollView viewWithTag:302]).layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderWidth = 0;
}

-(BOOL)isEmpty:(NSString*)string
{
    return ([string stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0);
}

-(BOOL)confirmDetails
{
    if (self.readOnly) return YES;
    int firstTag = 0;
    
    for (int i = 1; i <= 11; i++)
    {
        if (i == 10) continue;
        
        if ([self isEmpty:((UITextField*)[self.view viewWithTag:i]).text])
        {
            if (!firstTag) firstTag = i;
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
            if (!firstTag) firstTag = i;
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
    if ([self isEmpty:textField.text] && textField.tag != 10 && textField.tag != 12 && textField.tag != 13)
    {
        textField.layer.borderWidth = 1;
        textField.layer.borderColor = [UIColor redColor].CGColor;
    }
    else textField.layer.borderWidth = 0;
}
@end

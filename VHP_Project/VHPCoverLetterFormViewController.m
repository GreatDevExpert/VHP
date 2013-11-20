//
//  VHPCoverLetterFormViewController.m
//  VHP_Project
//
//  Created by Steve on 4/7/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//
#import "PJRSignatureView.h"
#import "VHPCoverLetterFormViewController.h"
@interface VHPCoverLetterFormViewController()
@property (weak, nonatomic) IBOutlet UIView *signatureDialog;
@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property PJRSignatureView* signatureView;
@end

@implementation VHPCoverLetterFormViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //[_signatureDialog setHidden:YES];
    int width = [[UIScreen mainScreen]bounds].size.width;
    int height = 620;
    [_scrollView setContentSize:CGSizeMake(width, height)];
    _signatureView = [[PJRSignatureView alloc]initWithFrame:CGRectMake(30, 35, width - 60, 100)];
    _signatureView.userInteractionEnabled = YES;
    [_signatureDialog addSubview:_signatureView];
    
    self.contentView = _scrollView;
    self.dateFieldTagsArray = @[@"7"];    
    [self refreshInterface];

    _signatureView.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1]CGColor];
    _signatureView.layer.borderWidth = 1;
    _signatureView.clipsToBounds = YES;
    
    [self load:@"coverletter"];
    
    NSString* myname = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"name"];
    NSString* email = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"email"];
    NSString* phone = [[NSUserDefaults standardUserDefaults]objectForKey:@"userData"][@"cell_phone"];
    
    if ([((UITextField*)[self.view viewWithTag:1]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:1]).text = myname;
    
    if ([((UITextField*)[self.view viewWithTag:5]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:5]).text = email;

    if ([((UITextField*)[self.view viewWithTag:6]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:6]).text = _vetName;
    
    if ([((UITextField*)[self.view viewWithTag:4]).text length] == 0)
        ((UITextField*)[self.view viewWithTag:4]).text = phone;
    
    [self addPhoneTexts:@[@"4"]];
    [self writeEmailList:@[@"5"]];
}

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
        _signatureImageView.image=[_signatureView getSignatureImage];
    }

    else
    {
        if ([self save:@"coverletter"])
            [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)onDrawSignature:(id)sender {

    [UIView animateWithDuration:0.25 animations:^{
        CGRect rt = _signatureDialog.frame;
        
        rt.origin.y = 60;
        [_signatureDialog setFrame:rt];
    }];
}

@end

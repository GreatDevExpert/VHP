//
//  VHPInstructionsViewController.m
//  VHP_Project
//
//  Created by Steve on 4/18/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "VHPInstructionsViewController.h"
#import "MFSideMenu.h"
#import "SVProgressHUD.h"

@interface VHPInstructionsViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabels;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation VHPInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleLabels.text = _titles;

    NSString* path = [[NSBundle mainBundle] pathForResource:_name
                                                     ofType:@"html"];
    
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]];
    NSString* htmlString = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                         
                                                     error:nil];
    [_webView loadHTMLString:htmlString baseURL:url];
    _webView.delegate = self;
    _webView.scalesPageToFit = NO;
    
    [SVProgressHUD show];
    if (_flag == 101)
        [_backButton setTitle:@"< Back" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onMenu:(id)sender {
    if (_flag == 101)
        [self.navigationController popViewControllerAnimated:YES];
    else
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //make sure that the page scales when it is loaded :-)
    NSString *currentURL = [request.URL absoluteString];
    if ([[currentURL substringToIndex:4] isEqualToString:@"http"])
    {
        theWebView.scalesPageToFit = YES;
    }
    else theWebView.scalesPageToFit = NO;
    
    
    return YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
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

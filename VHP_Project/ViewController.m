//
//  ViewController.m
//  VHP_Project
//
//  Created by Steve on 3/29/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    int width = [[UIScreen mainScreen]bounds].size.width;
    int height = [[UIScreen mainScreen]bounds].size.height;
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

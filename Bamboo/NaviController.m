//
//  NaviController.m
//  Bamboo
//
//  Created by HeeJinChoi on 9/5/13.
//  Copyright (c) 2013 Matthew Burnett. All rights reserved.
//

#import "NaviController.h"
@interface NaviController ()

@end

@implementation NaviController

- (void)loadView {
    [super loadView];
    CGRect newframe = self.view.frame;
    newframe.size.height = [UIScreen mainScreen].bounds.size.height+44;
    self.view.frame = newframe;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

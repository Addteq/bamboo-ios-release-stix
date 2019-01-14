//
//  BuildSummaryViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 11/8/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface BuildSummaryViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
   UIScrollView *scrollView;
   NSMutableArray *viewControllers;
   
   // To be used when scrolls originate from the UIPageControl
   BOOL pageControlUsed;
}
//View Outlets
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

//Class Variables
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *planKey;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (strong, nonatomic) NSMutableArray *builds;
@property (strong, nonatomic) AFHTTPClient *client;
@property (strong, nonatomic) UIActionSheet *actionSh;
@property (strong, nonatomic) UIButton *bug;

//Actions
- (IBAction)showActionSheet:(id)sender;
- (IBAction)showFeedback:(id)sender;


@end

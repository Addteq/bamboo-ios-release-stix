//
//  BuildInfoViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 11/5/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import <MessageUI/MessageUI.h>
#import "BIViewController.h"

@interface BuildInfoViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate,MFMailComposeViewControllerDelegate>
{
   UIScrollView *scrollView;
   NSMutableArray *viewControllers;
   // To be used when scrolls originate from the UIPageControl
   BOOL pageControlUsed;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic) NSInteger *index;
@property (nonatomic, strong) NSMutableArray *keyArray;
@property (nonatomic, strong) NSMutableArray *buildArray;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *planKey;
@property (nonatomic, strong) NSString *buildKeyString;
@property (nonatomic, strong) AFHTTPClient *client;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, strong) UIActionSheet *actionSheetDismiss;
/*@property (nonatomic, strong) UIButton *bug;
@property (nonatomic, strong) UIImage *bugImage;
@property (nonatomic, strong) UIImage *myBug;
@property (nonatomic, strong) UIButton *bugAction;*/

- (IBAction)showActionSheet:(id)sender;
- (IBAction)showFeedback:(id)sender;
//- (void) addBugIcon;

@end

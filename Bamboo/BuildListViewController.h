//
//  BuildListViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 11/5/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@class BuildInfoViewController;

@interface BuildListViewController : UITableViewController <UISplitViewControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) BuildInfoViewController *detailViewController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfBuilds;
@property (nonatomic) int *refresh;
@property (nonatomic, strong) NSString *projectName;
@property (nonatomic, strong) NSString *planKey;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) AFHTTPClient *client;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, strong) UIActionSheet *actionSheetDismiss;
@property (nonatomic, strong) UIButton *bug;
@property (nonatomic) NSInteger relogintype;
@property (nonatomic, strong) UIImage *customBugIcon;
@property (nonatomic, strong) UIImage *customBugIconY;
@property (nonatomic, strong) NSString *bugColor;

- (IBAction)showActionSheet:(id)sender;
- (IBAction)showFeedback:(id)sender;
- (void) addBugIcon;

@end

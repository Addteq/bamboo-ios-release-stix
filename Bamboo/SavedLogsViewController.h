//
//  SavedLogsViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 12/26/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface SavedLogsViewController : UITableViewController <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) NSMutableArray *arrayOfLogs;
@property (strong, nonatomic) NSString *dirPath;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *planKey;
@property (strong, nonatomic) AFHTTPClient *client;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) UIActionSheet *actionSh;
@property (strong, nonatomic) UIButton *bug;

- (IBAction)showActionSheet:(id)sender;
- (IBAction)leaveFeedback:(id)sender;
- (void) addBugIcon;
@end

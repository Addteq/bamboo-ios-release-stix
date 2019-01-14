//
//  CTViewController.h
//  Changes
//
//  Created by Matthew Burnett on 12/18/12.
//  Edited by Yung Chang on 3/9/13.
//  Copyright (c) 2012 You Low Liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface CTViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *commitArray;
@property (nonatomic, strong) NSMutableArray *fileNamesArray;
@property (nonatomic, strong) NSMutableArray *filteredArray;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSString *buildKey;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) AFHTTPClient *client;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) Boolean flag;
@property (nonatomic) Boolean flag404;
@property (nonatomic) Boolean flag500;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) UIActionSheet *actionSh;
@property (nonatomic) CGFloat originScrollOffset;
@property (strong, nonatomic) UIButton *searchbt;
@property (strong, nonatomic) UIButton *bug;

- (IBAction)showActionSheet:(id)sender;
- (void)showSearch;
- (IBAction)showFeedback:(id)sender;
@end

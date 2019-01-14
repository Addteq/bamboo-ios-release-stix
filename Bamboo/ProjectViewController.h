//
//  ProjectViewController1.h
//  Bamboo
//
//  Created by You Liang Low on 12/28/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildListViewController.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface ProjectViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIScrollViewDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableDictionary *allProjectsFromPlist;
@property (nonatomic, strong) NSMutableDictionary *allPlansFromPlist;
@property (nonatomic, strong) NSMutableArray *allPlansArrayToStoreInPlist;
@property (nonatomic, strong) NSMutableArray *allprojectsArrayToStoreInPlist;
@property (nonatomic, strong) NSMutableDictionary *allprojectsDictToStoreInPlist;
@property (nonatomic) int startIndexForServerRequestForProjects;
@property (nonatomic) int startIndexForServerRequestForPlans;
@property (nonatomic) NSNumber *numberOfTimesNeedServerRequestForProjects;
@property (nonatomic) NSNumber *numberOfTimesNeedServerRequestForPlans;
@property (nonatomic, assign) BOOL recievedPlans;
@property (nonatomic, assign) BOOL recievedProjects;
@property (nonatomic, strong) NSMutableArray *storeProjectResponse;
@property (nonatomic, strong) NSMutableArray *storePlanResponse;
@property (nonatomic, strong) NSNumber *numProjects;
@property (nonatomic, assign) NSInteger *startIndex;
@property (nonatomic, strong) NSNumber *numberOfProjectsRecievedFromServer;
@property (nonatomic, strong) NSNumber *numberOfPlansRecievedFromServer;
@property (nonatomic, strong) NSArray *arrayOfProjects;
@property (nonatomic, strong) NSMutableArray* sortingArray;
@property (nonatomic, strong) NSMutableArray* arrayOfPlans;
@property (nonatomic, strong) NSMutableArray* projectArray;
@property (nonatomic, strong) NSMutableArray* planArray;
@property (nonatomic, strong) NSDictionary* projectDictionary;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) AFHTTPClient *client;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *hudForLoadingMoreProjects;
@property (nonatomic, strong) MBProgressHUD *hudShowIntialLoading;
@property (nonatomic, strong) id responseObjectForProjects;
@property (nonatomic, strong) NSMutableArray *filteredProjects;
@property (nonatomic, strong) NSMutableArray *filteredPlans;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, strong) UIButton *bug;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) UIActionSheet *actionSheetDismiss;
@property (nonatomic, strong) NSArray *allprojects;

- (IBAction)mySearch:(id)sender;
- (IBAction)showFeedback:(id)sender;
- (IBAction)showActionSheet:(id)sender;

- (void) addBugIcon;
- (void) search;

@end

//
//  EAProjectViewController.h
//  Bamboo
//
//  Created by Emmanuel Anyiam on 9/18/14.
//  Copyright (c) 2014 Addteq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BuildListViewController.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface EAProjectViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIScrollViewDelegate,NSURLConnectionDelegate>

@property (nonatomic,strong) NSMutableDictionary *allProjectsFromPlist;
@property (nonatomic,strong) NSMutableDictionary *allPlansFromPlist;
@property (nonatomic,strong) NSMutableArray *allPlansArrayToStoreInPlist;
@property (nonatomic,strong) NSMutableArray *allprojectsArrayToStoreInPlist;
@property (nonatomic,strong) NSMutableDictionary *allprojectsDictToStoreInPlist;
@property (nonatomic) int startIndexForServerRequestForProjects;
@property (nonatomic) int startIndexForServerRequestForPlans;
@property (nonatomic) NSNumber *numberOfTimesNeedServerRequestForProjects;
@property (nonatomic) NSNumber *numberOfTimesNeedServerRequestForPlans;
@property (nonatomic, assign) BOOL recievedPlans;
@property (nonatomic, assign) BOOL recievedProjects;
@property (nonatomic,strong) NSMutableArray *storeProjectResponse;
@property (nonatomic,strong) NSMutableArray *storePlanResponse;
@property (nonatomic,strong) NSNumber *numProjects;
@property (nonatomic,assign) NSInteger *startIndex;
@property (nonatomic,strong) NSNumber *numberOfProjectsRecievedFromServer;
@property (nonatomic,strong) NSNumber *numberOfPlansRecievedFromServer;
@property (nonatomic,strong) NSArray* arrayOfProjects;
@property (nonatomic,strong) NSMutableArray* sortingArray;
@property (nonatomic,strong) NSMutableArray* arrayOfPlans;
@property (nonatomic,strong) NSMutableArray* projectArray;
@property (nonatomic,strong) NSMutableArray* planArray;
@property (nonatomic,strong) NSDictionary* projectDictionary;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *myView;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) AFHTTPClient *client;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) MBProgressHUD *hudForLoadingMoreProjects;
@property (strong, nonatomic) MBProgressHUD *hudShowIntialLoading;
@property (strong, nonatomic) id responseObjectForProjects;

@property (strong, nonatomic) NSMutableArray *filteredProjects;
@property (strong, nonatomic) NSMutableArray *filteredPlans;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) UIButton *bug;
@property (strong, nonatomic) UISearchDisplayController *searchDisplayController;
@property (strong, nonatomic) UIActionSheet *actionSheetDismiss;
@property (strong,nonatomic) NSArray *allprojects;
//- (void)responseAfterDelay;
- (IBAction)eaSearch:(id)sender;
@property (nonatomic, strong) IBOutlet UIButton *dButton;

- (IBAction)mySearch:(id)sender;
- (void) search;
- (IBAction)showFeedback:(id)sender;
- (IBAction)showActionSheet:(id)sender;
//- (NSString *)resolvePath:(NSString *)serverAddress;
- (void) addBugIcon;

@end

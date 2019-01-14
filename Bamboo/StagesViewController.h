//
//  StagesViewController.h
//  Bamboo
//
//  Created by You Liang Low on 11/27/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface StagesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) NSString *buildNumString;
@property (nonatomic, strong) NSString *buildStateString;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *stagesDictionary;
@property (nonatomic, strong) NSMutableArray *stageArray;
@property (nonatomic, strong) NSMutableArray *stageNameArray;
@property (nonatomic, strong) NSMutableArray *stageKeyArray;
@property (nonatomic, strong) NSMutableArray *planNameArray;
@property (nonatomic, strong) NSNumber *numStages;
@property (nonatomic, strong) NSDictionary *resultsDictionary;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) NSString *buildKey;
@property (strong, nonatomic) IBOutlet UIImageView *buildStateBackground;
@property (strong, nonatomic) IBOutlet UIImageView *buildStateBackground1;
@property (strong, nonatomic) IBOutlet UIImageView *buildState;
@property (strong, nonatomic) IBOutlet UILabel *buildNum;
@property (strong, nonatomic) NSString *planKey;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) AFHTTPClient *client;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) UIActionSheet *actionSh;
@property (strong, nonatomic) UIButton *bug;
@property (nonatomic) NSInteger relogintype;
- (IBAction)showActionSheet:(id)sender;
-(void) addBugIcon;
- (IBAction)showFeedback:(id)sender;



@end

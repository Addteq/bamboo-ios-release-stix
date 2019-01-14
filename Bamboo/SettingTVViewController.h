//
//  SettingTVViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 1/10/13.
//  Copyright (c) 2013 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fullCell.h"
#import "serverCell.h"
#import "portCell.h"
#import "httpCell.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "myAFHTTPClient.h"
#import "SettingTVViewController.h"
#import "NaviController.h"

#define kBamboo @"bamboo_url"
#define kPort @"port_num"
#define kHttp @"http"
#define kServer @"fullServer"
#define kPath @"path"

@protocol ServerUpdateDelegate <NSObject>
@required

-(void)updateSuccessful:(BOOL)success;

@end

@interface SettingTVViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>{
    id <ServerUpdateDelegate> delegate;
}
@property (strong, nonatomic) NSString *tempServerFull;
@property (strong, nonatomic) NSString *tempAddress;
@property (strong, nonatomic) NSString *tempPort;
@property (strong, nonatomic) NSString *tempHttp;
@property (assign, nonatomic) BOOL isUnsecureURLWarninginResponse;
@property (assign, nonatomic) BOOL isServerURLNil;
@property (strong, nonatomic) NSString *untrustedServer;
@property (strong, nonatomic) myAFHTTPClient *myclient;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) id delegate;
@property (strong, nonatomic) UIBarButtonItem *doneButtonItem;
@property (strong, nonatomic) UIBarButtonItem *cancelButtonItem;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *tempText;
@property (strong, nonatomic) UITextField *tempField;
@property (strong, nonatomic) NSString *serverFull;
@property BOOL isHTTPS;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSString *http;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (retain, nonatomic) NSString *test;
//@property (strong, nonatomic) UIButton *bug;
@property (strong, nonatomic) UIButton *info;

- (IBAction)httpSwitch:(UISwitch*)sender;
- (IBAction)help:(id)sender;
- (IBAction)showFeedback:(id)sender;

- (void)done;
- (void) addBugIcon;

@end

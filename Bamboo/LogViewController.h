//
//  LogViewController.h
//  Bamboo
//
//  Created by You Liang Low on 11/30/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface LogViewController : UIViewController < UIScrollViewDelegate, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSNumber *numFull;
@property (nonatomic, strong) NSNumber *numInfo;
@property (nonatomic, strong) NSNumber *numError;
@property (nonatomic, strong) NSArray *logLine;
@property (nonatomic, strong) NSMutableArray *fullList;
@property (nonatomic, strong) NSMutableArray *infoList;
@property (nonatomic, strong) NSMutableArray *errorList;
@property (nonatomic, strong) NSMutableArray *summaryList;
@property (nonatomic, strong) NSString *fullString;
@property (nonatomic, strong) NSString *infoString;
@property (nonatomic, strong) NSString *errorString;
@property (nonatomic, strong) NSString *summaryString;
@property (nonatomic, strong) NSString *jobKey;
@property (nonatomic, strong) NSString *jobBuildKey;
@property (nonatomic, strong) NSString *log;
@property long long int logSize;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (strong, nonatomic) IBOutlet UISegmentedControl *logSegment;
@property (strong, nonatomic) IBOutlet UITextView *logView;
@property (strong, nonatomic) AFHTTPClient *client;
@property (strong, nonatomic) NSString *planKey;
@property (strong, nonatomic) NSString *dirPath;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) UIActionSheet *actionSh;
@property (strong, nonatomic) UIButton *bug;

- (IBAction)showActionSheet:(id)sender;
- (void) addBugIcon;
- (IBAction)downloadLog:(id)sender;
- (IBAction)openLog:(id)sender;
- (IBAction)changeSegment;
- (IBAction)showFeedback:(id)sender;




@end

//
//  LoginViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 11/8/12.
//  Edited by Weifeng Zheng
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"
#import "ProjectViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "myAFHTTPRequestOperation.h"
#import "myAFHTTPClient.h"
#import "SettingTVViewController.h"

#define kBamboo @"bamboo_url"
#define kPort @"port_num"
#define kHttp @"http"
#define kServer @"fullServer"
#define kBasePath @"baseWithPath"
#define kUsername @"username"
#define kRemember @"YES"

@interface LoginViewController : UIViewController <UINavigationControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, ServerUpdateDelegate> {
   CGPoint _originalCenter;
   SettingTVViewController *settingVC;
}

@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *guestButton;
@property (nonatomic, strong) IBOutlet UITextField *userID;
@property (nonatomic, strong) IBOutlet UITextField *userPass;
@property (nonatomic, strong) IBOutlet UISwitch *rememberMe;
@property (nonatomic, strong) IBOutlet UILabel *userIDLabel;
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *bamboo;
@property (nonatomic, strong) NSString *port;
@property (nonatomic, strong) NSString *http;
@property (nonatomic, strong) KeychainItemWrapper *keychainItem;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) myAFHTTPClient *myclient;
@property (nonatomic, strong) AFHTTPClient *client;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIButton *bug;

- (IBAction)loginButton:(id)sender;
- (IBAction)rememberChanged:(id)sender;
- (IBAction)helpMe:(id)sender;
//- (IBAction)guestLogin:(id)sender;
- (IBAction)showFeedback:(id)sender;
- (IBAction)editSettings:(id)sender;
//- (NSString *)resolvePath:(NSString *)serverAddress;

@end

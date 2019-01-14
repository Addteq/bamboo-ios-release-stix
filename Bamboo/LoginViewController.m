//
//  LoginViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 11/8/12.
//  Edited by Weifeng Zheng
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import "LoginViewController.h"
#import "NaviController.h"
#import "EACamView.h"

static void * SessionRunningAndDeviceAuthorizedContext = & SessionRunningAndDeviceAuthorizedContext;
@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet EACamView *preView;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;

@end

@implementation LoginViewController

@synthesize originalCenter = _originalCenter;
@synthesize userID;
@synthesize userPass;
@synthesize rememberMe;
@synthesize server;
@synthesize path;
@synthesize bamboo;
@synthesize port;
@synthesize http;
@synthesize keychainItem;
@synthesize hud;
@synthesize myclient;
@synthesize client;
@synthesize guestButton;
@synthesize userIDLabel;
@synthesize loginButton;
@synthesize toolbar;

NSString *userName;
NSString *password;

- (void)loadView {
    [super loadView];
    CGRect viewframe = self.view.frame;
    viewframe.size.height = [UIScreen mainScreen].bounds.size.height;
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    self.view.frame = viewframe;
    
}

- (void)updateSuccessful:(BOOL)success{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tmp = [[userDefaults URLForKey:kServer] absoluteString];
    NSRange range = [tmp rangeOfString:@"file://localhost/"];
    if (range.location != NSNotFound) {
        tmp = [tmp substringFromIndex:range.location+range.length];
    }
    if ( tmp == NULL || tmp.length == 0) {
        bamboo = [userDefaults stringForKey:kBamboo];
        port = [userDefaults stringForKey:kPort];
        http = [userDefaults stringForKey:kHttp];
        if (http != nil && http.length != 0) {
            if (bamboo != nil && bamboo.length != 0) {
                if (![port isEqualToString:@""] && port != NULL &  port.length != 0) {
                    server = [[NSString alloc] initWithFormat:@"%@://%@:%@", http, bamboo, port];
                } else {
                    server = [[NSString alloc] initWithFormat:@"%@://%@", http, bamboo];
                }
            }
        }
    } else {
        server = tmp;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [[self session] startRunning];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kUsername];
    rememberMe.on = [[NSUserDefaults standardUserDefaults] boolForKey:kRemember];
    if (rememberMe.on) {
        NSString *saved_pass = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
        NSString *saved_user = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
        self.userID.text = saved_user;
        self.userPass.text = saved_pass;
    } else {
        [keychainItem resetKeychainItem];
        self.userID.text = @"";
        self.userPass.text = @"";
    }
    [self updateSuccessful:YES];
    NaviController *con = ((NaviController *)self.parentViewController);
    [con.self.view setBackgroundColor:[UIColor blackColor]];
    [loginButton.layer setBorderWidth:1.0f];
    [loginButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [loginButton.layer setCornerRadius:4.0];
    [loginButton.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[loginButton setTitleColor:[UIColor blueColor] forState:UIControlEventTouchUpInside];
    [loginButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
   // [super viewWillDisappear:animated];
    [[self session] stopRunning];
    NaviController *con = ((NaviController *)self.parentViewController);
    [con.self.view setBackgroundColor:[UIColor whiteColor]];
    [super viewWillDisappear:animated];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.center = CGPointMake(self.view.center.x, 168);
    }
    return self;
}

- (void)viewDidLoad {
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BambooLogin" accessGroup:nil];
    _originalCenter = self.view.center;
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    // Setup the preview view
    [[self preView] setSession:session];
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        NSError *error = nil;
        AVCaptureDevice *videoDevice = [LoginViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (error) {
            
        }
        if ([session canAddInput:videoDeviceInput]) {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[(AVCaptureVideoPreviewLayer *)[[self preView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
            
        }
    });
    //Change here
    //Do this only for iPad because secure attribute does not work for iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        userPass.secureTextEntry = YES;
    }
    //if first time, display alert
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"firstTime"] == NULL) {
        [[NSUserDefaults standardUserDefaults] setValue:@"Not" forKey:@"firstTime"];
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"Welcome"
                       message:@"Welcome to the Bamboo App by Addteq. This app requires a plug-in to be installed on your Bamboo instance. If you do not have this plug-in installed, you will not be able to login."
                       delegate: self
                       cancelButtonTitle: @"Use Default"
                       otherButtonTitles: @"Edit Settings", nil];
        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        [alertDialog show];
    } else {
        [self updateSuccessful:YES];
        if (server.length == 0 || [server isEqualToString:@" "] || [server isEqualToString:@""]) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Server is Blank"
                           message:@"Your server setting is blank, please update your settings."
                           delegate: self
                           cancelButtonTitle: nil
                           otherButtonTitles: @"Edit Settings", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
    }
    if (![self.userID.text isEqualToString:@""]) {
        self.userID.text = @"";
    }
    if (![self.userPass.text isEqualToString:@""]) {
        self.userPass.text = @"";
    }
    
    //
    //    UIColor * color = [UIColor colorWithRed:52/255.0f green:106/255.0f blue:210/255.0f alpha:1.0f];
    //
    //    [loginButton.layer setBackgroundColor: [[UIColor blueColor]CGColor]];
    //    [loginButton.layer setBorderWidth:1.5f];
    //    [loginButton.layer setBorderColor:[color CGColor]];
    //    [loginButton.layer setShadowOpacity:0.1f];
    //    [loginButton.layer setCornerRadius:6.7];
    //
    //   [self.userID  becomeFirstResponder];
	// Do any additional setup after loading the view.
    
    [loginButton.layer setBorderWidth:1.0f];
   // [loginButton setTintColor:[UIColor whiteColor]];
   // [loginButton.layer setBackgroundColor:[[UIColor grayColor] CGColor]];
    [loginButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [loginButton.layer setCornerRadius:4.0];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[loginButton setTitleColor:[UIColor blueColor] forState:UIControlEventTouchUpInside];
    [loginButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlStateHighlighted];
    [loginButton addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpOutside];
    //Change here
    //To move up and down while keyboard appears and siapears
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [self.toolbar setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    self.toolbar.clipsToBounds=YES;
    //toolbar=[[UIToolbar alloc]init];
    //[self addBugIcon];
}

- (void)addBugIcon {
    UIToolbar *etoolbar = ((NaviController *)self.parentViewController).toolbar;
    [etoolbar setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    etoolbar.clipsToBounds=YES;
    self.bug = [UIButton buttonWithType:UIButtonTypeCustom];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.bug.frame = CGRectMake(724,8,28,28);
    } else {
        self.bug.frame = CGRectMake(282,10,28,28);
        [self.bug setImage:[UIImage imageNamed:@"whiteyBug@2x.png"] forState:UIControlStateNormal];
        [self.bug addTarget:self action:@selector(showFeedback:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:self.bug];
    }
    
    
}

- (void)buttonClicked {
    [loginButton.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    UIColor *customBlue;
    customBlue = [UIColor colorWithRed:74.0f/255.0f green:144.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    [loginButton setTitleColor:customBlue forState:UIControlStateNormal];
    loginButton.enabled = NO;
    [self performSelector:@selector(enableButton:) withObject:loginButton afterDelay:0.7];
}

- (void)buttonPressed {
    if (UIControlEventTouchUpInside){
        [loginButton.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
        UIColor *customBlue;
        customBlue = [UIColor colorWithRed:74.0f/255.0f green:144.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
        [loginButton setTitleColor:customBlue forState:UIControlStateHighlighted];
    }
}

- (void)buttonReleased {
    [loginButton.layer setBackgroundColor:nil];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)enableButton:(UIButton *)button {
    button.enabled = YES;
    [loginButton.layer setBackgroundColor:nil];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton.layer setBorderWidth:1.0f];
    [loginButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [loginButton.layer setCornerRadius:4.0];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButton:(id)sender {
    [self.userID resignFirstResponder];
    [self.userPass resignFirstResponder];
    [self login];
}

- (void)doSuccessBlock:(NSDictionary *)dict {
    NSDictionary* json = dict;
    NSString* check = [json objectForKey:@"check-code"];
    NSRange checkRange = [check rangeOfString:@"success"];
    if (checkRange.location != NSNotFound) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kRemember]){
            [keychainItem setObject:password forKey:(__bridge id)(kSecValueData)];
            [keychainItem setObject:userName forKey:(__bridge id)(kSecAttrAccount)];
        }else{
            [keychainItem resetKeychainItem];
        }
        [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kUsername];
        //Go to Project List
        ProjectViewController *pvc = [[ProjectViewController alloc] init];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            pvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"navControl"];
        } else {
            UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            pvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"navControl"];
        }
        pvc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        {
            pvc.modalPresentationStyle=UIModalPresentationFormSheet;
        }
        [self presentViewController:pvc animated:YES completion:nil];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    } else {
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        // delete cookies
        [myclient clearAuthorizationHeader];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookies];
        for (NSHTTPCookie *each in cookies) {
            [cookieStorage deleteCookie:each];
        }
        NSInteger checkNum = [check integerValue];
        NSString *licenseMessage = nil;
        if (checkNum == 110) {
            licenseMessage = @"No license";
        }else if(checkNum == 120){
            licenseMessage = @"Invalid UPM";
        }else if(checkNum == 130){
            licenseMessage = @"Please enable the plugin and try again.";
        }else if(checkNum == 140){
            licenseMessage = @"Expired License";
        }else if(checkNum == 151){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 152){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 153){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 154){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 155){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 156){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 157){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 158){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 159){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 160){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 161){
            licenseMessage = @"License Type Mismatch";
        }else if(checkNum == 170){
            licenseMessage = @"User Mismatch";
        }else if(checkNum == 180){
            licenseMessage = @"Edition Mismatch";
        }else if(checkNum == 190){
            licenseMessage = @"Version Mismatch";
        }else if(checkNum == 200){
            licenseMessage = @"Unknown License Error";
        }else{
            licenseMessage = @"Login Error";
        }
        
        NSString *reason = [[NSString alloc] initWithFormat:@"Reason: %@", licenseMessage];
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"Invalid License"
                       message:reason
                       delegate: self
                       cancelButtonTitle: @"Close"
                       otherButtonTitles: nil];
        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        [alertDialog show];
    }
}

- (void)login {
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"guest"];
    userName = [self.userID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password = [self.userPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([userName isEqualToString:@""] || [password isEqualToString:@""]){
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"Username/Password Error"
                       message:@"Username and/or Password are blank. Please fill out both fields."
                       delegate: self
                       cancelButtonTitle: @"Close"
                       otherButtonTitles: nil];
        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        [alertDialog show];
    } else if ([userName rangeOfString:@" "].location != NSNotFound ||
             [password rangeOfString:@" "].location != NSNotFound) {
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"Username/Password Error"
                       message:@"Username and/or Password contain one or more spaces."
                       delegate: self
                       cancelButtonTitle: @"Close"
                       otherButtonTitles: nil];
        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        [alertDialog show];
    } else if ([userName rangeOfString:@" "].location == NSNotFound &&
             [password rangeOfString:@" "].location == NSNotFound) {
        if(server.length == 0 || [server isEqualToString:@" "] || [server isEqualToString:@""]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [hud hide:YES];
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Server is Blank"
                           message:@"Your server setting is blank, please update your settings."
                           delegate: self
                           cancelButtonTitle: nil
                           otherButtonTitles: @"Edit Settings", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        } else {
            dispatch_queue_t loginRequest = dispatch_queue_create("LoginRequest",NULL);
            dispatch_async(loginRequest, ^(void){
            //Initialize httpClient
            myclient = [[myAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
            [myclient registerHTTPOperationClass:[AFJSONRequestOperation class]];
            [myclient setDefaultHeader:@"Accept" value:@"application/json"];
            [myclient setParameterEncoding:AFJSONParameterEncoding];
               path = [[NSUserDefaults standardUserDefaults]valueForKey:kPath];
            NSString *viewURL = nil;
            if([path isKindOfClass:[NSNull class]] || path == NULL) {
                viewURL = [[NSString alloc] initWithFormat:@"/rest/addteqrest/latest/check.json"];
            }
            else {
                viewURL = [[NSString alloc] initWithFormat:@"%@/rest/addteqrest/latest/check.json", path];
            }
            [myclient setAuthorizationHeaderWithUsername:userName password:password];
            [myclient getPath:viewURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //[client getPath:viewURL parameters:nil username:userName password:password success:^(AFHTTPRequestOperation *operation, id responseObject){
                NSDictionary* json = responseObject;
                NSString *version = [json objectForKey:@"Version"];
                NSString *licenceType = [json objectForKey:@"Type"];
                
                NSString *expirationDate = [json objectForKey:@"Expiration"];
                NSDateFormatter *dateFormatterForExpirationDate = [[NSDateFormatter alloc] init];
                [dateFormatterForExpirationDate setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSSZZZZ"];
                NSDate *expDateFromString = [dateFormatterForExpirationDate dateFromString:expirationDate];
                NSString *strDate = [dateFormatterForExpirationDate stringFromDate:[NSDate date]];
                NSDate *dateFromString = [dateFormatterForExpirationDate dateFromString:strDate];
                
                //version is 1.1
                if ([version isEqualToString:@"1.1"]) {
                    // licence type is Evaluation
                    if ([licenceType isEqualToString:@"Evaluation"]) {
                        // check whether licence expired
                        NSUserDefaults *userDefaultsToStoreExpirationDate = [NSUserDefaults standardUserDefaults];
                        [userDefaultsToStoreExpirationDate setValue:expDateFromString forKey:@"licenceExpirationDate"];
                        if([dateFromString compare:expDateFromString] == NSOrderedAscending ){
                            // NSLog(@"not near to expire");
                            hud = [[MBProgressHUD alloc] initWithView:self.view];
                            [self.view addSubview:hud];
                            [hud setLabelText:@"Logging In"];
                            hud.dimBackground = YES;
                            [hud show:YES];
                            [self doSuccessBlock:responseObject];
                        } else {
                             UIAlertView *alertview1 = [[UIAlertView alloc]initWithTitle:@"Plugin license expired" message:@"The license for STIX plugin seems to be expired. Please renew it by visiting the Atlassian marketplace." delegate:self cancelButtonTitle:@"Settings" otherButtonTitles:@"Update", nil];
                            alertview1.alertViewStyle=UIAlertViewStyleDefault;
                            alertview1.userInteractionEnabled = YES;
                            [alertview1 show];
                        }
                    }  //licence type is commercial
                    else if ([licenceType isEqualToString:@"Commercial"]) {
                        NSUserDefaults *userDefaultsToStoreExpirationDate = [NSUserDefaults standardUserDefaults];
                        [userDefaultsToStoreExpirationDate setValue:expDateFromString forKey:@"licenceExpirationDate"];
                        //dismiss
                        hud = [[MBProgressHUD alloc] initWithView:self.view];
                        [self.view addSubview:hud];
                        [hud setLabelText:@"Logging In"];
                        hud.dimBackground = YES;
                        [hud show:YES];
                        [self doSuccessBlock:responseObject];
                    } // licence type is Unlicenced
                    else {
                        UIAlertView *alertInvalidLicence = [[UIAlertView alloc]
                                                            initWithTitle:@"Invalid License"
                                                            message:@"No valid license found for the stix plugin"
                                                            delegate: nil
                                                            cancelButtonTitle: @"Close"
                                                            otherButtonTitles: nil];
                        alertInvalidLicence.alertViewStyle=UIAlertViewStyleDefault;
                        [alertInvalidLicence show];
                    }
                }//version NOT is 1.1
                else {
                    UIAlertView *alertForOldVersions = [[UIAlertView alloc]initWithTitle:@"Needs Latest Plugin" message:@"It appears that the plugin in the server is not updated for latest version. Please update the plugin. " delegate:self cancelButtonTitle:@"Download" otherButtonTitles:@"Cancel", nil];
                    [alertForOldVersions show];
                }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                // NSLog(@"description %@", error.description);
                // NSLog(@"debugDescription %@", error.debugDescription);
                // NSLog(@"localizedFailureReason %@", error.localizedFailureReason);
                // NSLog(@"localizedDescription %@", error.localizedDescription);
                // NSLog(@"%ld", (long)[operation.response statusCode]);
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                // delete cookies
                [myclient clearAuthorizationHeader];
                NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                NSArray *cookies = [cookieStorage cookies];
                for (NSHTTPCookie *each in cookies) {
                    // NSLog(@"Cookie:%@", [each description]);
                    [cookieStorage deleteCookie:each];
                }
                if ([operation.response statusCode] == 401) {
                    if([error.description rangeOfString:@"AUTHENTICATED_FAILED"].location == NSNotFound && [error.description rangeOfString:@"AUTHENTICATION_DENIED"].location == NSNotFound)
                    {
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Cannot reach server"
                                       message:@"Server returned a secure response but it looks like you are using http. Please check your settings and try again."
                                       delegate: nil
                                       cancelButtonTitle: @"Close"
                                       otherButtonTitles: nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    }
                    /*
                     else if([error.description rangeOfString:@"HTTP ERROR 401"].location != NSNotFound){
                     
                     
                     UIAlertView *alertDialog;
                     alertDialog = [[UIAlertView alloc]
                     initWithTitle:@"Error"
                     message: @"Couldn't find the STIX plugin on server for authentication. Please download the plugin to enable functionality."
                     delegate: self
                     cancelButtonTitle: @"Close"
                     otherButtonTitles: @"Download", nil];
                     alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                     
                     
                     
                     [alertDialog show];
                     }*/
                    else
                    {
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Authentication Denied"
                                       message:@"Username or Password incorrect. Please try again or check with the Administrator."
                                       delegate: nil
                                       cancelButtonTitle: @"Close"
                                       otherButtonTitles: nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    }
                } else if([operation.response statusCode] == 404) {
                    if([error.description rangeOfString:@"ErrorDomain Code=-1011"].location != NSNotFound){
                        //[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Couldn't find the STIX plugin on server for authentication. Please download the plugin to enable functionality." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Error"
                                       message: @"Couldn't find the STIX plugin on server for authentication. Please download the plugin to enable functionality."
                                       delegate: self
                                       cancelButtonTitle: @"Close"
                                       otherButtonTitles: @"Download", nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    } else {
                        
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Authentication Denied"
                                       message:@"Username or Password incorrect. Please try again or check with the Administrator."
                                       delegate: nil
                                       cancelButtonTitle: @"Close"
                                       otherButtonTitles: nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    }
                } else if([operation.response statusCode] == 503){
                    UIAlertView *alertDialog;
                    alertDialog = [[UIAlertView alloc]
                                   initWithTitle:@"Cannot reach server"
                                   message:@"You were unable to reach the server."
                                   delegate: nil
                                   cancelButtonTitle: @"Close"
                                   otherButtonTitles: nil];
                    alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                    [alertDialog show];
                } else {
                    if(error) {
                        //change here
                        //if it is self signed problem
                        if ([error.description rangeOfString:@"ErrorDomain Code=-1202"].location != NSNotFound) {
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"OK ", nil] show];
                        }
                        else if([error.description rangeOfString:@"ErrorDomain Code=-1200"].location != NSNotFound){
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Server returned an unsecure response but it looks like you are using https. Please check your settings and try again." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                        }
                        else if([error.description rangeOfString:@"ErrorDomain Code=-1001"].location != NSNotFound){
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Request Timed out. Please try again." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                        }else if([error.description rangeOfString:@"400 Bad Request"].location != NSNotFound){
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot reach the server", nil) message:@"Server returned a secure response but it looks like you are using http. Please check your settings and try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                        }else
                        {
                            if([error.description rangeOfString:@"ErrorDomain Code=-1016"].location != NSNotFound)
                            {
                                
                                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"The bamboo server that you are trying to access is not a valid Bamboo server." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                            }
                            else
                            {
                                //// NSLog(@"400 ===> %@",[error localizedDescription]);
                                
                                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                            }
                        }/*
                          else if([error.description rangeOfString:@"ErrorDomain Code=-1016"].location != NSNotFound){
                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"The bamboo server that you are trying to access is not valid Bamboo server." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                          }else
                          {
                          if([error.description rangeOfString:@"400 Bad Request"].location != NSNotFound)
                          {
                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot reach the server", nil) message:@"Server returned a secure response but it looks like you are using http. Please check your settings and try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                          
                          }
                          else
                          {
                          //// NSLog(@"400 ===> %@",[error localizedDescription]);
                          
                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                          }
                          }*/
                        
                        
                    }
                    
                }
                
                
            }];
//            [hud show:NO];
            });
        }
    }
}

- (void)allowLogInToProjectViewController {
//    if (checkRange.location != NSNotFound) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kRemember]){
            [keychainItem setObject:password forKey:(__bridge id)(kSecValueData)];
            [keychainItem setObject:userName forKey:(__bridge id)(kSecAttrAccount)];
        } else {
            [keychainItem resetKeychainItem];
        }
        [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kUsername];
        //Go to Project List
        ProjectViewController *pvc = [[ProjectViewController alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            pvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"navControl"];
        } else {
            UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            pvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"navControl"];
        }
        pvc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        {
            pvc.modalPresentationStyle=UIModalPresentationFormSheet;
        }
        [self presentViewController:pvc animated:YES completion:nil];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
   // }else{
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        // delete cookies
        [myclient clearAuthorizationHeader];
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookies];
        for (NSHTTPCookie *each in cookies) {
            [cookieStorage deleteCookie:each];
        }
}

- (IBAction)rememberChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:rememberMe.on forKey:kRemember];
}

- (IBAction)helpMe:(id)sender {
    //    UIAlertView *alertDialog;
    //    alertDialog = [[UIAlertView alloc]
    //                   initWithTitle:@"Help"
    //                   message:@"If you are having issues connecting, please check your Bamboo address in the Settings page. If these settings are correct, please check that you are using your correct Bamboo login credentials. If your login credentials are correct and still having issues, please submit a bug report using the bottom right compose button."
    //                   delegate: self
    //                   cancelButtonTitle: @"Close"
    //                   otherButtonTitles: @"Open help page"];
    //    alertDialog.alertViewStyle=UIAlertViewStyleDefault;
    //    [alertDialog show];
    //
    //
    
    [[[UIAlertView alloc] initWithTitle:@"Help" message:@"If you are having issues connecting, please check your Bamboo address in the Settings page. If these settings are correct, please check that you are using your correct Bamboo login credentials. If your login credentials are correct and still having issues, please submit a bug report using the bottom right compose button. You can view more help information by open help page" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"Open help page", nil] show];
}

//- (IBAction)guestLogin:(id)sender {
//    if (server.length == 0 || [server isEqualToString:@" "] || [server isEqualToString:@""]) {
//        UIAlertView *alertDialog;
//        alertDialog = [[UIAlertView alloc]
//                       initWithTitle:@"Server is Blank"
//                       message:@"Your server setting is blank, please update your settings."
//                       delegate: self
//                       cancelButtonTitle: nil
//                       otherButtonTitles: @"Edit Settings", nil];
//        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
//        [alertDialog show];
//    } else {
//    //Show Alert to notify of Guest Login
//    UIAlertView *alertDialog;
//    alertDialog = [[UIAlertView alloc]
//                   initWithTitle:@"Guest Login"
//                   message:@"If guest access is allowed on the provided Bamboo instance, continue. If not, please use your username and password."
//                   delegate: self
//                   cancelButtonTitle: @"Cancel"
//                   otherButtonTitles: @"Ok", nil];
//    alertDialog.alertViewStyle=UIAlertViewStyleDefault;
//    [alertDialog show];
//    }
//}

- (IBAction)showFeedback:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
    }
    
}

- (IBAction)editSettings:(id)sender {
    settingVC = [[SettingTVViewController alloc] init];
     
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            settingVC = [ipadstoryboard instantiateViewControllerWithIdentifier:@"settingNavi"];
        }
        else
        {
            UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            settingVC = [iphonestoryboard instantiateViewControllerWithIdentifier:@"settingNavi"];
        }
    
    
    settingVC.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        settingVC.modalPresentationStyle=UIModalPresentationFormSheet;
    }
    settingVC.delegate = self;
    [self presentViewController:settingVC animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Get the name of the current pressed button
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Settings"]) {
        [self editSettings:self];
    }
    if ([buttonTitle isEqualToString:@"Update"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://marketplace.atlassian.com/plugins/com.addteq.bamboo.plugin.addteq-bamboo-plugin"]];
    }
    if ([buttonTitle isEqualToString:@"Ok"]){
        //Skip login and go to Project List
        //Go to Project List
        //Change here, do a check for guest mode
        //Solve for issue BIP-234 Activate the guest mode
        //Initialize httpClient
        myAFHTTPClient* testClient = [[myAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
        [testClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [testClient setDefaultHeader:@"Accept" value:@"application/json"];
        [testClient setParameterEncoding:AFJSONParameterEncoding];
        path = [[NSUserDefaults standardUserDefaults]valueForKey:kPath];
   
        NSString *projectURL = nil;
        NSString *successURL = nil;
        if ([path isKindOfClass:[NSNull class]] || path == NULL) {
            projectURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/project.json?expand=projects.project.plans"];
            successURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result.json"];
        } else {
            projectURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/project.json?expand=projects.project.plans", path];
            successURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/result.json", path];
        }
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud setLabelText:@"Logging In"];
        hud.dimBackground = YES;
        [hud show:YES];
        // NSLog(@"Before start");
        [testClient getPath:projectURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        ProjectViewController *pvc;
      
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                    pvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"navControl"];
                }
                else
                {
                    UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                    pvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"navControl"];
                }
            
            pvc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
            {
                pvc.modalPresentationStyle=UIModalPresentationFormSheet;
            }
            [[NSUserDefaults standardUserDefaults] setValue:@"guest" forKey:@"guest"];
            [self presentViewController:pvc animated:YES completion:nil];

            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // NSLog(@"Fail2 %@", error.description);
            
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            // delete cookies
            [testClient clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                // NSLog(@"Cookie:%@", [each description]);
                [cookieStorage deleteCookie:each];
            }
            // **** //

            
            if((testClient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (testClient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
                
                if([error.description rangeOfString:@"ErrorDomain Code=-1200"].location != NSNotFound){
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Server returned an unsecure response but it looks like you are using https. Please check your settings and try again." delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil, nil] show];
                }else if([error.description rangeOfString:@"ErrorDomain Code=-1011"].location != NSNotFound){
                    
                    if([server rangeOfString:@"http://"].location != NSNotFound){
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Server returned a secure response but it looks like you are using http. Please check your settings and try again." delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil, nil] show];
                    }else{
                        UIAlertView *alertDialog = [[UIAlertView alloc]
                                                    initWithTitle:@"Error"
                                                    message:@"Guest login is not available for this server!"
                                                    delegate: nil
                                                    cancelButtonTitle: @"Close"
                                                    otherButtonTitles: nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    }
                }else if([error.description rangeOfString:@"ErrorDomain Code=-1016"].location != NSNotFound)
                {
                    
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"The bamboo server that you are trying to access is not a valid Bamboo server." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                }else if([error.description rangeOfString:@"ErrorDomain Code=-1003"].location != NSNotFound)
                {
                    
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                }else{

                UIAlertView *alertDialog = [[UIAlertView alloc]
                                            initWithTitle:@"Error"
                                            message:@"Guest login is not available for this server!"
                                            delegate: nil
                                            cancelButtonTitle: @"Close"
                                            otherButtonTitles: nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
                }
            }else{
                if([error.description rangeOfString:@"ErrorDomain Code=-1003"].location != NSNotFound)
                {
                    
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                }else if([error.description rangeOfString:@"ErrorDomain Code=-1016"].location != NSNotFound)
                {
                    
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"The bamboo server that you are trying to access is not a valid Bamboo server." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                }else{
                UIAlertView *alertDialog = [[UIAlertView alloc]
                                            initWithTitle:@"Error"
                                            message:@"Guest login is not available for this server!"
                                            delegate: nil
                                            cancelButtonTitle: @"Close"
                                            otherButtonTitles: nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
                }
            }
        }];
    }
    
    if ([buttonTitle isEqualToString:@"Use Default"]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *initialDefaults=[[NSDictionary alloc]
                                       initWithObjectsAndKeys:
                                       @"bamboo.addteq.com", kBamboo,
                                       @"", kPort,
                                       @"https", kHttp,
                                       @"", kServer,
                                       nil];
        [userDefaults registerDefaults: initialDefaults];
        [self updateSuccessful:YES];
    }
    
    //Change here
    if ([buttonTitle isEqualToString:@"Open help page"]) {
        [[[UIAlertView alloc] initWithTitle:@"Open Safari" message:@"Stix would like to open your Safari for more help information" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"Allow", nil] show];
    } else if([buttonTitle isEqualToString:@"Download"]){
        [[[UIAlertView alloc] initWithTitle:@"Open Safari" message:@"Stix would like to open your Safari for download page" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"Agree", nil] show];
        
    }
    if ([buttonTitle isEqualToString:@"Allow"]) {
        // NSLog(@"User want to view help page");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://addteq.atlassian.net/wiki/display/DOC/Documentation"]];
    } else if([buttonTitle isEqualToString:@"Agree"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://marketplace.atlassian.com/plugins/com.addteq.bamboo.plugin.addteq-bamboo-plugin"]];
    }
    
    
    //Change here, for handling if user want to continue visit untrusted address
    if ([buttonTitle isEqualToString:@"OK "]) {
        //Initialize httpClient
        client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [client setDefaultHeader:@"Accept" value:@"application/json"];
        [client setParameterEncoding:AFJSONParameterEncoding];
        path = [[NSUserDefaults standardUserDefaults]valueForKey:kPath];

        NSString *viewURL = nil;
        if([path isKindOfClass:[NSNull class]] || path == NULL) {
            viewURL = [[NSString alloc] initWithFormat:@"/rest/addteqrest/latest/check.json"];
        }
        else {
            viewURL = [[NSString alloc] initWithFormat:@"%@/rest/addteqrest/latest/check.json", path];
        }
        [client setAuthorizationHeaderWithUsername:userName password:password];
        [client getPath:viewURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //[client getPath:viewURL parameters:nil username:userName password:password success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            NSDictionary* json = responseObject;
            NSString* check = [json objectForKey:@"check-code"];
            NSRange checkRange = [check rangeOfString:@"success"];
            if (checkRange.location != NSNotFound) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:kRemember]){
                    [keychainItem setObject:password forKey:(__bridge id)(kSecValueData)];
                    [keychainItem setObject:userName forKey:(__bridge id)(kSecAttrAccount)];
                } else {
                    [keychainItem resetKeychainItem];
                }
                [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kUsername];
                //Go to Project List
                ProjectViewController *pvc = [[ProjectViewController alloc] init];
     
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                        pvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"navControl"];
                    }
                    else
                    {
                        UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                        pvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"navControl"];
                    }
                pvc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
                {
                    pvc.modalPresentationStyle=UIModalPresentationFormSheet;
                }
                [self presentViewController:pvc animated:YES completion:nil];
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            } else {
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                // delete cookies
                [client clearAuthorizationHeader];
                NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                NSArray *cookies = [cookieStorage cookies];
                for (NSHTTPCookie *each in cookies) {
                    // NSLog(@"Cookie:%@", [each description]);
                    [cookieStorage deleteCookie:each];
                }

                NSInteger checkNum = [check integerValue];
                NSString *licenseMessage = nil;
                if (checkNum == 110) {
                    licenseMessage = @"No license";
                }else if(checkNum == 120){
                    licenseMessage = @"Invalid UPM";
                }else if(checkNum == 130){
                    licenseMessage = @"Remote Agent Required";
                }else if(checkNum == 140){
                    licenseMessage = @"Expired License";
                }else if(checkNum == 151){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 152){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 153){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 154){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 155){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 156){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 157){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 158){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 159){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 160){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 161){
                    licenseMessage = @"License Type Mismatch";
                }else if(checkNum == 170){
                    licenseMessage = @"User Mismatch";
                }else if(checkNum == 180){
                    licenseMessage = @"Edition Mismatch";
                }else if(checkNum == 190){
                    licenseMessage = @"Version Mismatch";
                }else if(checkNum == 200){
                    licenseMessage = @"Unknown License Error";
                }else{
                    licenseMessage = @"Login Error";
                }
                NSString *reason = [[NSString alloc] initWithFormat:@"Reason: %@", licenseMessage];
                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Invalid License"
                               message:reason
                               delegate: self
                               cancelButtonTitle: @"Close"
                               otherButtonTitles: nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // NSLog(@"description %@", error.description);
            // NSLog(@"debugDescription %@", error.debugDescription);
            // NSLog(@"localizedFailureReason %@", error.localizedFailureReason);
            // NSLog(@"localizedDescription %@", error.localizedDescription);
            
            // NSLog(@"%ld", (long)[operation.response statusCode]);
            
            
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [client clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }

            if ([operation.response statusCode] == 401) {
                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Authentication Denied"
                               message:@"You were unable to login, please ensure you are authorized to access this server and your credentials are correct."
                               delegate: self
                               cancelButtonTitle: @"Close"
                               otherButtonTitles: nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
            } else if([operation.response statusCode] == 404) {
                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Invalid Server"
                               message:@"You were unable to login, please ensure you are authorized to access this server and your credentials are correct."
                               delegate: self
                               cancelButtonTitle: @"Close"
                               otherButtonTitles: nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
            } else {
                if(error) {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"The bamboo server that you are trying to access is not a valid Bamboo server." delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                    
                    //[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                }
            }
            
        }];
        [hud show:NO];
    }
    if ([buttonTitle isEqualToString:@"Edit Settings"]) {
        [self editSettings:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:TRUE];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield{
    if(textfield == self.userID){
        [self.userID resignFirstResponder];
        [self.userPass becomeFirstResponder];
        return NO;
    }
    if(textfield == self.userPass){
        [self.userPass resignFirstResponder];
        [[self view] endEditing:YES];
        [self loginButton:self];
        return YES;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(textField == self.userID){
            bool isEqual = CGPointEqualToPoint (self.view.center, _originalCenter);
            if(isEqual){
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.0];
                self.view.center = CGPointMake(self.view.center.x, (self.view.center.y - self.userIDLabel.frame.origin.y+2));
                [UIView commitAnimations];
            }
        }
        if(textField == self.userPass){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.0];
            self.view.center = CGPointMake(self.view.center.x, (self.view.center.y - self.userIDLabel.frame.origin.y+2));
            [UIView commitAnimations];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(textField == self.userID){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.0];
            self.view.center = CGPointMake(self.view.center.x, (self.view.center.y + self.userIDLabel.frame.origin.y-2));
            [UIView commitAnimations];
        }
        if(textField == self.userPass){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.0];
            self.view.center = CGPointMake(self.view.center.x, (self.view.center.y + self.userIDLabel.frame.origin.y-2));
            [UIView commitAnimations];
        }
    }
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

//Change here
//To move up while keyboard appears
- (void)keyboardDidShow:(NSNotification *)notification {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        //Assign new frame to your view
        //[self.view setFrame:CGRectMake(0,-30,320,460)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
       // [self.view setFrame:CGRectMake(0,-30,self.view.frame.size.width,self.view.frame.size.height)];
    }
}

//Change here
//To move done while keyboard finshed
- (void)keyboardDidHide:(NSNotification *)notification
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
      // [self.view setFrame:CGRectMake(0,20,self.view.frame.size.width,self.view.frame.size.height)];
        /*
        CGRect viewframe = self.view.frame;
        viewframe.size.height = [UIScreen mainScreen].bounds.size.height;
        [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        self.view.frame = viewframe;*/
    }
}

@end


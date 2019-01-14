//
//  BuildSummaryViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 11/8/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//
#define kSuccess @"success"
#define kFailure @"failure"
#define kUnknown @"unknown"
#define kBasePath @"baseWithPath"

#import "BSViewController.h"
#import "BuildSummaryViewController.h"
#import "BuildItem.h"
#import "NaviController.h"
#import "CustomIOS7AlertView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
static NSUInteger kNumberOfPages = 3;

@interface BuildSummaryViewController ()
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@end

@implementation BuildSummaryViewController
@synthesize server;
@synthesize path;
@synthesize planKey;
@synthesize viewControllers;
@synthesize scrollView;
@synthesize builds;
@synthesize client;
@synthesize actionSh;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    CGRect sframe = scrollView.frame;
    sframe.size.height = [UIScreen mainScreen].bounds.size.height;
    scrollView.frame = sframe;
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    //Start Build here.
    //Post to queue URL - rest/api/latest/queue
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setDefaultHeader:@"X-Atlassian-Token" value:@"nocheck"];
    [client setParameterEncoding:AFJSONParameterEncoding];
    //[self addBugIcon];
    
}

- (void) addBugIcon{
    UIToolbar *toolbar = ((NaviController *)self.parentViewController).toolbar;
    [toolbar setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    toolbar.clipsToBounds=YES;
    //   // NSLog(@"%@")
    
    self.bug = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.bug.frame = CGRectMake(731,10,28,28);
    }else{
        self.bug.frame = CGRectMake(282,10,28,28);
    }
    
    [self.bug setImage:[UIImage imageNamed:@"whiteyBug.png"] forState:UIControlStateNormal];
    [self.bug addTarget:self action:@selector(showFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:self.bug];
    
}

-(void) viewWillDisappear:(BOOL)animated{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if(self.actionSh.visible){
            [self.actionSh dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    NaviController *navi = ((NaviController *)self.parentViewController);
    [navi.view setBackgroundColor:[UIColor whiteColor]];
    [self.bug setImage:nil forState:UIControlStateNormal];
    [super viewWillDisappear:animated];
}

-(void) viewWillAppear:(BOOL)animated{
    NaviController *navi = ((NaviController *)self.parentViewController);
    [navi.view setBackgroundColor:[UIColor blackColor]];
    [self.bug setImage:[UIImage imageNamed:@"whiteyBug.png"] forState:UIControlStateNormal];
    [super viewWillAppear:animated];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    BSViewController *controller = [viewControllers objectAtIndex:page];
    
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[BSViewController alloc] initWithNibName:@"BSViewController" bundle:nil];
        controller.pageNumber = page;
        controller.buildsArray = builds;
        controller.planKey = planKey;
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        // NSLog(@"Scrolllview %f", scrollView.frame.size.height);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)didReceiveMemoryWarning {
    [self setActionSh:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet;
    //Action Sheet Title
    NSString *actionSheetTitle = @"Build Summary";
    //Action Sheet Button Titles
    NSString *build = @"Start Build";
    NSString *logout = @"Logout";
    NSString *cancelTitle = @"Cancel";
    NSString *helpTitle = @"Help";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *guest = [userDefaults stringForKey:@"guest"];
    if ([guest isEqualToString:@"guest"]) {
        //Hide play button
        actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                  delegate:self
                                         cancelButtonTitle:cancelTitle
                                    destructiveButtonTitle:logout
                                         otherButtonTitles:helpTitle, nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                  delegate:self
                                         cancelButtonTitle:cancelTitle
                                    destructiveButtonTitle:logout
                                         otherButtonTitles:build,helpTitle, nil];
    }
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        actionSheet.cancelButtonIndex = -1;
    }
    //    } else {
    //        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    //    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (actionSheet.visible) {
            [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex
                                              animated:YES];
        } else {
            [actionSheet showFromBarButtonItem:sender animated:YES];
        }
    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
    self.actionSh = actionSheet;
}

- (IBAction)showFeedback:(id)sender {
    [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==-1)
    {
        // NSLog(@"Touch outside");
        //[actionSheet showInView:[self.view window]];
    }
    
    else
    {
        //Get the name of the current pressed button
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"Logout"]) {
            [client clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([buttonTitle isEqualToString:@"Start Build"]) {
            NSString *message = [[NSString alloc] initWithFormat:@"Are you sure you would like to start %@?", planKey];
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Confirm Build"
                           message:message
                           delegate: self
                           cancelButtonTitle: @"Cancel"
                           otherButtonTitles: @"Yes", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
        else if ([buttonTitle isEqualToString:@"Help"]) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen displays statistics relative to the selected plan. Scroll left or right to see more information. From here, you can start a new build for the selected plan."
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Yes"]){
        
        if((client.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown)) {
            
            //Check if host can be reached first, before making request
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Cannot connect to Server" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        }
        else {
            
            NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
            
            if([path isKindOfClass:[NSNull class]] || path == NULL) {
                planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
            }else{
                planURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/queue/%@", path, planKey];
            }
            
            [client postPath:planURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *result = [responseObject description];
                //           // NSLog(@"String result:%@", result);
                if (result != (id)[NSNull null]) {
                    [[[[iToast makeText:@" Successfully posted to build queue "]
                       setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
                }else{
                    [[[[[[iToast makeText:@" Could not post to build queue "]
                         setBackgroundColor: [UIColor colorWithRed:210/255.0f green:1/255.0f blue:8/255.0f alpha:1.0f]]
                        setTextColor:[UIColor whiteColor]]
                       setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if ([operation.response statusCode] == 401) {
                    if([error.description rangeOfString:@"Access is denied"].location != NSNotFound){
                        /*[[[[[[iToast makeText:@" Unauthorized Access\n You do not have permission to build  "]
                             setBackgroundColor: [UIColor colorWithRed:210/255.0f green:1/255.0f blue:8/255.0f alpha:1.0f]]
                            setTextColor:[UIColor whiteColor]]
                           setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
                        */
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                            CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
                            [alert setContainerView: [self createAlertView]];
                            [alert setButtonTitles:[NSArray arrayWithObject:@"Dismiss"]];
                            [alert show];
                        }else{
                        UIAlertView *alertDialog;
                        UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
                        [imageView setImage:[UIImage imageNamed:@"redX@2x.png"]];
                        
                        
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"    Unauthorized Access"
                                       message:@"You do not have permission to build!"
                                       delegate: self
                                       cancelButtonTitle: @"Dismiss"
                                       otherButtonTitles: @"Logout", nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog addSubview:imageView];
                        [alertDialog show];
                        }
                    }else{
                        // need to loggin in
                        [self loggingIn:1];
                    }
                    
                }else if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Error"
                                       message:@"Server Error or Unavailable, Please logout!"
                                       delegate: self
                                       cancelButtonTitle: @"Dismiss"
                                       otherButtonTitles: @"Logout", nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                }else{
                    UIAlertView *alertDialog;
                    alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:@"Check your internet connection."
                               delegate: self
                               cancelButtonTitle: @"Dismiss"
                               otherButtonTitles: @"Logout", nil];
                    alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                    [alertDialog show];

                }
                // NSLog(@"Network Request Error:%@", error);
                
            }];
        }
    }
    if([buttonTitle isEqualToString:@"Logout"]) {
        [client clearAuthorizationHeader];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
            [cookieStorage deleteCookie:each];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if([buttonTitle isEqualToString:@"Dismiss"]) {
        return;
    }else if([buttonTitle isEqualToString:@"Retry"]){
        [self loggingIn:1];
    }
}
- (void) retryBuilding{
    
    NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
    
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
    }else{
        planURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/queue/%@", path, planKey];
    }
    // NSLog(@"Plan URL in BuildInfo:%@", planURL);
    [client postPath:planURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *result = [responseObject description];
        if (result != (id)[NSNull null]) {
            [[[[iToast makeText:@" Successfully posted to build queue "]
               setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
        }else{
            [[[[[[iToast makeText:@" Could not post to build queue "]
                 setBackgroundColor: [UIColor colorWithRed:210/255.0f green:1/255.0f blue:8/255.0f alpha:1.0f]]
                setTextColor:[UIColor whiteColor]]
               setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == 401) {
            /*[[[[[[iToast makeText:@" Unauthorized Access\n You do not have permission to build  "]
                 setBackgroundColor: [UIColor colorWithRed:210/255.0f green:1/255.0f blue:8/255.0f alpha:1.0f]]
                setTextColor:[UIColor whiteColor]]
               setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];*/
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
                [alert setContainerView: [self createAlertView]];
                [alert setButtonTitles:[NSArray arrayWithObject:@"Dismiss"]];
                [alert show];
            }else{
                
            UIAlertView *alertDialog;
            UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
            [imageView setImage:[UIImage imageNamed:@"redX@2x.png"]];
            
            
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"    Unauthorized Access"
                           message:@"You do not have permission to build!"
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog addSubview:imageView];
            [alertDialog show];
            }
        }else if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {

                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:@"Server Error or Unavailable, Please logout!"
                               delegate: self
                               cancelButtonTitle: @"Dismiss"
                               otherButtonTitles: @"Logout", nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
        }else{
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Check your internet connection."
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
    }];
    
}

- (void) loggingIn:(NSInteger)type{
    
    
    //Initialize httpClient
    AFHTTPClient *myclient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [myclient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [myclient setDefaultHeader:@"Accept" value:@"application/json"];
    [myclient setDefaultHeader:@"X-Atlassian-Token" value:@"nocheck"];
    [myclient setParameterEncoding:AFJSONParameterEncoding];
    
    NSString *viewURL = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        viewURL = [[NSString alloc] initWithFormat:@"/rest/addteqrest/1.0/check.json"];
    }
    else {
        // NSLog(@"path %@",path);
        viewURL = [[NSString alloc] initWithFormat:@"%@/rest/addteqrest/1.0/check.json", path];
    }
    //viewURL = [[NSString alloc] initWithFormat:@"/rest/addteqrest/1.0/check.json"];
    
    // NSLog( @"viewURL=%@", viewURL);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BambooLogin" accessGroup:nil];
    NSString *user = [userDefaults stringForKey:kUsername];
    NSString *password = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
    [myclient setAuthorizationHeaderWithUsername:user password:password];
    [myclient getPath:viewURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* json = responseObject;
        NSString* check = [json objectForKey:@"check-code"];
        NSRange checkRange = [check rangeOfString:@"success"];
        if (checkRange.location != NSNotFound) {
            // NSLog(@"SUCCESS LOGING IN");
            [self retryBuilding];
        }else{
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Server Error or Unavailable, Please logout!"
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // NSLog(@"FAIL to LOG IN");
        if([error.description rangeOfString:@"ErrorDomain Code=-1001"].location != NSNotFound){
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Request Timed out. Please try again."
                           delegate: self
                           cancelButtonTitle: @"Retry"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }else if((myclient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (myclient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:@"Server Error or Unavailable, Please logout!"
                               delegate: self
                               cancelButtonTitle: @"Dismiss"
                               otherButtonTitles: @"Logout", nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        }else{
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Check your internet connection."
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
    }];
}
- (BOOL)shouldAutomaticallyForwardRotationMethods{
    return NO;
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIView *) createAlertView{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 80)];
    demoView.layer.cornerRadius = 8.0f;
    demoView.layer.masksToBounds = YES;
    demoView.backgroundColor = [UIColor clearColor];
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
    [imageView setImage:[UIImage imageNamed:@"redX@2x.png"]];
    [demoView addSubview:imageView];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 250, 30)];
    title.text = @"Unauthorized Access";
    title.textColor = [UIColor blackColor];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    title.numberOfLines = 0;
    [demoView addSubview:title];
    UILabel *lblShare= [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 260, 30)];
    lblShare.text=@"You do not have permission to build";
    lblShare.numberOfLines=2;
    lblShare.textColor =[UIColor blackColor];
    lblShare.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    //lblShare.font = [UIFont systemFontOfSize:14];
    lblShare.backgroundColor =[UIColor clearColor];
    [demoView addSubview:lblShare];
    return  demoView;
}

@end
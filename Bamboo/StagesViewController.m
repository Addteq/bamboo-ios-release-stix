//
//  StagesViewController.m
//  Bamboo
//
//  Created by You Liang Low on 11/27/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#define kBamboo @"bamboo_url"
#define kPort @"port_num"
#define kHttp @"http"
#define kBasePath @"baseWithPath"

#import "MBProgressHUD.h"
#import "StagesViewController.h"
#import "LogViewController.h"
#import "NaviController.h"
#import "CustomIOS7AlertView.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface StagesViewController ()
- (void)configureView;

@end

@implementation StagesViewController
@synthesize stagesDictionary;
@synthesize stageArray;
@synthesize stageNameArray;
@synthesize stageKeyArray;
@synthesize planNameArray;
@synthesize resultsDictionary;
@synthesize resultArray;
@synthesize numStages;
@synthesize buildState;
@synthesize buildStateBackground;
@synthesize buildStateBackground1;
@synthesize buildStateString;
@synthesize buildNum;
@synthesize buildNumString;
@synthesize buildKey;
@synthesize planKey;
@synthesize server;
@synthesize path;
@synthesize client;
@synthesize hud;
@synthesize tableview;
@synthesize menuButton;
@synthesize actionSh;
@synthesize relogintype;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      // Custom initialization
   }
   return self;
}

#pragma mark - Managing the detail item
- (void)configureView
{
   // Update the user interface for the detail item.
   if([buildStateString isEqualToString:@"Successful"]){
      UIImage *image = [UIImage imageNamed: @"GreenWhite@2x.png"];
       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
       {
           image = [UIImage imageNamed: @"GreenWhite@2x.png"];
       }
//      UIImage *background = [UIImage imageNamed: @"light_green.png"];
      UIImage *background1 = [UIImage imageNamed: @"GreenBackground@2x.png"];
      buildState.image = image;
  //    buildStateBackground.image = background;
      buildStateBackground1.image = background1;
   }else if([buildStateString isEqualToString:@"Failed"]){
      UIImage *image = [UIImage imageNamed: @"ReddyWhite@2x.png"];
       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
       {
           image = [UIImage imageNamed: @"ReddyWhite@2x.png"];
       }
  //    UIImage *background = [UIImage imageNamed: @"light_red.png"];
      UIImage *background1 = [UIImage imageNamed: @"RedBackground@2x.png"];
      buildState.image = image;
 //     buildStateBackground.image = background;
      buildStateBackground1.image = background1;
   }else{
      UIImage *image = [UIImage imageNamed: @"YellowOrWhite@2x.png"];
       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
       {
           image = [UIImage imageNamed: @"YellowOrWhite@2x.png"];
       }
 //     UIImage *background = [UIImage imageNamed: @"YellowOrWhiteBackground@2x.png"];
      UIImage *background1 = [UIImage imageNamed: @"YellowOrWhiteBackground@2x.png"];
      buildState.image = image;
 //     buildStateBackground.image = background;
      buildStateBackground1.image = background1;
   }
   buildNum.text = buildNumString;
}

- (void)viewWillDisappear:(BOOL)animated{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if(self.actionSh.visible){
            [self.actionSh dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    if([[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.bug removeFromSuperview];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
   planNameArray = [[NSMutableArray alloc] init];
   stageNameArray = [[NSMutableArray alloc] init];
   stageArray = [[NSMutableArray alloc] init];
   stageKeyArray = [[NSMutableArray alloc] init];
   stagesDictionary = [[NSDictionary alloc] init];
   resultArray = [[NSMutableArray alloc] init];
   resultsDictionary = [[NSDictionary alloc] init];
    
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setDefaultHeader:@"X-Atlassian-Token" value:@"nocheck"];
    [client setParameterEncoding:AFJSONParameterEncoding];

    //[self addBugIcon];
    CGRect viewframe = self.view.frame;
    viewframe.size.height = self.view.frame.size.height+44;
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    self.view.frame = viewframe;

    [self parseStages];
      [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated{
    if(![[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.navigationController.toolbar addSubview:self.bug];
    }
    [super viewWillAppear:animated];
}

- (void) parseStages {
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud setLabelText:@"Loading..."];
    hud.dimBackground = YES;
    [hud show:YES];
    
    NSString *stagesURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=stages.stage.results.result", buildKey];
    NSString *stagesPath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        stagesPath = [[NSString alloc] initWithFormat:@"%@", stagesURL];
    }
    else {
        stagesPath = [[NSString alloc] initWithFormat:@"%@%@", path, stagesURL];
    }
    /*
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *each in cookies) {
        // NSLog(@"delete Cookie:%@", [each description]);
        [cookieStorage deleteCookie:each];
    }
    */
    [client getPath:stagesPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"SUCCESS");
        //Get stages dictionary
        stagesDictionary = [responseObject objectForKey:@"stages"];
        
        //Get number of stages
        numStages = [stagesDictionary objectForKey:@"size"];
        
        //parse json for stages
        stageArray = [stagesDictionary objectForKey:@"stage"];
        
        int i = 0;
        
        for(i = 0; i < [stageArray count]; i++) {
            NSString *stageName = [stageArray[i] objectForKey:@"name"];
            
            //add stage name to array
            [stageNameArray addObject:stageName];
            
            
            
            //get results dictionary
            resultsDictionary = [stageArray[i] objectForKey:@"results"];
            
            //get result array
            resultArray = [resultsDictionary objectForKey:@"result"];
            
            int i = 0;
            for(i = 0; i < [resultArray count]; i++) {
                //get key from result object
                NSString *stageKey = [resultArray[i] objectForKey:@"key"];
                NSString *planName = [resultArray[i] objectForKey:@"planName"];
                //add stage key to array
                [stageKeyArray addObject:stageKey];
                [planNameArray addObject:planName];
                
            }
        }
        
        
        [self.tableview reloadData];
        [self configureView];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // NSLog(@"fAIL");
        if ([operation.response statusCode] == 401) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *guest = [userDefaults stringForKey:@"guest"];
            
            if([guest isEqualToString:@"guest"]){
                // NSLog(@"GUEST LOGIN");
                [self getSessionID];
                [self retryParseStages];
            }else{
                // NSLog(@"NOT GUEST");
                /*
                 KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BambooLogin" accessGroup:nil];
                 NSString *user = [userDefaults stringForKey:kUsername];
                 NSString *password = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
                 [client setAuthorizationHeaderWithUsername:user password:password];
                 */
                [self loggingIn:0];
            }
            
            
        }
        else if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
    [hud show:NO];
}
- (void) getSessionID{
    NSString *base = server;
    NSURL *originalUrl=[NSURL URLWithString:base];
    NSData *data=nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLResponse *response;
    NSError *error;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

- (void) retryParseStages{
    
    NSString *stagesURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=stages.stage.results.result", buildKey];
    NSString *stagesPath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        stagesPath = [[NSString alloc] initWithFormat:@"%@", stagesURL];
    }
    else {
        stagesPath = [[NSString alloc] initWithFormat:@"%@%@", path, stagesURL];
    }
    
    
    [client getPath:stagesPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //Get stages dictionary
        stagesDictionary = [responseObject objectForKey:@"stages"];
        
        //Get number of stages
        numStages = [stagesDictionary objectForKey:@"size"];
        
        //parse json for stages
        stageArray = [stagesDictionary objectForKey:@"stage"];
        
        int i = 0;
        
        for(i = 0; i < [stageArray count]; i++) {
            NSString *stageName = [stageArray[i] objectForKey:@"name"];
            
            //add stage name to array
            [stageNameArray addObject:stageName];
            
            
            
            //get results dictionary
            resultsDictionary = [stageArray[i] objectForKey:@"results"];
            
            //get result array
            resultArray = [resultsDictionary objectForKey:@"result"];
            
            int i = 0;
            for(i = 0; i < [resultArray count]; i++) {
                //get key from result object
                NSString *stageKey = [resultArray[i] objectForKey:@"key"];
                NSString *planName = [resultArray[i] objectForKey:@"planName"];
                //add stage key to array
                [stageKeyArray addObject:stageKey];
                [planNameArray addObject:planName];
                
            }
        }
        /*
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookies];
        for (NSHTTPCookie *each in cookies) {
            // NSLog(@"new Cookie:%@", [each description]);
        }
        */
        [self.tableview reloadData];
        [self configureView];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
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
    [hud show:NO];
}


- (void)didReceiveMemoryWarning
{
    [self setActionSh:nil];
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   // Return the number of sections.
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // Return the number of rows in the section.
   
   return [numStages integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
   
   static NSString *CellIdentifier = @"stageCell";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
   // Configure the cell...
   if([stageNameArray count] == 1){
      cell.textLabel.text = stageNameArray[indexPath.row];
      tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   }else{
      cell.textLabel.text = stageNameArray[indexPath.row];
   }
   return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (IBAction)showActionSheet:(id)sender {
    [menuButton setEnabled:NO];
   NSString *actionSheetTitle = @"Stages"; //Action Sheet Title
                                         //Action Sheet Button Titles
    NSString *helpTitle = @"Help";
   NSString *logout = @"Logout";
   NSString *build = @"Start Build";
   UIActionSheet *actionSheet = nil;
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   NSString *guest = [userDefaults stringForKey:@"guest"];
   if ([guest isEqualToString:@"guest"]) {
      //Hide play button
      actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:logout
                                       otherButtonTitles:helpTitle, nil];
   }else{
      actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                delegate:self
                                       cancelButtonTitle:nil
                                  destructiveButtonTitle:logout
                                       otherButtonTitles:build, nil];
       
       int i;
       for(i = 0; i < [planNameArray count]; i++) {
           //NSString *title = [stageKeyArray objectAtIndex:i];
           NSString *planName = [planNameArray objectAtIndex:i];
           //// NSLog(@"Button title:%@, index:%d", planName, i);
           [actionSheet addButtonWithTitle:planName];
           //// NSLog(@"Number of buttons %d", actionSheet.numberOfButtons);
       }
       [actionSheet addButtonWithTitle:helpTitle];
       [actionSheet addButtonWithTitle:@"Cancel"];
       [actionSheet setCancelButtonIndex:[planNameArray count]+3];
       //actionSheet.cancelButtonIndex = (actionSheet.numberOfButtons)-1;
       //// NSLog(@"Cancel Button Index:%d", actionSheet.cancelButtonIndex);
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
   //[actionSheet showFromToolbar:self.navigationController.toolbar];
   
   
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [menuButton setEnabled:YES];
        
    }
    if(buttonIndex==-1)
    {
        // NSLog(@"Touch outside");
        //[actionSheet showInView:[self.view window]];
    }
    
    else
    {
   //// NSLog(@"Button title:%@, index:%d", buttonTitle, buttonIndex);
        //Get the name of the current pressed button
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        //if ([buttonTitle isEqualToString:@"Cancel"]) {
            //// NSLog(@"Cancel clicked");
        //}else
        if ([buttonTitle isEqualToString:@"Logout"]) {
            [client clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if ([buttonTitle isEqualToString:@"Start Build"]) {
            //       // NSLog(@"Start Build Button index:%d", buttonIndex);
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
        }else if ([buttonTitle isEqualToString:@"Help"]) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen shows you the stages of the selected plan. From this screen you can view the logs of a particular job or start a new build for this plan."
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }else{
            //// NSLog(@"Button Clicked:%@", buttonTitle);
            // default Job
            if(buttonIndex < ([planNameArray count] + 2)) {
                if (buttonIndex >= 2) {
                    buttonIndex = buttonIndex - 2;
                }
                NSString *tempJobKey = nil;
                NSString *tempJobBuildKey = nil;
                NSString *tempPlanName = nil;
                
                //Get stage name for job key in log view controller
                LogViewController *logvc = [[LogViewController alloc] init];
                if(buttonIndex < [stageNameArray count]) {
                    tempJobKey = [stageNameArray objectAtIndex:buttonIndex];
                }
                
                //Get stage key for job  build key in log view controller
                if(buttonIndex < [stageKeyArray count]) {
                    tempJobBuildKey = [stageKeyArray objectAtIndex:buttonIndex];
                }
                
                if(buttonIndex < [planNameArray count]) {
                    tempPlanName = [planNameArray objectAtIndex:buttonIndex];
                }
                NSString *jobTitle = [planNameArray objectAtIndex:buttonIndex];
                //// NSLog(@"Job Title:%@", jobTitle);
                
                if ([buttonTitle isEqualToString:jobTitle]) {
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                        logvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"log"];
                    }
                    else {
                        UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                        logvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"log"];
                    }
                    
                    //              // NSLog(@"Job Key %@", tempJobKey);
                    //              // NSLog(@"Job Build Key %@", tempJobBuildKey);
                    logvc.planKey = planKey;
                    logvc.server = server;
                    logvc.path = path;
                    logvc.jobKey = tempJobKey;
                    logvc.jobBuildKey = tempJobBuildKey;
                    [self.navigationController pushViewController:logvc animated:YES];
                }
            }
        }
    }
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
   if([title isEqualToString:@"Yes"])
   {
      //Start Build here.
      //Post to queue URL - rest/api/latest/queue
      NSString *planURL = nil;
      
      if([path isKindOfClass:[NSNull class]] || path == NULL) {
         planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
      }else{
         planURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/queue/%@", path, planKey];
      }
       
       if((client.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown)) {
           
           //Check if host can be reached first, before making request
           [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Cannot connect to Server" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
       }
       else {
         
           
           [client postPath: planURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               NSString *result = [responseObject description];
               if (![result isKindOfClass:[NSNull class]]) {
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
                   // NSLog(@"operation %@",operation.response );
                   // NSLog(@"error %@",error.description );
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
                   
                   
               }
              else if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
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
   
   
    if([title isEqualToString:@"Try Again"]) {
        [self parseStages];
    }else if([title isEqualToString:@"Retry"]){
        
        
        if(self.relogintype==0){
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:hud];
            hud.dimBackground = YES;
            hud.labelText = @"Loading...";
            [hud show:YES];
        }
        
        [self loggingIn:self.relogintype];
    }
    if([title isEqualToString:@"Cancel"]) {
        return;
    }
    if([title isEqualToString:@"Dismiss"]) {
        return;
    }
    if([title isEqualToString:@"Logout"]) {
        [client clearAuthorizationHeader];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
            [cookieStorage deleteCookie:each];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
   else if([title isEqualToString:@"No"])
   {
      [alertView dismissWithClickedButtonIndex:1 animated:NO];
   }
   
}


- (IBAction)showFeedback:(id)sender {
   [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
}

- (void) addBugIcon{
    UIToolbar *toolbar = ((NaviController *)self.parentViewController).toolbar;
    [toolbar setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    toolbar.clipsToBounds=YES;
    self.bug = [UIButton buttonWithType:UIButtonTypeCustom];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.bug.frame = CGRectMake(731,10,28,28);
    }else{
        self.bug.frame = CGRectMake(282,10,28,28);
    }

    [self.bug setImage:[UIImage imageNamed:@"blueBug.png"] forState:UIControlStateNormal];
    [self.bug addTarget:self action:@selector(showFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:self.bug];
}

- (void) loggingIn:(NSInteger)type{
    
    //Initialize httpClient
    AFHTTPClient *myclient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [myclient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [myclient setDefaultHeader:@"Accept" value:@"application/json"];
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
            
            if(type==0){
                // testing session id time out by deleting cookie.
     //$           NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //$            for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
                    //// NSLog(@"Cookie %@", [each value]);
 //$               }
                
                [self retryParseStages];
            }else{
                [self retryBuilding];
            }

        }else{
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
        
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
    [hud show:NO];
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
        [hud hide:YES];
        if ([operation.response statusCode] == 401) {
           /* [[[[[[iToast makeText:@" Unauthorized Access\n You do not have permission to build  "]
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

//
//  SavedLogsViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 12/26/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import "SavedLogsViewController.h"
#import "NaviController.h"
#import "CustomIOS7AlertView.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@implementation SavedLogsViewController
@synthesize arrayOfLogs;
@synthesize dirPath;
@synthesize client;
@synthesize server;
@synthesize path;
@synthesize planKey;
@synthesize menuButton;
@synthesize actionSh;
@synthesize bug;


- (id)initWithStyle:(UITableViewStyle)style
{
   self = [super initWithStyle:style];
   if (self) {
      // Custom initialization
   }
   return self;
}


- (void)viewDidLoad
{
   [super viewDidLoad];
    //[self addBugIcon];
   // Uncomment the following line to preserve selection between presentations.
   self.clearsSelectionOnViewWillAppear = YES;
   arrayOfLogs = [[NSMutableArray alloc] initWithArray:[self listFileAtPath:dirPath]];
   self.tableView.tableFooterView = [[UIView alloc] init];
    
    
    CGRect tableviewframe = self.tableView.frame;
    tableviewframe.size.height = self.tableView.frame.size.height+44;
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    self.tableView.frame = tableviewframe;

    
}

-(void) viewWillAppear:(BOOL)animated{
    if(![[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.navigationController.toolbar addSubview:self.bug];
    }
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(self.actionSh.visible){
            [self.actionSh dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    if([[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.bug removeFromSuperview];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

-(NSArray *)listFileAtPath:(NSString *)filePath
{
   //-----> LIST ALL FILES <-----//
   // NSLog(@"LISTING ALL FILES FOUND");
   
   int count;
   
   NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:NULL];
   if ([directoryContent count] == 0) {
   }else{
      for (count = 0; count < (int)[directoryContent count]; count++)
      {
//         // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
      }
   }
   return directoryContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   // Return the number of sections.
   if ([arrayOfLogs count] == 0) {
      return 1;
   }else{
      return 1;
   }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // Return the number of rows in the section.
   if ([arrayOfLogs count] == 0) {
      return 1;
   }else{
      return [arrayOfLogs count];
   }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"logFileName";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   
   // Configure the cell...
   if ([arrayOfLogs count] == 0) {
      cell.textLabel.text = @"No Saved Logs";
      cell.userInteractionEnabled = NO;
      tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   }else{
      cell.textLabel.text = arrayOfLogs[indexPath.row];
   }
   return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Return NO if you do not want the specified item to be editable.
   if ([arrayOfLogs count] == 0) {
      return NO;
   }else{
      return YES;
   }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (editingStyle == UITableViewCellEditingStyleDelete) {
      // Delete the row from the data source
      //Remove file from phone
      NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@", dirPath, arrayOfLogs[indexPath.row]];
      NSFileManager *fileManager = [NSFileManager defaultManager];
      if ([fileManager fileExistsAtPath:filePath])
      {
         NSError *error;
         if (![fileManager removeItemAtPath:filePath error:&error])
         {
            // NSLog(@"Error removing file: %@", error);
         }
         //Remove file from array
         if ([arrayOfLogs count] == 1) {
            [arrayOfLogs removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
         }else{
            [arrayOfLogs removeObjectAtIndex:indexPath.row];
            //Remove row from table
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         }
      }
   }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   //Open Selected Log in External Text Editor
   if ([arrayOfLogs count] == 0) {
      //Don't try to open anything
   }else{
      NSString *logFilePath = [[NSString alloc] initWithFormat:@"%@/%@", dirPath, arrayOfLogs[indexPath.row]];
      // NSLog(@"Opening file in text editor");
      UIDocumentInteractionController *documentController = [[UIDocumentInteractionController alloc] init];
      documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:logFilePath]];
      
      documentController.delegate = self;
      
      documentController.UTI = @"public.plain-text";
      //[documentController presentOpenInMenuFromRect:CGRectZero
      //                                       inView:self.view
      //                                     animated:YES];
        [documentController presentPreviewAnimated:YES];
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
   }
}

//Document interaction controller part
- (UIDocumentInteractionController*) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id<UIDocumentInteractionControllerDelegate>) interactionDelegate {
   
   UIDocumentInteractionController *interactionController =
   [UIDocumentInteractionController interactionControllerWithURL:fileURL];
   
   interactionController.delegate = interactionDelegate;
   
   return interactionController;
}
-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
   
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
   
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
   
}
#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
	return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
	return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
	return self.view.frame;
}



- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Retry"]){
        [self loggingIn:1];
    }
}


- (IBAction)showActionSheet:(id)sender {
   UIActionSheet *actionSheet;
    [menuButton setEnabled:NO];
   //Action Sheet Title
   NSString *actionSheetTitle = @"Saved Logs";
   //Action Sheet Button Titles
   NSString *logout = @"Logout";
   NSString *cancelTitle = @"Cancel";
    NSString *helpTitle = @"Help";
   //NSString *build = @"Start Build";
   actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                             delegate:self
                                    cancelButtonTitle:cancelTitle
                               destructiveButtonTitle:logout
                                    otherButtonTitles: helpTitle, nil];
   [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
   
   
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      actionSheet.cancelButtonIndex = -1;
   }
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
        //Get the name of the current pressed button
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"Cancel"]) {
            //// NSLog(@"Cancel clicked");
        }else if ([buttonTitle isEqualToString:@"Start Build"]){
            //Start Build here.
            //Post to queue URL - rest/api/latest/queue
            NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
            
            if([path isKindOfClass:[NSNull class]] || path == NULL) {
                planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
            }else{
                planURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/queue/%@", path, planKey];
            }
            
            client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
            [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
            [client setDefaultHeader:@"Accept" value:@"application/json"];
            [client setDefaultHeader:@"X-Atlassian-Token" value:@"nocheck"];
            [client setParameterEncoding:AFJSONParameterEncoding];
            
            if((client.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown)) {
                
                //Check if host can be reached first, before making request
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Cannot connect to Server" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                
                
            }
            else {
                
                
                                  
                [client postPath:planURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
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
                            // NSLog(@"Loggin in again");
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
            
        }else if ([buttonTitle isEqualToString:@"Logout"]) {
            [client clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if([buttonTitle isEqualToString:@"Help"]){
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen shows you the logs stored on your device. You can open these logs in an external text editor by selecting which log you would like to view. You can also delete these logs by swiping to the right on the log you would like to delete."
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
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
    [self.bug addTarget:self action:@selector(leaveFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:self.bug];
}

- (IBAction)leaveFeedback:(id)sender {
   [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
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
        }
        else if((myclient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (myclient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
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

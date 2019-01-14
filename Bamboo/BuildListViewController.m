//
//  BuildListViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 11/5/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import "BuildListViewController.h"
#import "BuildInfoViewController.h"
#import "BuildSummaryViewController.h"
#import "ProjectViewController.h"
#import "BuildItem.h"
#import "BuildListCell.h"
#import "NaviController.h"
#import "CustomIOS7AlertView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface BuildListViewController ()

@end

@implementation BuildListViewController

@synthesize arrayOfBuilds;
@synthesize refresh;
@synthesize planKey;
@synthesize server;
@synthesize path;
@synthesize hud;
@synthesize client;
@synthesize projectName;
@synthesize menuButton;
@synthesize actionSheetDismiss;
@synthesize bug;
@synthesize relogintype;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)loadView {
    [super loadView];
    CGRect newframe = self.view.frame;
    newframe.size.height = [UIScreen mainScreen].bounds.size.height+44;
    self.view.frame = newframe;
    [self.view setAutoresizesSubviews:YES];
}

-(void)viewDidLoad
{
    //[self addBugIcon];
    refresh = 0;
    arrayOfBuilds = [[NSMutableArray alloc] init];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing Data..."];
    [refreshControl addTarget:self action:@selector(refreshView:)
             forControlEvents:UIControlEventValueChanged];
    
    // Assign control to the tableview
    [self setRefreshControl: refreshControl];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.dimBackground = YES;
    hud.labelText = @"Loading...";
    [hud show:YES];

    dispatch_queue_t parseBuildThread = dispatch_queue_create("parseBuildThread",NULL);
    dispatch_async(parseBuildThread, ^(void){
        [self parsePlanAndArtifact];

//        dispatch_queue_t parseArtifat = dispatch_queue_create("parseArtifat",NULL);
//        dispatch_async(parseArtifat, ^(void){
     //   });
    });
    
    [super viewDidLoad];
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.title = projectName;
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.detailViewController = (BuildInfoViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)parsePlanAndArtifact {
    [self parseBuilds];
    [self parseArtifats];
}

- (void) viewWillAppear:(BOOL)animated {
    if(![[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.navigationController.toolbar addSubview:self.bug];
    }
    [self refreshView:self.refreshControl];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(self.actionSheetDismiss.visible) {
            [self.actionSheetDismiss dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    if([[self.navigationController.toolbar subviews] containsObject:self.bug]) {
        [self.bug removeFromSuperview];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Refresh TableView
- (void)refreshView:(UIRefreshControl *)refreshControl {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    // custom refresh logic would be placed here...
    //    hud = [[MBProgressHUD alloc] initWithView:self.view];
    //    hud.labelText = @"Getting Build List...";
    //    hud.detailsLabelText = @"Just relax";
    //    hud.dimBackground = YES;
    //    [self.view addSubview:hud];
    //    [hud showWhileExecuting:@selector(parseBuilds) onTarget:self withObject:nil animated:YES];
    //    hud.dimBackground = NO;
    
    if(client.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || client.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        
    } else {
    //    [self parseBuilds];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [self.refreshControl endRefreshing];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayOfBuilds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BuildListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buildCell" forIndexPath:indexPath];
    
    if((indexPath.row < [arrayOfBuilds count]) && (arrayOfBuilds != nil)) {
        NSString *buildNum = [NSString stringWithFormat:@"%@", [arrayOfBuilds[indexPath.row] getNumber]];
        cell.buildNum.text = buildNum;
        NSString *buildTime = [NSString stringWithFormat:@"%@", [arrayOfBuilds[indexPath.row] getRelativeTime]];
        
        if ([buildTime isEqualToString:@""]) {
            cell.buildTime.text = @"Unavailable";
        } else {
            cell.buildTime.text = buildTime;
        }
        
        NSString *buildReason = [NSString stringWithFormat:@"%@", [arrayOfBuilds[indexPath.row] getReason]];
        cell.buildReason.text = buildReason;
        NSString *buildState = [NSString stringWithFormat:@"%@", [arrayOfBuilds[indexPath.row] getState]];
        
        if ([buildState isEqualToString:@"Successful"]) {
            UIImage *image = [UIImage imageNamed: @"Green@2x.png"];
            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                image = [UIImage imageNamed: @"success_ipad.png"];
//            }
            
            cell.buildImage.image = image;
            _customBugIcon = [UIImage imageNamed:@"bugGreenL"];
            // NSLog(@"Green Bug");
            _bugColor = @"Green Bug";
        } else if([buildState isEqualToString:@"Failed"]) {
            UIImage *image = [UIImage imageNamed: @"redX@2x.png"];
            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                image = [UIImage imageNamed: @"failure_ipad.png"];
//            }
            
            cell.buildImage.image = image;
            _customBugIcon = [UIImage imageNamed:@"bugRedL.png"];
            // NSLog(@"Red Bug");
            _bugColor = @"Red Bug";
        } else {
            UIImage *image = [UIImage imageNamed: @"YellowOr@2x.png"];
            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                image = [UIImage imageNamed: @"YellowOr@2x.png"];
//            }
            
            cell.buildImage.image = image;
            _customBugIcon = [UIImage imageNamed:@"bugYellowL.png"];
            // NSLog(@"Yellow Bug");
            _bugColor = @"Yellow bug";
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BuildInfoViewController *detail = segue.destinationViewController;
        detail.buildArray = arrayOfBuilds;
        detail.planKey = planKey;
        detail.index = indexPath.row;
        detail.server = server;
        detail.path = path;
        BuildInfoViewController *pushImage = (BuildInfoViewController *)segue.destinationViewController;
        pushImage.hidesBottomBarWhenPushed = YES;
        // [self.navigationController pushViewController:pushImage animated:YES];
    }
}

#pragma mark - Fetch Data

- (void)parseBuilds {
    if (refresh != 0) {
        [arrayOfBuilds removeAllObjects];
    }
    else {
        
    }
    //Will need to get plankey for url
    NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=results.result", planKey];
    
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setDefaultHeader:@"X-Atlassian-Token" value:@"nocheck"];
    [client setParameterEncoding:AFJSONParameterEncoding];
    NSString *planPath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        planPath = [[NSString alloc] initWithFormat:@"%@", planURL];
    } else {
        planPath = [[NSString alloc] initWithFormat:@"%@%@",path, planURL];
    }

    [client getPath:planPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL isResponseDict = [responseObject isKindOfClass:[NSDictionary class]];
        
        if (isResponseDict == 1) {
        NSDictionary* json = responseObject;
        NSDictionary* results = [json objectForKey:@"results"];
        NSArray* result = [results objectForKey:@"result"];
        int i = 0;
        for (i=0; i<[result count]; i++) {
            NSString *key = [result[i] objectForKey:@"key"];
            NSString *number = [result[i] objectForKey:@"number"];
            NSString *revision = [result[i] objectForKey:@"vcsRevisionKey"];
            NSString *prettyTime = [result[i] objectForKey:@"prettyBuildCompletedTime"];
            NSString *durationDesc = [result[i] objectForKey:@"buildDurationDescription"];
            NSString *relativeTime = [result[i] objectForKey:@"buildRelativeTime"];
            NSString *durationSeconds = [result[i] objectForKey:@"buildDurationInSeconds"];
            NSString *reason = [result[i] objectForKey:@"buildReason"];
            NSString *state = [result[i] objectForKey:@"state"];
            BuildItem *item = [[BuildItem alloc] init];
            [item setKey:key];
            [item setNumber:number];
            [item setRevision:revision];
            [item setPrettyTime:prettyTime];
            [item setDurationDesc:durationDesc];
            [item setRelativeTime:relativeTime];
            [item setDurationSeconds:durationSeconds];
            NSMutableString *html = [NSMutableString stringWithCapacity:[reason length]];
            NSScanner *scanner = [NSScanner scannerWithString:reason];
            scanner.charactersToBeSkipped = NULL;
            NSString *tempText = nil;
            
            while (![scanner isAtEnd]) {
                [scanner scanUpToString:@"<" intoString:&tempText];
                
                if (tempText != nil)
                    [html appendString:tempText];
                [scanner scanUpToString:@">" intoString:NULL];
                if (![scanner isAtEnd])
                    [scanner setScanLocation:[scanner scanLocation] + 1];
                tempText = nil;
            }
            //this may need to be fixed...problem with bamboo.addteq.com
            NSRange htmlTag = [html rangeOfString:@" &lt;"];
            if (htmlTag.location != NSNotFound) {
                NSString *subString = [html substringToIndex:htmlTag.location];
                [item setReason:subString];
            } else {
                [item setReason:html];
            }
            [item setState:state];
            [arrayOfBuilds addObject:item];
        }
        refresh++;
        NSString *artURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=results.result.artifacts", planKey];
        NSString *artPath = nil;
        
        if([path isKindOfClass:[NSNull class]] || path == NULL) {
            artPath = [[NSString alloc] initWithFormat:@"%@", artURL];
        } else {
            artPath = [[NSString alloc] initWithFormat:@"%@%@", path, artURL];
        }
            
        } else {
            // calling ParseBuild again if responseObject is not of dictionary - because response from server sometimes is not of json format. Its problem with framework or delegate class.
            //[self parseBuilds];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] == 401) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *guest = [userDefaults stringForKey:@"guest"];
            
            if([guest isEqualToString:@"guest"]) {
                [self getSessionID];
                [self retryParseBuilds];
            } else {
                [self loggingIn:0];
            }
        } else {
            if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
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
             } else {
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
        }
    }];
}

- (void)parseArtifats {
    if (refresh != 0) {
        [arrayOfBuilds removeAllObjects];
    } else {
        
    }
    //Will need to get plankey for url
    NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=results.result", planKey];
    
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setDefaultHeader:@"X-Atlassian-Token" value:@"nocheck"];
    [client setParameterEncoding:AFJSONParameterEncoding];
    NSString *planPath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        planPath = [[NSString alloc] initWithFormat:@"%@", planURL];
    } else {
        planPath = [[NSString alloc] initWithFormat:@"%@%@",path, planURL];
    }
    
    NSString *artURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=results.result.artifacts", planKey];
    NSString *artPath = nil;
    
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        artPath = [[NSString alloc] initWithFormat:@"%@", artURL];
    } else {
        artPath = [[NSString alloc] initWithFormat:@"%@%@", path, artURL];
    }
    
    [client getPath:artPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL isResponseDict = [responseObject isKindOfClass:[NSDictionary class]];
        if (isResponseDict == 1) {
            NSDictionary* json = responseObject;
            //parse json for results
            NSDictionary* results = [json objectForKey:@"results"];
            //get result array from results
            NSArray* result = [results objectForKey:@"result"];
            NSInteger i;
            if (![arrayOfBuilds count] == 0 ) {
                for (i=0; i<[result count]; i++) {
                    NSDictionary *artifacts = [result[i] objectForKey:@"artifacts"];
                    NSArray *artifact = [artifacts objectForKey:@"artifact"];
                    BuildItem *item = arrayOfBuilds[i];
                    NSMutableArray *arrayOfArtifacts = [[NSMutableArray alloc] initWithCapacity:[artifact count]];
                    NSInteger j;
                    for (j=0; j<[artifact count]; j++) {
                        NSString *artName = [artifact[j] objectForKey:@"name"];
                            [arrayOfArtifacts addObject:artName];
                        }
                        item.artifacts = arrayOfArtifacts;
                }
            } else {
                    //[self parsePlanAndArtifact];
            }
        } else {
                // calling ParseBuild again if responseObject is not of dictionary - because response from server sometimes is not of json format. Its problem with framework or delegate class.
                //[self parseArtifats];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
        
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
            }
    }];
}

- (void)retryParseBuilds {
    NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=results.result", planKey];
    
    NSString *planPath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        
        planPath = [[NSString alloc] initWithFormat:@"%@", planURL];
    } else {
        planPath = [[NSString alloc] initWithFormat:@"%@%@",path, planURL];
    }
    
    [client getPath:planPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* json = responseObject;
        NSDictionary* results = [json objectForKey:@"results"];
        NSArray* result = [results objectForKey:@"result"];
        NSInteger i = 0;
        for (i=0; i<[result count]; i++) {
            NSString *key = [result[i] objectForKey:@"key"];
            NSString *number = [result[i] objectForKey:@"number"];
            NSString *revision = [result[i] objectForKey:@"vcsRevisionKey"];
            NSString *prettyTime = [result[i] objectForKey:@"prettyBuildCompletedTime"];
            NSString *durationDesc = [result[i] objectForKey:@"buildDurationDescription"];
            NSString *relativeTime = [result[i] objectForKey:@"buildRelativeTime"];
            NSString *durationSeconds = [result[i] objectForKey:@"buildDurationInSeconds"];
            NSString *reason = [result[i] objectForKey:@"buildReason"];
            NSString *state = [result[i] objectForKey:@"state"];
           
            BuildItem *item = [[BuildItem alloc] init];
            [item setKey:key];
            [item setNumber:number];
            [item setRevision:revision];
            [item setPrettyTime:prettyTime];
            [item setDurationDesc:durationDesc];
            [item setRelativeTime:relativeTime];
            [item setDurationSeconds:durationSeconds];
           
            NSMutableString *html = [NSMutableString stringWithCapacity:[reason length]];
            NSScanner *scanner = [NSScanner scannerWithString:reason];
            scanner.charactersToBeSkipped = NULL;
            NSString *tempText = nil;
            
            while(![scanner isAtEnd])
            {
                [scanner scanUpToString:@"<" intoString:&tempText];
                if (tempText != nil)
                    [html appendString:tempText];
                [scanner scanUpToString:@">" intoString:NULL];
                
                if (![scanner isAtEnd])
                    [scanner setScanLocation:[scanner scanLocation] + 1];
                tempText = nil;
            }
            //this may need to be fixed...problem with bamboo.addteq.com
            NSRange htmlTag = [html rangeOfString:@" &lt;"];
            if (htmlTag.location != NSNotFound) {
                NSString *subString = [html substringToIndex:htmlTag.location];
                [item setReason:subString];
            } else {
                [item setReason:html];
            }
            [item setState:state];
            [arrayOfBuilds addObject:item];
        } //end of for loop
        
        refresh++;
        NSString *artURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=results.result.artifacts", planKey];
        NSString *artPath = nil;
        
        if([path isKindOfClass:[NSNull class]] || path == NULL) {
            artPath = [[NSString alloc] initWithFormat:@"%@", artURL];
        } else {
            artPath = [[NSString alloc] initWithFormat:@"%@%@", path, artURL];
        }
        
        [client getPath:artPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary* json = responseObject;
            //parse json for results
            NSDictionary* results = [json objectForKey:@"results"];
            //get result array from results
            NSArray* result = [results objectForKey:@"result"];
            int i;
            for (i=0; i<[result count]; i++) {
                NSDictionary *artifacts = [result[i] objectForKey:@"artifacts"];
                NSArray *artifact = [artifacts objectForKey:@"artifact"];
                BuildItem *item = arrayOfBuilds[i];
                NSMutableArray *arrayOfArtifacts = [[NSMutableArray alloc] initWithCapacity:[artifact count]];
                int j;
                for (j=0; j<[artifact count]; j++) {
                    NSString *artName = [artifact[j] objectForKey:@"name"];
                    [arrayOfArtifacts addObject:artName];
                }
                item.artifacts = arrayOfArtifacts;
            }
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
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
            }
        }];
        
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
        } else {
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

- (void) getSessionID {
    NSString *base = server;
    NSURL *originalUrl=[NSURL URLWithString:base];
    NSData *data=nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLResponse *response;
    NSError *error;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

#pragma mark - UI Buttons
- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet;
    [menuButton setEnabled:NO];
    //Action Sheet Title
    NSString *actionSheetTitle = @"Build List";
    //Action Sheet Button Titles
    NSString *build = @"Start Build";
    NSString *logout = @"Logout";
    NSString *summary = @"Plan Summary";
    NSString *helpTitle=@"Help";
    NSString *cancelTitle = @"Cancel";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    // Guest Login Code not Needed -
    NSString *guest = [userDefaults stringForKey:@"guest"];
    if ([guest isEqualToString:@"guest"]) {
        //Hide play button
        if([arrayOfBuilds count] == 0) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                      delegate:self
                                             cancelButtonTitle:cancelTitle
                                        destructiveButtonTitle:logout
                                             otherButtonTitles:helpTitle, nil];
        }
        else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                      delegate:self
                                             cancelButtonTitle:cancelTitle
                                        destructiveButtonTitle:logout
                                             otherButtonTitles:summary,helpTitle, nil];
        }
    } else {
        if([arrayOfBuilds count] == 0) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                      delegate:self
                                             cancelButtonTitle:cancelTitle
                                        destructiveButtonTitle:logout
                                             otherButtonTitles:build,helpTitle, nil];
        }
        else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                      delegate:self
                                             cancelButtonTitle:cancelTitle
                                        destructiveButtonTitle:logout
                                             otherButtonTitles:build, summary,helpTitle, nil];
        }
    }
    // Login code ends
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        actionSheet.cancelButtonIndex = -1;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (actionSheet.visible) {
            // if actionsheet is visible,,,,,,,,
            [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex
                                              animated:YES];
        } else {
            
            [actionSheet showFromBarButtonItem:sender animated:YES];
        }
    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
    self.actionSheetDismiss = actionSheet;
}

- (IBAction)showFeedback:(id)sender {
    [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [menuButton setEnabled:YES];
    }
    if(buttonIndex==-1) {
   
    } else {
        //Get the name of the current pressed button
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([buttonTitle isEqualToString:@"Plan Summary"]) {
            BuildSummaryViewController *bsvc = [[BuildSummaryViewController alloc] init];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                bsvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"buildSummary"];
            } else {
                UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                bsvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"buildSummary"];
            }
            bsvc.builds = arrayOfBuilds;
            bsvc.server = server;
            bsvc.path = path;
            bsvc.planKey = planKey;
            [self.navigationController pushViewController:bsvc animated:YES];
        } else if ([buttonTitle isEqualToString:@"Logout"]) {
            [client clearAuthorizationHeader];
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
                [cookieStorage deleteCookie:each];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else if ([buttonTitle isEqualToString:@"Start Build"]) {
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
        } else if ([buttonTitle isEqualToString:@"Help"]) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen displays up to the last 25 builds available for the selected plan. To change plans, please return to the Project List and select a different plan. From here, you can start a new build, view information of a previous build, or view the statistics of this plan."
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([buttonTitle isEqualToString:@"Try Again"]) {
        [self parseBuilds];
    } else if([buttonTitle isEqualToString:@"Retry"]) {
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
    }
    if ([buttonTitle isEqualToString:@"Yes"]){
        //Start Build here.
        //Post to queue URL - rest/api/latest/queue
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
                if (result != (id)[NSNull null]) {
                    [[[[iToast makeText:@" Successfully posted to build queue "]
                       setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
                } else {
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
}

- (void) retryBuilding{
    NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
    } else {
        planURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/queue/%@", path, planKey];
    }
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
            } else {
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
        } else if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
            
                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:@"Server Error or Unavailable, Please logout!"
                               delegate: self
                               cancelButtonTitle: @"Dismiss"
                               otherButtonTitles: @"Logout", nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
        } else {
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

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return NO;
}




- (BOOL)shouldAutorotate {
    return YES;
}

- (void)addBugIcon{
    UIToolbar *toolbar = ((NaviController *)self.parentViewController).toolbar;
   [toolbar setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    toolbar.clipsToBounds=YES;
    self.bug = [UIButton buttonWithType:UIButtonTypeCustom];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.bug.frame = CGRectMake(731,10,28,28);
    } else {
        self.bug.frame = CGRectMake(282,10,28,28);
    }
 
    [self.bug setImage:[UIImage imageNamed:@"blueBug.png"] forState:UIControlStateNormal];
    [self.bug addTarget:self action:@selector(showFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:self.bug];
}

- (void) loggingIn:(NSInteger)type{
        
    if(type==0){
        self.relogintype=0;
    } else {
        self.relogintype=1;
    }

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
            
            if(type==0){
                // testing session id time out by deleting cookie.
   //#             NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
   //#             for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
                    //// NSLog(@"Cookie %@", [each value]);
   //#             }

                [self retryParseBuilds];
            }else{
                [self retryBuilding];
            }
            
        }else{
            if(type==0){
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
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
        if(type==0){
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
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
    if(type==0){
        [hud show:NO];
    }
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